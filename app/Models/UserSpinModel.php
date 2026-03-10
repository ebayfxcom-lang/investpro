<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class UserSpinModel extends Model
{
    protected string $table = 'user_spins';

    public function getOrCreate(int $userId): array
    {
        $row = $this->db->fetchOne("SELECT * FROM user_spins WHERE user_id = ?", [$userId]);
        if (!$row) {
            $id = $this->create([
                'user_id'    => $userId,
                'free_spins' => 0,
                'paid_spins' => 0,
                'updated_at' => date('Y-m-d H:i:s'),
            ]);
            $row = $this->find((int)$id);
        }
        return $row;
    }

    public function grantDailyFreeSpins(int $userId, int $count = 1): bool
    {
        $today = date('Y-m-d');
        $spin  = $this->getOrCreate($userId);
        if ($spin['last_free_spin_date'] === $today) {
            return false; // already granted today
        }
        $this->db->query(
            "UPDATE user_spins SET free_spins = free_spins + ?, last_free_spin_date = ?, updated_at = NOW() WHERE user_id = ?",
            [$count, $today, $userId]
        );
        return true;
    }

    public function hasFreeSpin(int $userId): bool
    {
        $spin = $this->getOrCreate($userId);
        return (int)$spin['free_spins'] > 0;
    }

    public function hasPaidSpin(int $userId): bool
    {
        $spin = $this->getOrCreate($userId);
        return (int)$spin['paid_spins'] > 0;
    }

    public function consumeFreeSpin(int $userId): bool
    {
        $rows = $this->db->query(
            "UPDATE user_spins SET free_spins = free_spins - 1, updated_at = NOW() WHERE user_id = ? AND free_spins > 0",
            [$userId]
        )->rowCount();
        return $rows > 0;
    }

    public function consumePaidSpin(int $userId): bool
    {
        $rows = $this->db->query(
            "UPDATE user_spins SET paid_spins = paid_spins - 1, updated_at = NOW() WHERE user_id = ? AND paid_spins > 0",
            [$userId]
        )->rowCount();
        return $rows > 0;
    }

    public function addPaidSpins(int $userId, int $count): void
    {
        $this->getOrCreate($userId);
        $this->db->query(
            "UPDATE user_spins SET paid_spins = paid_spins + ?, updated_at = NOW() WHERE user_id = ?",
            [$count, $userId]
        );
    }

    public function getTotalSpins(int $userId): int
    {
        $spin = $this->getOrCreate($userId);
        return (int)$spin['free_spins'] + (int)$spin['paid_spins'];
    }
}
