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
}
