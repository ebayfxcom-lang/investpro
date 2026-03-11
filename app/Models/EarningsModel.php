<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class EarningsModel extends Model
{
    protected string $table = 'earnings';

    public function getUserEarnings(int $userId, int $limit = 50): array
    {
        return $this->findAll('user_id = ?', [$userId], 'created_at DESC', $limit);
    }

    public function getTotalEarnings(int $userId): float
    {
        $row = $this->db->fetchOne(
            "SELECT COALESCE(SUM(amount),0) as total FROM earnings WHERE user_id = ? AND status = 'paid'",
            [$userId]
        );
        return (float)($row['total'] ?? 0);
    }

    public function getStats(): array
    {
        return [
            'total'       => (float)($this->db->fetchOne("SELECT COALESCE(SUM(amount),0) as s FROM earnings WHERE status = 'paid'")['s'] ?? 0),
            'today'       => (float)($this->db->fetchOne("SELECT COALESCE(SUM(amount),0) as s FROM earnings WHERE DATE(created_at) = CURDATE() AND status = 'paid'")['s'] ?? 0),
        ];
    }

    /**
     * Paginate earnings with username joined for admin display.
     */
    public function paginateWithUsers(int $page, int $perPage = 20): array
    {
        $offset = ($page - 1) * $perPage;
        $total  = $this->count();
        $items  = $this->db->fetchAll(
            "SELECT e.*, u.username, d.currency as deposit_currency
             FROM earnings e
             LEFT JOIN users u ON e.user_id = u.id
             LEFT JOIN deposits d ON e.deposit_id = d.id
             ORDER BY e.created_at DESC
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
