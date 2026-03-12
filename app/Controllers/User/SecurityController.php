<?php
declare(strict_types=1);

namespace App\Controllers\User;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\UserModel;
use App\Services\TotpService;

class SecurityController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('user');

        $userId    = (int)Auth::id('user');
        $userModel = new UserModel();
        $user      = $userModel->find($userId);
        $totp      = new TotpService();

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/user/security');
            }

            $action = $request->post('action', '');

            // ── Change password ──────────────────────────────────────────
            if ($action === 'change_password' || $action === '') {
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

            // ── Start 2FA setup ──────────────────────────────────────────
            if ($action === 'setup_2fa') {
                $secret      = $totp->generateSecret();
                $backupCodes = $totp->generateBackupCodes(8);
                $this->session->set('totp_pending_secret', $secret);
                $this->session->set('totp_pending_backup', $backupCodes);
                $this->redirect('/user/security');
            }

            // ── Cancel 2FA setup ─────────────────────────────────────────
            if ($action === 'cancel_2fa') {
                $this->session->remove('totp_pending_secret');
                $this->session->remove('totp_pending_backup');
                $this->redirect('/user/security');
            }

            // ── Confirm & enable 2FA ─────────────────────────────────────
            if ($action === 'confirm_2fa') {
                $pendingSecret = $this->session->get('totp_pending_secret');
                if (!$pendingSecret) {
                    $this->flash('error', 'Setup session expired. Please start again.');
                    $this->redirect('/user/security');
                }
                $code = trim($request->post('totp_code', ''));
                if (!$totp->verify($pendingSecret, $code)) {
                    $this->flash('error', 'Invalid authenticator code. Please try again.');
                    $this->redirect('/user/security');
                }
                $backupCodes  = $this->session->get('totp_pending_backup', []);
                $hashedBackup = $totp->hashBackupCodes($backupCodes);
                $userModel->update($userId, [
                    'two_factor'             => 1,
                    'two_factor_secret'      => $pendingSecret,
                    'two_factor_backup_codes'=> json_encode($hashedBackup),
                    'two_factor_confirmed_at'=> date('Y-m-d H:i:s'),
                ]);
                $this->session->remove('totp_pending_secret');
                $this->session->remove('totp_pending_backup');
                (new AuditLog())->log('2fa_enabled', 'User enabled 2FA', $userId, $request->ip());
                $this->flash('success', '2FA enabled successfully. Keep your backup codes safe!');
                $this->redirect('/user/security');
            }

            // ── Disable 2FA ──────────────────────────────────────────────
            if ($action === 'disable_2fa') {
                $password = $request->post('password', '');
                $code     = trim($request->post('totp_code', ''));
                if (!$userModel->verifyPassword($password, $user['password'])) {
                    $this->flash('error', 'Incorrect password.');
                    $this->redirect('/user/security');
                }
                if (!$totp->verify((string)$user['two_factor_secret'], $code)) {
                    $this->flash('error', 'Invalid authenticator code.');
                    $this->redirect('/user/security');
                }
                $userModel->update($userId, [
                    'two_factor'              => 0,
                    'two_factor_secret'       => null,
                    'two_factor_backup_codes' => null,
                    'two_factor_confirmed_at' => null,
                ]);
                (new AuditLog())->log('2fa_disabled', 'User disabled 2FA', $userId, $request->ip());
                $this->flash('success', '2FA has been disabled.');
                $this->redirect('/user/security');
            }
        }

        // Build view data
        $pendingSecret = $this->session->get('totp_pending_secret');
        $pendingBackup = $this->session->get('totp_pending_backup', []);
        $totpSetup     = false;
        $totpQrUrl     = null;

        if ($pendingSecret) {
            $totpSetup = true;
            $appConfig = require dirname(__DIR__, 3) . '/config/app.php';
            $issuer    = $appConfig['name'] ?? 'InvestPro';
            $uri       = $totp->getProvisioningUri($pendingSecret, (string)$user['email'], $issuer);
            $totpQrUrl = $totp->getQrCodeUrl($uri);
        }

        $this->view('user/security', [
            'title'          => 'Security Settings',
            'user_2fa_enabled' => (bool)($user['two_factor'] ?? false),
            'totp_setup'     => $totpSetup,
            'totp_secret'    => $pendingSecret,
            'totp_qr_url'    => $totpQrUrl,
            'backup_codes'   => $pendingBackup,
            'user'           => $user,
        ]);
    }
}
