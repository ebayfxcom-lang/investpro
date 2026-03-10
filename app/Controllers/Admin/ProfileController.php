<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\UserModel;

class ProfileController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');

        $admin = Auth::user('admin');

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/admin/profile');
            }

            $userModel   = new UserModel();
            $newUsername = trim($request->post('username', ''));
            $newEmail    = trim($request->post('email', ''));
            $newPassword = $request->post('password', '');
            $confirmPass = $request->post('confirm_password', '');

            if ($newUsername === '' || $newEmail === '') {
                $this->flash('error', 'Username and email are required.');
                $this->redirect('/admin/profile');
            }

            $data = [
                'username' => $newUsername,
                'email'    => $newEmail,
            ];

            if ($newPassword !== '') {
                if (strlen($newPassword) < 8) {
                    $this->flash('error', 'Password must be at least 8 characters.');
                    $this->redirect('/admin/profile');
                }
                if ($newPassword !== $confirmPass) {
                    $this->flash('error', 'Passwords do not match.');
                    $this->redirect('/admin/profile');
                }
                $data['password'] = password_hash($newPassword, PASSWORD_DEFAULT);
            }

            $userModel->update((int)$admin['id'], $data);
            (new AuditLog())->log('profile_updated', 'Admin profile updated', Auth::id('admin'), $request->ip());
            $this->flash('success', 'Profile updated successfully.');
            $this->redirect('/admin/profile');
        }

        $this->view('admin/profile/index', [
            'title' => 'Admin Profile',
            'admin' => $admin,
        ]);
    }
}
