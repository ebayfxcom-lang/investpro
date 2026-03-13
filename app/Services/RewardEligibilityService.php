<?php
declare(strict_types=1);

namespace App\Services;

use App\Core\Database;

/**
 * Evaluates whether a user is eligible to claim a reward offer,
 * and computes their progress towards the eligibility requirement.
 */
class RewardEligibilityService
{
    private Database $db;

    public function __construct()
    {
        $this->db = Database::getInstance();
    }

    /**
     * Returns ['eligible' => bool, 'progress' => float, 'target' => float, 'label' => string, 'pct' => int].
     */
    public function check(int $userId, array $offer): array
    {
        $rule      = $offer['eligibility_rule'] ?? 'first_deposit';
        $ruleValue = (float)($offer['rule_value'] ?? 1);

        switch ($rule) {
            case 'first_deposit':
                return $this->addPct($this->checkFirstDeposit($userId));

            case 'invest_plan':
                return $this->addPct($this->checkInvestPlan($userId, $ruleValue));

            case 'complete_deposits':
                return $this->addPct($this->checkDepositCount($userId, (int)$ruleValue));

            case 'refer_users':
                return $this->addPct($this->checkReferrals($userId, (int)$ruleValue));

            case 'buy_spins':
                return $this->addPct($this->checkBuySpins($userId, (int)$ruleValue));

            case 'daily_login':
                return $this->addPct($this->checkDailyLogin($userId, (int)$ruleValue));

            case 'earn_spin_rewards':
                return $this->addPct($this->checkSpinRewards($userId, (int)$ruleValue));

            default:
                return ['eligible' => true, 'progress' => 1, 'target' => 1, 'pct' => 100, 'label' => 'Eligible'];
        }
    }

    private function addPct(array $result): array
    {
        $result['pct'] = $result['target'] > 0
            ? (int)min(100, round($result['progress'] / $result['target'] * 100))
            : 100;
        return $result;
    }

    private function checkFirstDeposit(int $userId): array
    {
        try {
            $count = (int)($this->db->fetchOne(
                "SELECT COUNT(*) AS cnt FROM deposits WHERE user_id = ? AND status != 'cancelled'",
                [$userId]
            )['cnt'] ?? 0);
        } catch (\Throwable) {
            $count = 0;
        }
        $eligible = $count >= 1;
        return [
            'eligible' => $eligible,
            'progress' => min($count, 1),
            'target'   => 1,
            'label'    => $eligible ? '1 / 1 deposit completed' : '0 / 1 deposit completed',
        ];
    }

    private function checkInvestPlan(int $userId, float $minAmount): array
    {
        try {
            $row = $this->db->fetchOne(
                "SELECT COALESCE(SUM(amount),0) AS total FROM deposits
                 WHERE user_id = ? AND status != 'cancelled'",
                [$userId]
            );
            $total = (float)($row['total'] ?? 0);
        } catch (\Throwable) {
            $total = 0;
        }
        $eligible = $total >= $minAmount;
        $pct = $minAmount > 0 ? min(100, round($total / $minAmount * 100, 1)) : 100;
        return [
            'eligible' => $eligible,
            'progress' => $total,
            'target'   => $minAmount,
            'label'    => number_format($total, 2) . ' / ' . number_format($minAmount, 2) . ' deposited (' . $pct . '%)',
        ];
    }

    private function checkDepositCount(int $userId, int $required): array
    {
        try {
            $count = (int)($this->db->fetchOne(
                "SELECT COUNT(*) AS cnt FROM deposits WHERE user_id = ? AND status != 'cancelled'",
                [$userId]
            )['cnt'] ?? 0);
        } catch (\Throwable) {
            $count = 0;
        }
        $eligible = $count >= $required;
        return [
            'eligible' => $eligible,
            'progress' => min($count, $required),
            'target'   => $required,
            'label'    => min($count, $required) . ' / ' . $required . ' deposits completed',
        ];
    }

    private function checkReferrals(int $userId, int $required): array
    {
        try {
            $count = (int)($this->db->fetchOne(
                "SELECT COUNT(*) AS cnt FROM users WHERE referred_by = ? AND status = 'active'",
                [$userId]
            )['cnt'] ?? 0);
        } catch (\Throwable) {
            $count = 0;
        }
        $eligible = $count >= $required;
        return [
            'eligible' => $eligible,
            'progress' => min($count, $required),
            'target'   => $required,
            'label'    => min($count, $required) . ' / ' . $required . ' active referrals',
        ];
    }

    private function checkBuySpins(int $userId, int $required): array
    {
        try {
            $count = (int)($this->db->fetchOne(
                "SELECT COUNT(*) AS cnt FROM spin_history WHERE user_id = ? AND spin_type = 'paid'",
                [$userId]
            )['cnt'] ?? 0);
        } catch (\Throwable) {
            $count = 0;
        }
        $eligible = $count >= $required;
        return [
            'eligible' => $eligible,
            'progress' => min($count, $required),
            'target'   => $required,
            'label'    => min($count, $required) . ' / ' . $required . ' paid spins used',
        ];
    }

    private function checkDailyLogin(int $userId, int $required): array
    {
        // Check consecutive login streak via audit_logs
        try {
            $rows = $this->db->fetchAll(
                "SELECT DATE(created_at) AS login_date FROM audit_logs
                 WHERE user_id = ? AND action = 'login'
                 GROUP BY DATE(created_at)
                 ORDER BY login_date DESC
                 LIMIT ?",
                [$userId, $required]
            );
        } catch (\Throwable) {
            $rows = [];
        }
        $streak = 0;
        $today  = new \DateTimeImmutable('today');
        foreach ($rows as $i => $row) {
            $day = new \DateTimeImmutable($row['login_date']);
            if ($today->diff($day)->days !== $i) {
                break;
            }
            $streak++;
        }
        $eligible = $streak >= $required;
        return [
            'eligible' => $eligible,
            'progress' => min($streak, $required),
            'target'   => $required,
            'label'    => min($streak, $required) . ' / ' . $required . ' day login streak',
        ];
    }

    private function checkSpinRewards(int $userId, int $required): array
    {
        try {
            $count = (int)($this->db->fetchOne(
                "SELECT COUNT(*) AS cnt FROM spin_history WHERE user_id = ? AND reward_type NOT IN ('no_reward','')",
                [$userId]
            )['cnt'] ?? 0);
        } catch (\Throwable) {
            $count = 0;
        }
        $eligible = $count >= $required;
        return [
            'eligible' => $eligible,
            'progress' => min($count, $required),
            'target'   => $required,
            'label'    => min($count, $required) . ' / ' . $required . ' spin rewards earned',
        ];
    }
}
