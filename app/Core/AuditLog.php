<?php
declare(strict_types=1);

namespace App\Core;

class AuditLog
{
    private Database $db;

    public function __construct()
    {
        $this->db = Database::getInstance();
    }

    public function log(string $action, string $description, ?int $userId = null, ?string $ipAddress = null): void
    {
        try {
            $this->db->insert('audit_logs', [
                'user_id'     => $userId,
                'action'      => $action,
                'description' => $description,
                'ip_address'  => $ipAddress ?? '0.0.0.0',
                'created_at'  => date('Y-m-d H:i:s'),
            ]);
        } catch (\Throwable) {
            // Silently fail to not interrupt flow
        }
    }

    public function getRecent(int $limit = 50): array
    {
        try {
            return $this->db->fetchAll(
                "SELECT al.*, u.username FROM audit_logs al
                 LEFT JOIN users u ON al.user_id = u.id
                 ORDER BY al.created_at DESC LIMIT ?",
                [$limit]
            );
        } catch (\Throwable) {
            return [];
        }
    }
}
