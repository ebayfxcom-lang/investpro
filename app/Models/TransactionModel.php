<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class TransactionModel extends Model
{
    protected string $table = 'transactions';

    public function getUserTransactions(int $userId, int $limit = 50): array
    {
        return $this->db->fetchAll(
            "SELECT * FROM transactions WHERE user_id = ? ORDER BY created_at DESC LIMIT ?",
            [$userId, $limit]
        );
    }

    public function addTransaction(int $userId, string $type, float $amount, string $currency, string $description, string $status = 'completed', ?int $refId = null): string
    {
        return $this->db->insert('transactions', [
            'user_id'     => $userId,
            'type'        => $type,
            'amount'      => $amount,
            'currency'    => $currency,
            'description' => $description,
            'status'      => $status,
            'ref_id'      => $refId,
            'created_at'  => date('Y-m-d H:i:s'),
        ]);
    }

    public function paginateWithUsers(int $page, int $perPage = 20, string $extraWhere = '', array $params = []): array
    {
        $where = $extraWhere ? "WHERE {$extraWhere}" : '';
        $total = (int)($this->db->fetchOne(
            "SELECT COUNT(*) as cnt FROM transactions t LEFT JOIN users u ON t.user_id = u.id {$where}",
            $params
        )['cnt'] ?? 0);
        $offset = ($page - 1) * $perPage;
        $items  = $this->db->fetchAll(
            "SELECT t.*, u.username
             FROM transactions t
             LEFT JOIN users u ON t.user_id = u.id
             {$where}
             ORDER BY t.id DESC
             LIMIT {$perPage} OFFSET {$offset}",
            $params
        );
        return [
            'items'       => $items,
            'total'       => $total,
            'page'        => $page,
            'per_page'    => $perPage,
            'total_pages' => (int)ceil($total / $perPage),
        ];
    }

    public function markDepositTransactionCompleted(int $depositId): void
    {
        $this->db->update(
            'transactions',
            ['status' => 'completed'],
            ['ref_id' => $depositId, 'type' => 'deposit', 'status' => 'pending']
        );
    }

    public function getStats(): array
    {
        return [
            'total'   => $this->count(),
            'today'   => $this->count('DATE(created_at) = CURDATE()'),
            'volume'  => $this->db->fetchOne("SELECT COALESCE(SUM(amount),0) as s FROM transactions WHERE type = 'deposit' AND status = 'completed'")['s'] ?? 0,
        ];
    }
}
