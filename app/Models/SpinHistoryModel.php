<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class SpinHistoryModel extends Model
{
    protected string $table = 'spin_history';

    public function getUserHistory(int $userId, int $limit = 50): array
    {
        return $this->db->fetchAll(
            "SELECT * FROM spin_history WHERE user_id = ? ORDER BY created_at DESC LIMIT ?",
            [$userId, $limit]
        );
    }

    public function getRecentHistory(int $limit = 100): array
    {
        return $this->db->fetchAll(
            "SELECT sh.*, u.username FROM spin_history sh
             JOIN users u ON sh.user_id = u.id
             ORDER BY sh.created_at DESC LIMIT ?",
            [$limit]
        );
    }

    public function getTotalWinnings(int $userId): float
    {
        $row = $this->db->fetchOne(
            "SELECT COALESCE(SUM(reward_value),0) as total FROM spin_history WHERE user_id = ? AND reward_type != 'no_reward'",
            [$userId]
        );
        return (float)($row['total'] ?? 0);
    }
}
