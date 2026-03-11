<?php
declare(strict_types=1);

namespace App\Controllers\User;

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
        if (Auth::check('user')) {
            $this->redirect('/user/dashboard');
        }

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/login');
            }

            $email    = trim($request->post('email', ''));
            $password = $request->post('password', '');

            $userModel = new UserModel();
            $user = $userModel->findByEmail($email);

            if ($user && $userModel->verifyPassword($password, $user['password'])) {
                if ($user['status'] === 'banned') {
                    $this->flash('error', 'Your account has been suspended.');
                    $this->redirect('/login');
                }
                Auth::login($user, 'user');
                // Grant daily free spins
                try {
                    (new \App\Services\SpinService())->grantDailyFreeSpins((int)$user['id']);
                } catch (\Throwable $e) {
                    // Non-critical, log and continue
                    error_log('SpinService::grantDailyFreeSpins failed: ' . $e->getMessage());
                }
                (new AuditLog())->log('user_login', 'User logged in', (int)$user['id'], $request->ip());
                $this->redirect('/user/dashboard');
            }

            $this->flash('error', 'Invalid email or password.');
            $this->redirect('/login');
        }

        $this->view('auth/login', ['title' => 'Login']);
    }

    public function register(Request $request): void
    {
        if (Auth::check('user')) {
            $this->redirect('/user/dashboard');
        }

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/register');
            }

            $username           = trim($request->post('username', ''));
            $email              = trim($request->post('email', ''));
            $password           = $request->post('password', '');
            $confirm            = $request->post('password_confirm', '');
            $refCode            = trim($request->post('ref', ''));
            $whatsapp           = trim($request->post('whatsapp_number', ''));
            $facebook           = trim($request->post('facebook_url', ''));
            $country            = trim($request->post('country', ''));
            $preferred_currency = strtoupper(trim($request->post('preferred_currency', 'USD')));

            $userModel = new UserModel();

            if (strlen($password) < 8) {
                $this->flash('error', 'Password must be at least 8 characters.');
                $this->redirect('/register');
            }
            if ($password !== $confirm) {
                $this->flash('error', 'Passwords do not match.');
                $this->redirect('/register');
            }
            if (empty($whatsapp) || !preg_match('/^\+?[\d\s\-\(\)]{7,20}$/', $whatsapp)) {
                $this->flash('error', 'WhatsApp number is required and must be 7–20 characters (digits, spaces, +, -, (, ) only).');
                $this->redirect('/register');
            }
            if ($userModel->findByEmail($email)) {
                $this->flash('error', 'Email already registered.');
                $this->redirect('/register');
            }
            if ($userModel->findByUsername($username)) {
                $this->flash('error', 'Username already taken.');
                $this->redirect('/register');
            }

            $referredBy = null;
            if ($refCode) {
                $referrer = $userModel->findByReferralCode($refCode);
                $referredBy = $referrer ? $referrer['id'] : null;
            }

            $id = $userModel->create([
                'username'           => $username,
                'email'              => $email,
                'password'           => $userModel->hashPassword($password),
                'referral_code'      => $userModel->generateReferralCode(),
                'referred_by'        => $referredBy,
                'role'               => 'user',
                'status'             => 'active',
                'whatsapp_number'    => $whatsapp,
                'facebook_url'       => $facebook ?: null,
                'country'            => $country ?: null,
                'preferred_currency' => in_array($preferred_currency, ['USD', 'EUR', 'BTC', 'ETH', 'USDT']) ? $preferred_currency : 'USD',
                'created_at'         => date('Y-m-d H:i:s'),
            ]);

            $user = $userModel->find((int)$id);
            Auth::login($user, 'user');
            (new AuditLog())->log('user_register', 'New user registered', (int)$id, $request->ip());
            $this->flash('success', 'Welcome to InvestPro! Your account has been created.');
            $this->redirect('/user/dashboard');
        }

        $this->view('auth/register', [
            'title' => 'Register',
            'ref'   => $request->get('ref', ''),
        ]);
    }

    public function logout(Request $request): void
    {
        $userId = Auth::id('user');
        Auth::logout('user');
        if ($userId) {
            (new AuditLog())->log('user_logout', 'User logged out', $userId, $request->ip());
        }
        $this->redirect('/login');
    }
}
