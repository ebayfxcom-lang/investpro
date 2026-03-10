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

    public function getAllRewards(): array
    {
        return $this->findAll('', [], 'slot ASC');
    }

    public function spin(): ?array
    {
        $rewards = $this->getActiveRewards();
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
