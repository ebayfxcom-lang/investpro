<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class SpinRewardModel extends Model
{
    protected string $table = 'spin_rewards';

    public function getActiveRewards(): array
    {
        return $this->findAll('status = ?', ['active'], 'slot ASC');
    }

    public function getActiveRewardsByMode(string $mode): array
    {
        // Returns rewards for a specific mode: 'free', 'paid', or 'both'
        // A reward with mode='both' applies to both free and paid spins
        return $this->db->fetchAll(
            "SELECT * FROM spin_rewards WHERE status = 'active' AND (spin_mode = ? OR spin_mode = 'both') ORDER BY slot ASC",
            [$mode]
        );
    }

    public function getAllRewards(): array
    {
        return $this->findAll('', [], 'slot ASC');
    }

    public function getFreeRewards(): array
    {
        return $this->db->fetchAll(
            "SELECT * FROM spin_rewards WHERE status = 'active' AND (spin_mode = 'free' OR spin_mode = 'both') ORDER BY slot ASC"
        );
    }

    public function getPaidRewards(): array
    {
        return $this->db->fetchAll(
            "SELECT * FROM spin_rewards WHERE status = 'active' AND (spin_mode = 'paid' OR spin_mode = 'both') ORDER BY slot ASC"
        );
    }

    private function getActiveCurrencyCodes(): array
    {
        try {
            $rows = $this->db->fetchAll("SELECT code FROM currencies WHERE status = 'active'");
            return array_column($rows, 'code');
        } catch (\Throwable $e) {
            return ['USD', 'EUR', 'BTC', 'ETH', 'USDT'];
        }
    }

    public function spin(?string $spinMode = null): ?array
    {
        if ($spinMode === 'free') {
            $rewards = $this->getFreeRewards();
        } elseif ($spinMode === 'paid') {
            $rewards = $this->getPaidRewards();
        } else {
            $rewards = $this->getActiveRewards();
        }

        if (empty($rewards)) {
            // No mode-specific rewards configured – signal caller to handle this case
            return null;
        }

        // Filter out rewards whose type is not a recognised special type and not an active currency
        $validSpecialTypes    = ['spin_credits', 'points', 'percent_bonus', 'no_reward', 'usd', 'eur', 'bonus'];
        $activeCurrenciesUpper = $this->getActiveCurrencyCodes();
        $rewards = array_values(array_filter($rewards, function (array $r) use ($validSpecialTypes, $activeCurrenciesUpper): bool {
            $type = strtolower($r['reward_type'] ?? '');
            if (in_array($type, $validSpecialTypes, true)) {
                return true;
            }
            return in_array(strtoupper($type), $activeCurrenciesUpper, true);
        }));

        if (empty($rewards)) {
            return null;
        }

        // Server-side probability calculation - tamper-resistant
        $total = array_sum(array_column($rewards, 'probability'));
        // Use cryptographically secure random integer scaled to 6 decimal places
        $rand = random_int(0, (int)round($total * 1_000_000)) / 1_000_000;
        $cumulative = 0.0;
        foreach ($rewards as $reward) {
            $cumulative += (float)$reward['probability'];
            if ($rand <= $cumulative) {
                return $reward;
            }
        }
        return $rewards[array_key_last($rewards)];
    }
}
