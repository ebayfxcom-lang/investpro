<?php
declare(strict_types=1);

namespace App\Services;

use App\Core\Database;
use App\Models\DepositModel;
use App\Models\PlanModel;
use App\Models\EarningsModel;
use App\Models\WalletModel;
use App\Models\TransactionModel;
use App\Models\ReferralModel;
use App\Models\SettingsModel;
use App\Models\UserModel;

class InvestmentService
{
    private Database $db;

    public function __construct()
    {
        $this->db = Database::getInstance();
    }

    /**
     * Process daily earnings for all active deposits.
     * This should be called via a cron job.
     */
    public function processEarnings(): array
    {
        $depositModel  = new DepositModel();
        $planModel     = new PlanModel();
        $earningsModel = new EarningsModel();
        $walletModel   = new WalletModel();
        $transModel    = new TransactionModel();

        $activeDeposits = $depositModel->findAll(
            "status = ? AND (expires_at IS NULL OR expires_at > NOW())",
            ['active'],
            'id ASC'
        );

        $processed = 0;
        $totalPaid  = 0.0;

        foreach ($activeDeposits as $deposit) {
            $plan = $planModel->find((int)$deposit['plan_id']);
            if (!$plan || $plan['status'] !== 'active') continue;

            // Calculate earning
            $amount   = (float)$deposit['amount'] * ((float)$plan['roi_percent'] / 100);
            $currency = $deposit['currency'];
            $userId   = (int)$deposit['user_id'];

            // Record earning
            $earningsModel->create([
                'user_id'    => $userId,
                'deposit_id' => $deposit['id'],
                'amount'     => $amount,
                'currency'   => $currency,
                'type'       => 'roi',
                'status'     => 'paid',
                'created_at' => date('Y-m-d H:i:s'),
            ]);

            // Credit wallet
            $walletModel->credit($userId, $currency, $amount);

            // Add transaction
            $transModel->addTransaction($userId, 'earning', $amount, $currency, "ROI Earning - Plan: {$plan['name']}");

            $processed++;
            $totalPaid += $amount;
        }

        return ['processed' => $processed, 'total_paid' => $totalPaid];
    }

    /**
     * Complete expired deposits and optionally return principal.
     */
    public function processExpiredDeposits(): array
    {
        $depositModel = new DepositModel();
        $planModel    = new PlanModel();
        $walletModel  = new WalletModel();
        $transModel   = new TransactionModel();

        $expiredDeposits = $depositModel->findAll(
            "status = ? AND expires_at <= NOW()",
            ['active'],
            'id ASC'
        );

        $processed = 0;
        foreach ($expiredDeposits as $deposit) {
            $this->db->beginTransaction();
            try {
                $depositModel->update((int)$deposit['id'], ['status' => 'completed', 'updated_at' => date('Y-m-d H:i:s')]);

                // Return principal if plan says so
                $plan = $planModel->find((int)$deposit['plan_id']);
                if ($plan && $plan['principal_return']) {
                    $walletModel->credit((int)$deposit['user_id'], $deposit['currency'], (float)$deposit['amount']);
                    $transModel->addTransaction(
                        (int)$deposit['user_id'],
                        'deposit',
                        (float)$deposit['amount'],
                        $deposit['currency'],
                        'Principal returned on deposit #' . $deposit['id']
                    );
                }

                $this->db->commit();
                $processed++;
            } catch (\Throwable $e) {
                $this->db->rollBack();
                error_log('processExpiredDeposits error: ' . $e->getMessage());
            }
        }

        return ['processed' => $processed];
    }

    /**
     * Pay referral commission on a deposit.
     */
    public function payReferralCommission(int $userId, int $depositId, float $depositAmount, string $currency): void
    {
        $userModel     = new UserModel();
        $settingsModel = new SettingsModel();
        $walletModel   = new WalletModel();
        $transModel    = new TransactionModel();
        $refModel      = new ReferralModel();

        $referralPercent = (float)($settingsModel->get('referral_percent', 5));
        $referralLevels  = (int)($settingsModel->get('referral_levels', 1));

        $user = $userModel->find($userId);
        if (!$user || !$user['referred_by']) return;

        $referrerId = (int)$user['referred_by'];
        $commission = $depositAmount * ($referralPercent / 100);

        if ($commission <= 0) return;

        $refModel->create([
            'referrer_id' => $referrerId,
            'referee_id'  => $userId,
            'deposit_id'  => $depositId,
            'amount'      => $commission,
            'currency'    => $currency,
            'level'       => 1,
            'status'      => 'paid',
            'created_at'  => date('Y-m-d H:i:s'),
        ]);

        $walletModel->credit($referrerId, $currency, $commission);
        $transModel->addTransaction($referrerId, 'referral', $commission, $currency, "Referral commission - Level 1 from user #{$userId}");
    }
}
