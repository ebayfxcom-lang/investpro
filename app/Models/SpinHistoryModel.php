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

    /**
     * Paginate spin history with username join for admin display.
     */
    public function paginateWithUsers(int $page, int $perPage = 30): array
    {
        $offset = ($page - 1) * $perPage;
        $total  = $this->count();
        $items  = $this->db->fetchAll(
            "SELECT sh.*, u.username
             FROM spin_history sh
             LEFT JOIN users u ON sh.user_id = u.id
             ORDER BY sh.created_at DESC
             LIMIT ? OFFSET ?",
            [$perPage, $offset]
        );
        return [
            'items'       => $items,
            'total'       => $total,
            'page'        => $page,
            'per_page'    => $perPage,
            'total_pages' => (int)ceil($total / max(1, $perPage)),
        ];
    }
}
