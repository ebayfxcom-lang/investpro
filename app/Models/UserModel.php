<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class UserModel extends Model
{
    protected string $table = 'users';

    public function findByEmail(string $email): ?array
    {
        return $this->db->fetchOne("SELECT * FROM users WHERE email = ?", [$email]);
    }

    public function findByUsername(string $username): ?array
    {
        return $this->db->fetchOne("SELECT * FROM users WHERE username = ?", [$username]);
    }

    public function findByReferralCode(string $code): ?array
    {
        return $this->db->fetchOne("SELECT * FROM users WHERE referral_code = ?", [$code]);
    }

    public function hashPassword(string $password): string
    {
        return password_hash($password, PASSWORD_ARGON2ID, [
            'memory_cost' => 65536,
            'time_cost'   => 4,
            'threads'     => 3,
        ]);
    }

    public function verifyPassword(string $password, string $hash): bool
    {
        return password_verify($password, $hash);
    }

    public function generateReferralCode(): string
    {
        do {
            $code = strtoupper(substr(bin2hex(random_bytes(4)), 0, 8));
        } while ($this->findByReferralCode($code));
        return $code;
    }

    public function getReferrals(int $userId): array
    {
        return $this->db->fetchAll(
            "SELECT u.id, u.username, u.email, u.created_at, u.status FROM users u WHERE u.referred_by = ?",
            [$userId]
        );
    }

    public function getStats(): array
    {
        return [
            'total'  => $this->count(),
            'active' => $this->count('status = ?', ['active']),
            'banned' => $this->count('status = ?', ['banned']),
            'new_today' => $this->count('DATE(created_at) = CURDATE()'),
        ];
    }
}
