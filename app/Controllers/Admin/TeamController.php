<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\TeamRoleModel;
use App\Models\UserModel;

class TeamController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');
        $roleModel = new TeamRoleModel();
        $roles     = $roleModel->getAllRoles();

        $this->view('admin/team/index', [
            'title' => 'Team Roles',
            'roles' => $roles,
            'admin' => Auth::user('admin'),
        ]);
    }

    public function editRole(Request $request, array $params): void
    {
        $this->requireAuth('admin');
        $roleModel = new TeamRoleModel();
        $role      = $roleModel->getRoleWithPermissions((int)$params['id']);
        if (!$role) {
            $this->flash('error', 'Role not found.');
            $this->redirect('/admin/team');
        }

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/admin/team/' . $params['id'] . '/edit');
            }

            $permIds = array_map('intval', (array)$request->post('permissions', []));
            $roleModel->syncPermissions((int)$params['id'], $permIds);
            if (!$role['is_system']) {
                $roleModel->update((int)$params['id'], [
                    'label'       => trim($request->post('label', $role['label'])),
                    'description' => trim($request->post('description', '')) ?: null,
                ]);
            }
            (new AuditLog())->log('role_permissions_updated', "Role #{$params['id']} permissions updated", Auth::id('admin'), $request->ip());
            $this->flash('success', 'Role permissions updated.');
            $this->redirect('/admin/team/' . $params['id'] . '/edit');
        }

        $allPerms = $roleModel->getPermissionsGrouped();
        $assigned = $roleModel->getPermissionNames((int)$params['id']);

        $this->view('admin/team/edit-role', [
            'title'    => 'Edit Role: ' . $role['label'],
            'role'     => $role,
            'all_perms' => $allPerms,
            'assigned' => $assigned,
            'admin'    => Auth::user('admin'),
        ]);
    }

    public function members(Request $request): void
    {
        $this->requireAuth('admin');
        $roleModel = new TeamRoleModel();
        $userModel = new UserModel();
        $roles     = $roleModel->getAllRoles();

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/admin/team/members');
            }

            $action = $request->post('action', '');
            $userId = (int)$request->post('user_id', 0);

            if ($action === 'assign_role' && $userId > 0) {
                $roleId = (int)$request->post('role_id', 0);
                $userModel->update($userId, ['team_role_id' => $roleId ?: null]);
                (new AuditLog())->log('team_role_assigned', "User #{$userId} assigned role #{$roleId}", Auth::id('admin'), $request->ip());
                $this->flash('success', 'Role assigned.');
            }

            if ($action === 'remove_role' && $userId > 0) {
                $userModel->update($userId, ['team_role_id' => null]);
                (new AuditLog())->log('team_role_removed', "Team role removed from user #{$userId}", Auth::id('admin'), $request->ip());
                $this->flash('success', 'Role removed.');
            }

            $this->redirect('/admin/team/members');
        }

        $members = $this->getTeamMembers();

        $this->view('admin/team/members', [
            'title'   => 'Team Members',
            'members' => $members,
            'roles'   => $roles,
            'admin'   => Auth::user('admin'),
        ]);
    }

    private function getTeamMembers(): array
    {
        try {
            $db = \App\Core\Database::getInstance();
            return $db->fetchAll(
                "SELECT u.*, r.label AS role_label, r.name AS role_name
                 FROM users u
                 LEFT JOIN team_roles r ON r.id = u.team_role_id
                 WHERE u.team_role_id IS NOT NULL OR u.role IN ('admin','superadmin')
                 ORDER BY u.created_at DESC"
            );
        } catch (\Throwable $e) {
            return [];
        }
    }
}
