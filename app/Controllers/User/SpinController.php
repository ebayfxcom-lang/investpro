<?php
declare(strict_types=1);

namespace App\Controllers\User;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\UserSpinModel;
use App\Models\SpinRewardModel;
use App\Models\SpinHistoryModel;
use App\Models\SpinSettingsModel;
use App\Services\SpinService;

class SpinController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('user');
        $userId = (int)Auth::id('user');

        $spinService   = new SpinService();
        $settingsModel = new SpinSettingsModel();
        $userSpinModel = new UserSpinModel();
        $historyModel  = new SpinHistoryModel();
        $rewardModel   = new SpinRewardModel();

        // Grant daily free spins on page load
        $spinService->grantDailyFreeSpins($userId);

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->json(['success' => false, 'error' => 'Invalid CSRF token.'], 403);
                return;
            }

            $action = $request->post('action', '');

            if ($action === 'spin') {
                // Accept both 'spin_type' and legacy 'type' parameter names from the frontend
                $spinType = $request->post('spin_type', $request->post('type', 'free'));
                if (!in_array($spinType, ['free', 'paid'], true)) {
                    $this->json(['success' => false, 'message' => 'Invalid spin type.'], 400);
                    return;
                }
                $result = $spinService->performSpin($userId, $spinType);

                if (!$result['success']) {
                    (new AuditLog())->log('spin_failed', "Spin failed ({$spinType}): " . ($result['error'] ?? 'unknown'), $userId, $request->ip());
                    $this->json(['success' => false, 'message' => $result['error'] ?? 'Spin failed. Please try again.'], 422);
                    return;
                }

                $reward      = $result['reward'] ?? [];
                $rewardType  = $reward['reward_type'] ?? 'no_reward';
                $rewardValue = (float)($reward['reward_value'] ?? 0);

                // Points are not used in this system – treat as no reward for display purposes
                $displayAmount = in_array($rewardType, ['no_reward', 'points', ''], true) ? 0.0 : $rewardValue;

                (new AuditLog())->log('spin_performed', "Spin ({$spinType}): {$rewardType} value={$rewardValue}", $userId, $request->ip());

                $this->json([
                    'success'      => true,
                    'reward_type'  => $rewardType,
                    'reward_label' => $reward['label'] ?? ($rewardType === 'no_reward' ? 'Better luck next time!' : 'No Prize'),
                    'reward_amount'=> $displayAmount,
                ]);
                return;
            }

            if ($action === 'purchase') {
                $quantity = max(1, (int)$request->post('quantity', 1));
                $result   = $spinService->purchaseSpins($userId, $quantity);
                if ($result['success']) {
                    (new AuditLog())->log('spins_purchased', "Purchased {$quantity} spins", $userId, $request->ip());
                    $this->flash('success', "Successfully purchased {$quantity} spin(s)!");
                } else {
                    $this->flash('error', $result['error'] ?? 'Purchase failed.');
                }
                $this->redirect('/user/spin');
                return;
            }
        }

        $settings  = $settingsModel->getSettings();
        $userSpins = $userSpinModel->getOrCreate($userId);
        $history   = $historyModel->getUserHistory($userId, 20);
        $rewards   = $rewardModel->getActiveRewards();

        // Pass user's USD wallet balance for purchase display
        $walletModel = new \App\Models\WalletModel();
        $usdBalance  = $walletModel->getBalance($userId, 'USD');

        $this->view('user/spin/index', [
            'title'       => 'Spin & Earn',
            'settings'    => $settings,
            'user_spins'  => $userSpins,
            'history'     => $history,
            'rewards'     => $rewards,
            'usd_balance' => $usdBalance,
        ]);
    }
}
