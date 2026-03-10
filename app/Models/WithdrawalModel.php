<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class WithdrawalModel extends Model
{
    protected string $table = 'withdrawals';

    public function getUserWithdrawals(int $userId): array
    {
        return $this->findAll('user_id = ?', [$userId], 'created_at DESC');
    }

    public function getPending(): array
    {
        return $this->db->fetchAll(
            "SELECT w.*, u.username, u.email FROM withdrawals w
             JOIN users u ON w.user_id = u.id
             WHERE w.status = 'pending' ORDER BY w.created_at ASC"
        );
    }

    public function getStats(): array
    {
        return [
            'total'         => $this->count(),
            'pending'       => $this->count('status = ?', ['pending']),
            'total_amount'  => $this->db->fetchOne("SELECT COALESCE(SUM(amount),0) as s FROM withdrawals WHERE status = 'approved'")['s'] ?? 0,
            'pending_amount'=> $this->db->fetchOne("SELECT COALESCE(SUM(amount),0) as s FROM withdrawals WHERE status = 'pending'")['s'] ?? 0,
        ];
    }
}
