<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class KycModel extends Model
{
    protected string $table = 'kyc_submissions';

    public function getByUser(int $userId): ?array
    {
        return $this->db->fetchOne("SELECT * FROM kyc_submissions WHERE user_id = ?", [$userId]);
    }

    public function upsert(int $userId, array $data): void
    {
        $existing = $this->getByUser($userId);
        if ($existing) {
            $this->update((int)$existing['id'], array_merge($data, ['updated_at' => date('Y-m-d H:i:s')]));
        } else {
            $this->create(array_merge(['user_id' => $userId, 'created_at' => date('Y-m-d H:i:s')], $data));
        }
    }

    public function getPending(): array
    {
        return $this->db->fetchAll(
            "SELECT k.*, u.username, u.email FROM kyc_submissions k
             JOIN users u ON k.user_id = u.id
             WHERE k.status = 'pending' ORDER BY k.created_at ASC"
        );
    }

    public function paginate(int $page, int $perPage = 20, string $status = ''): array
    {
        $where  = $status ? 'k.status = ?' : '';
        $params = $status ? [$status] : [];
        $whereClause = $where ? "WHERE {$where}" : '';
        $total = (int)($this->db->fetchOne(
            "SELECT COUNT(*) as cnt FROM kyc_submissions k {$whereClause}",
            $params
        )['cnt'] ?? 0);
        $offset = ($page - 1) * $perPage;
        $items  = $this->db->fetchAll(
            "SELECT k.*, u.username, u.email
             FROM kyc_submissions k
             LEFT JOIN users u ON k.user_id = u.id
             {$whereClause}
             ORDER BY k.id DESC
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
}
