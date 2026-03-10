<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class SettingsModel extends Model
{
    protected string $table = 'settings';
    private static array $cache = [];

    public function get(string $key, mixed $default = null): mixed
    {
        if (isset(self::$cache[$key])) {
            return self::$cache[$key];
        }
        $row = $this->db->fetchOne("SELECT value FROM settings WHERE `key` = ?", [$key]);
        $value = $row ? $row['value'] : $default;
        self::$cache[$key] = $value;
        return $value;
    }

    public function set(string $key, mixed $value): void
    {
        $existing = $this->db->fetchOne("SELECT id FROM settings WHERE `key` = ?", [$key]);
        if ($existing) {
            $this->db->update('settings', ['value' => $value, 'updated_at' => date('Y-m-d H:i:s')], ['key' => $key]);
        } else {
            $this->db->insert('settings', ['key' => $key, 'value' => $value, 'updated_at' => date('Y-m-d H:i:s')]);
        }
        self::$cache[$key] = $value;
    }

    public function setMany(array $settings): void
    {
        foreach ($settings as $key => $value) {
            $this->set($key, $value);
        }
    }

    public function getAll(): array
    {
        $rows = $this->db->fetchAll("SELECT `key`, `value` FROM settings");
        return array_column($rows, 'value', 'key');
    }

    public function getGroup(string $prefix): array
    {
        $rows = $this->db->fetchAll("SELECT `key`, `value` FROM settings WHERE `key` LIKE ?", [$prefix . '%']);
        return array_column($rows, 'value', 'key');
    }
}
