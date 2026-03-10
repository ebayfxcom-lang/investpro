<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class BlacklistModel extends Model
{
    protected string $table = 'blacklist';

    public function isBlacklisted(string $value, string $type = 'ip'): bool
    {
        $row = $this->db->fetchOne(
            "SELECT id FROM blacklist WHERE value = ? AND type = ? AND (expires_at IS NULL OR expires_at > NOW())",
            [$value, $type]
        );
        return $row !== null;
    }

    public function addEntry(string $value, string $type, string $reason = '', ?string $expiresAt = null): string
    {
        return $this->db->insert('blacklist', [
            'value'      => $value,
            'type'       => $type,
            'reason'     => $reason,
            'expires_at' => $expiresAt,
            'created_at' => date('Y-m-d H:i:s'),
        ]);
    }
}
