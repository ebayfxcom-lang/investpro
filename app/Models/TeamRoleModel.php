<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class TeamRoleModel extends Model
{
    protected string $table = 'team_roles';

    public function getAllRoles(): array
    {
        return $this->findAll('', [], 'sort_order ASC, id ASC');
    }

    public function getRoleWithPermissions(int $roleId): ?array
    {
        $role = $this->find($roleId);
        if (!$role) return null;
        $role['permissions'] = $this->db->fetchAll(
            "SELECT p.* FROM permissions p
             INNER JOIN role_permissions rp ON rp.permission_id = p.id
             WHERE rp.role_id = ?
             ORDER BY p.module, p.sort_order",
            [$roleId]
        );
        return $role;
    }

    public function getRoleByName(string $name): ?array
    {
        return $this->findBy(['name' => $name]);
    }

    public function getPermissionNames(int $roleId): array
    {
        $rows = $this->db->fetchAll(
            "SELECT p.name FROM permissions p
             INNER JOIN role_permissions rp ON rp.permission_id = p.id
             WHERE rp.role_id = ?",
            [$roleId]
        );
        return array_column($rows, 'name');
    }

    public function syncPermissions(int $roleId, array $permissionIds): void
    {
        $this->db->query("DELETE FROM role_permissions WHERE role_id = ?", [$roleId]);
        foreach ($permissionIds as $pid) {
            $this->db->query(
                "INSERT IGNORE INTO role_permissions (role_id, permission_id) VALUES (?, ?)",
                [$roleId, (int)$pid]
            );
        }
    }

    public function getAllPermissions(): array
    {
        return $this->db->fetchAll("SELECT * FROM permissions ORDER BY module, sort_order");
    }

    public function getPermissionsGrouped(): array
    {
        $all    = $this->getAllPermissions();
        $groups = [];
        foreach ($all as $p) {
            $groups[$p['module']][] = $p;
        }
        return $groups;
    }
}
