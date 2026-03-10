<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class WalletModel extends Model
{
    protected string $table = 'wallets';

    public function getUserWallets(int $userId): array
    {
        return $this->findAll('user_id = ?', [$userId], 'currency ASC');
    }

    public function getWallet(int $userId, string $currency): ?array
    {
        return $this->db->fetchOne(
            "SELECT * FROM wallets WHERE user_id = ? AND currency = ?",
            [$userId, strtoupper($currency)]
        );
    }

    public function getOrCreate(int $userId, string $currency): array
    {
        $wallet = $this->getWallet($userId, $currency);
        if (!$wallet) {
            $id = $this->db->insert('wallets', [
                'user_id'    => $userId,
                'currency'   => strtoupper($currency),
                'balance'    => 0.00,
                'locked'     => 0.00,
                'created_at' => date('Y-m-d H:i:s'),
            ]);
            $wallet = $this->find($id);
        }
        return $wallet;
    }

    public function credit(int $userId, string $currency, float $amount): bool
    {
        $this->getOrCreate($userId, $currency);
        $rows = $this->db->query(
            "UPDATE wallets SET balance = balance + ? WHERE user_id = ? AND currency = ?",
            [$amount, $userId, strtoupper($currency)]
        )->rowCount();
        return $rows > 0;
    }

    public function debit(int $userId, string $currency, float $amount): bool
    {
        $rows = $this->db->query(
            "UPDATE wallets SET balance = balance - ? WHERE user_id = ? AND currency = ? AND balance >= ?",
            [$amount, $userId, strtoupper($currency), $amount]
        )->rowCount();
        return $rows > 0;
    }

    public function getBalance(int $userId, string $currency): float
    {
        $wallet = $this->getWallet($userId, $currency);
        return (float)($wallet['balance'] ?? 0);
    }

    public function getTotalBalance(): array
    {
        return $this->db->fetchAll(
            "SELECT currency, SUM(balance) as total FROM wallets GROUP BY currency ORDER BY currency"
        );
    }
}
