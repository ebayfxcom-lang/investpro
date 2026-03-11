<?php
declare(strict_types=1);

namespace App\Services;

use App\Models\SpinRewardModel;
use App\Models\UserSpinModel;
use App\Models\SpinHistoryModel;
use App\Models\SpinSettingsModel;
use App\Models\WalletModel;
use App\Core\Database;

class SpinService
{
    private SpinRewardModel   $rewardModel;
    private UserSpinModel     $userSpinModel;
    private SpinHistoryModel  $historyModel;
    private SpinSettingsModel $settingsModel;
    private WalletModel       $walletModel;

    public function __construct()
    {
        $this->rewardModel   = new SpinRewardModel();
        $this->userSpinModel = new UserSpinModel();
        $this->historyModel  = new SpinHistoryModel();
        $this->settingsModel = new SpinSettingsModel();
        $this->walletModel   = new WalletModel();
    }

    /**
     * Grant daily free spins to user if applicable.
     * Call this on user login.
     */
    public function grantDailyFreeSpins(int $userId): bool
    {
        $settings = $this->settingsModel->getSettings();
        if (!$settings['enabled']) {
            return false;
        }
        return $this->userSpinModel->grantDailyFreeSpins($userId, (int)$settings['daily_free_spins']);
    }

    /**
     * Perform a spin for the user.
     * $spinType: 'free' or 'paid'
     * Returns ['success' => bool, 'reward' => array|null, 'error' => string|null]
     */
    public function performSpin(int $userId, string $spinType = 'free'): array
    {
        if (!in_array($spinType, ['free', 'paid'], true)) {
            return ['success' => false, 'reward' => null, 'error' => 'Invalid spin type.'];
        }

        $settings = $this->settingsModel->getSettings();
        if (!$settings['enabled']) {
            return ['success' => false, 'reward' => null, 'error' => 'Spin rewards are currently disabled.'];
        }

        $db = Database::getInstance();
        $db->beginTransaction();

        try {
            // Check and consume spin
            if ($spinType === 'free') {
                if (!$this->userSpinModel->consumeFreeSpin($userId)) {
                    $db->rollBack();
                    return ['success' => false, 'reward' => null, 'error' => 'No free spins available.'];
                }
            } else {
                if (!$this->userSpinModel->consumePaidSpin($userId)) {
                    $db->rollBack();
                    return ['success' => false, 'reward' => null, 'error' => 'No paid spins available.'];
                }
            }

            // Spin the wheel
            $reward = $this->rewardModel->spin($spinType);
            if (!$reward) {
                $db->rollBack();
                return ['success' => false, 'reward' => null, 'error' => 'No rewards configured.'];
            }

            // Apply reward
            $this->applyReward($userId, $reward);

            // Record history
            $this->historyModel->create([
                'user_id'      => $userId,
                'reward_id'    => $reward['id'],
                'spin_type'    => $spinType,
                'reward_type'  => $reward['reward_type'],
                'reward_value' => $reward['reward_value'],
                'reward_label' => $reward['label'],
                'created_at'   => date('Y-m-d H:i:s'),
            ]);

            $db->commit();
            return ['success' => true, 'reward' => $reward, 'error' => null];
        } catch (\Throwable $e) {
            $db->rollBack();
            error_log('SpinService error: ' . $e->getMessage());
            return ['success' => false, 'reward' => null, 'error' => 'An error occurred. Please try again.'];
        }
    }

    private function applyReward(int $userId, array $reward): void
    {
        $type  = $reward['reward_type'];
        $value = (float)$reward['reward_value'];

        match ($type) {
            'usd'        => $this->walletModel->credit($userId, 'USD', $value),
            'eur'        => $this->walletModel->credit($userId, 'EUR', $value),
            'bonus'      => $this->walletModel->credit($userId, 'USD', $value),
            'spin_credits' => $this->userSpinModel->addPaidSpins($userId, (int)$value),
            'points', 'percent_bonus', 'no_reward' => null, // handled separately if needed
            default      => null,
        };
    }

    /**
     * Purchase spins for user. Deducts USD from wallet.
     */
    public function purchaseSpins(int $userId, int $quantity): array
    {
        $settings = $this->settingsModel->getSettings();
        $totalCost = (float)$settings['spin_price'] * $quantity;

        $db = Database::getInstance();
        $db->beginTransaction();
        try {
            if (!$this->walletModel->debit($userId, 'USD', $totalCost)) {
                $db->rollBack();
                return ['success' => false, 'error' => 'Insufficient USD balance.'];
            }
            $this->userSpinModel->addPaidSpins($userId, $quantity);
            $db->commit();
        } catch (\Throwable $e) {
            $db->rollBack();
            error_log('SpinService purchaseSpins error: ' . $e->getMessage());
            return ['success' => false, 'error' => 'An error occurred. Please try again.'];
        }

        return ['success' => true, 'error' => null];
    }
}
