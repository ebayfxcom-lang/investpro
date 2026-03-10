<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class ReferralModel extends Model
{
    protected string $table = 'referral_earnings';

    public function getUserEarnings(int $userId): array
    {
        return $this->findAll('referrer_id = ?', [$userId], 'created_at DESC');
    }

    public function getTotalEarnings(int $userId): float
    {
        $row = $this->db->fetchOne(
            "SELECT COALESCE(SUM(amount),0) as total FROM referral_earnings WHERE referrer_id = ? AND status = 'paid'",
            [$userId]
        );
        return (float)($row['total'] ?? 0);
    }

    public function getReferralStats(int $userId): array
    {
        return [
            'total_referrals' => $this->db->fetchOne("SELECT COUNT(*) as c FROM users WHERE referred_by = ?", [$userId])['c'] ?? 0,
            'total_earnings'  => $this->getTotalEarnings($userId),
            'pending'         => (float)($this->db->fetchOne("SELECT COALESCE(SUM(amount),0) as s FROM referral_earnings WHERE referrer_id = ? AND status = 'pending'", [$userId])['s'] ?? 0),
        ];
    }
}
