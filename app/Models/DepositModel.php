<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class DepositModel extends Model
{
    protected string $table = 'deposits';

    public function getUserDeposits(int $userId, string $status = ''): array
    {
        if ($status) {
            return $this->findAll('user_id = ? AND status = ?', [$userId, $status], 'created_at DESC');
        }
        return $this->findAll('user_id = ?', [$userId], 'created_at DESC');
    }

    public function getActiveDeposits(int $userId): array
    {
        return $this->findAll('user_id = ? AND status = ?', [$userId, 'active'], 'created_at DESC');
    }

    public function getExpiringDeposits(int $days = 3): array
    {
        return $this->db->fetchAll(
            "SELECT d.*, u.username, u.email, p.name as plan_name
             FROM deposits d
             JOIN users u ON d.user_id = u.id
             JOIN plans p ON d.plan_id = p.id
             WHERE d.status = 'active' AND d.expires_at BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL ? DAY)
             ORDER BY d.expires_at ASC",
            [$days]
        );
    }

    public function getStats(): array
    {
        return [
            'total'           => $this->count(),
            'active'          => $this->count('status = ?', ['active']),
            'total_amount'    => $this->db->fetchOne("SELECT COALESCE(SUM(amount),0) as s FROM deposits WHERE status != 'cancelled'")['s'] ?? 0,
            'active_amount'   => $this->db->fetchOne("SELECT COALESCE(SUM(amount),0) as s FROM deposits WHERE status = 'active'")['s'] ?? 0,
        ];
    }

    public function getTotalDepositsByUser(int $userId): float
    {
        $row = $this->db->fetchOne("SELECT COALESCE(SUM(amount),0) as total FROM deposits WHERE user_id = ? AND status != 'cancelled'", [$userId]);
        return (float)($row['total'] ?? 0);
    }
}
