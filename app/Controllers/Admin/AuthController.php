<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\UserModel;

class AuthController extends Controller
{
    public function login(Request $request): void
    {
        if (Auth::check('admin')) {
            $this->redirect('/admin/dashboard');
        }

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/admin/login');
            }

            $email    = trim($request->post('email', ''));
            $password = $request->post('password', '');

            $userModel = new UserModel();
            $user = $userModel->findByEmail($email);

            if ($user && in_array($user['role'], ['admin', 'superadmin']) && $userModel->verifyPassword($password, $user['password'])) {
                Auth::login($user, 'admin');
                (new AuditLog())->log('admin_login', 'Admin logged in', (int)$user['id'], $request->ip());
                $this->redirect('/admin/dashboard');
            }

            $this->flash('error', 'Invalid credentials or insufficient privileges.');
            $this->redirect('/admin/login');
        }

        $this->view('admin/auth/login', ['title' => 'Admin Login']);
    }

    public function logout(Request $request): void
    {
        $userId = Auth::id('admin');
        Auth::logout('admin');
        if ($userId) {
            (new AuditLog())->log('admin_logout', 'Admin logged out', $userId, $request->ip());
        }
        $this->redirect('/admin/login');
    }
}
