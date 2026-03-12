<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class SupportTicketModel extends Model
{
    protected string $table = 'support_tickets';

    public function generateReference(): string
    {
        $row = $this->db->fetchOne("SELECT COUNT(*) AS cnt FROM support_tickets");
        $num = (int)($row['cnt'] ?? 0) + 1;
        return 'TKT-' . str_pad((string)$num, 5, '0', STR_PAD_LEFT);
    }

    public function getForUser(int $userId): array
    {
        return $this->db->fetchAll(
            "SELECT t.*, d.name AS department_name
             FROM support_tickets t
             LEFT JOIN ticket_departments d ON d.id = t.department_id
             WHERE t.user_id = ?
             ORDER BY t.created_at DESC",
            [$userId]
        );
    }

    public function getWithDepartment(int $ticketId): ?array
    {
        return $this->db->fetchOne(
            "SELECT t.*, d.name AS department_name, u.username AS user_name, u.email AS user_email
             FROM support_tickets t
             LEFT JOIN ticket_departments d ON d.id = t.department_id
             LEFT JOIN users u ON u.id = t.user_id
             WHERE t.id = ?",
            [$ticketId]
        );
    }

    public function getReplies(int $ticketId, bool $includeInternal = false): array
    {
        $sql = "SELECT r.*, u.username AS staff_name, u.first_name, u.last_name
                FROM ticket_replies r
                LEFT JOIN users u ON u.id = r.user_id
                WHERE r.ticket_id = ?";
        if (!$includeInternal) {
            $sql .= " AND r.is_internal_note = 0";
        }
        $sql .= " ORDER BY r.created_at ASC";
        return $this->db->fetchAll($sql, [$ticketId]);
    }

    public function addReply(int $ticketId, ?int $userId, string $body, bool $isStaff = false, bool $isInternal = false): int
    {
        $id = $this->db->insert('ticket_replies', [
            'ticket_id'        => $ticketId,
            'user_id'          => $userId,
            'is_staff'         => (int)$isStaff,
            'is_internal_note' => (int)$isInternal,
            'body'             => $body,
            'created_at'       => date('Y-m-d H:i:s'),
        ]);
        $this->db->query(
            "UPDATE support_tickets SET last_reply_at = NOW(), updated_at = NOW() WHERE id = ?",
            [$ticketId]
        );
        return (int)$id;
    }

    public function adminPaginate(int $page = 1, int $perPage = 25, string $status = '', int $deptId = 0): array
    {
        $where  = [];
        $params = [];
        if ($status) { $where[] = "t.status = ?"; $params[] = $status; }
        if ($deptId) { $where[] = "t.department_id = ?"; $params[] = $deptId; }
        $whereStr = $where ? implode(' AND ', $where) : '';

        $countSql = "SELECT COUNT(*) AS cnt FROM support_tickets t" . ($whereStr ? " WHERE {$whereStr}" : '');
        $total    = (int)($this->db->fetchOne($countSql, $params)['cnt'] ?? 0);

        $offset   = ($page - 1) * $perPage;
        $dataSql  = "SELECT t.*, d.name AS department_name, u.username AS user_name
                     FROM support_tickets t
                     LEFT JOIN ticket_departments d ON d.id = t.department_id
                     LEFT JOIN users u ON u.id = t.user_id"
                  . ($whereStr ? " WHERE {$whereStr}" : '')
                  . " ORDER BY t.created_at DESC LIMIT ? OFFSET ?";
        $items = $this->db->fetchAll($dataSql, array_merge($params, [$perPage, $offset]));

        return [
            'items'       => $items,
            'total'       => $total,
            'page'        => $page,
            'per_page'    => $perPage,
            'total_pages' => (int)ceil($total / $perPage),
        ];
    }
}
