<?php
declare(strict_types=1);

namespace App\Controllers\User;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\UserModel;

class SecurityController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('user');

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/user/security');
            }

            $userId      = (int)Auth::id('user');
            $userModel   = new UserModel();
            $user        = $userModel->find($userId);
            $currentPass = $request->post('current_password', '');
            $newPass     = $request->post('new_password', '');
            $confirmPass = $request->post('confirm_password', '');

            if (!$userModel->verifyPassword($currentPass, $user['password'])) {
                $this->flash('error', 'Current password is incorrect.');
                $this->redirect('/user/security');
            }
            if (strlen($newPass) < 8) {
                $this->flash('error', 'New password must be at least 8 characters.');
                $this->redirect('/user/security');
            }
            if ($newPass !== $confirmPass) {
                $this->flash('error', 'Passwords do not match.');
                $this->redirect('/user/security');
            }

            $userModel->update($userId, ['password' => $userModel->hashPassword($newPass)]);
            (new AuditLog())->log('password_changed', 'User changed password', $userId, $request->ip());
            $this->flash('success', 'Password changed successfully.');
            $this->redirect('/user/security');
        }

        $this->view('user/security', ['title' => 'Security Settings']);
    }
}
