<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\UserModel;
use App\Models\WalletModel;
use App\Models\TransactionModel;

class UsersController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');
        $userModel = new UserModel();
        $page   = (int)($request->get('page', 1));
        $search = trim($request->get('search', ''));

        if ($search) {
            $where  = 'username LIKE ? OR email LIKE ?';
            $params = ["%{$search}%", "%{$search}%"];
        } else {
            $where = '';
            $params = [];
        }

        $data = $userModel->paginate($page, 20, $where, $params);

        $this->view('admin/users/index', [
            'title'  => 'Users Management',
            'data'   => $data,
            'search' => $search,
            'admin'  => Auth::user('admin'),
        ]);
    }

    public function show(Request $request, array $params): void
    {
        $this->requireAuth('admin');
        $userModel    = new UserModel();
        $walletModel  = new WalletModel();
        $transModel   = new TransactionModel();

        $user = $userModel->find((int)$params['id']);
        if (!$user) {
            $this->flash('error', 'User not found.');
            $this->redirect('/admin/users');
        }

        $wallets      = $walletModel->getUserWallets((int)$user['id']);
        $transactions = $transModel->getUserTransactions((int)$user['id'], 20);

        $this->view('admin/users/view', [
            'title'        => 'User: ' . $user['username'],
            'user'         => $user,
            'wallets'      => $wallets,
            'transactions' => $transactions,
            'admin'        => Auth::user('admin'),
        ]);
    }

    public function edit(Request $request, array $params): void
    {
        $this->requireAuth('admin');
        if (!Csrf::validateRequest($request)) {
            $this->flash('error', 'Invalid CSRF token.');
            $this->redirect("/admin/users/{$params['id']}");
        }

        $userModel = new UserModel();
        $user = $userModel->find((int)$params['id']);
        if (!$user) {
            $this->flash('error', 'User not found.');
            $this->redirect('/admin/users');
        }

        $updateData = [];

        $username = trim($request->post('username', ''));
        if ($username !== '' && $username !== $user['username']) {
            // Check uniqueness
            $existing = $userModel->findByUsername($username);
            if ($existing && (int)$existing['id'] !== (int)$user['id']) {
                $this->flash('error', 'Username is already taken.');
                $this->redirect("/admin/users/{$params['id']}");
            }
            $updateData['username'] = $username;
        }

        $email = trim($request->post('email', ''));
        if ($email !== '' && $email !== $user['email']) {
            if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
                $this->flash('error', 'Invalid email address.');
                $this->redirect("/admin/users/{$params['id']}");
            }
            $existing = $userModel->findByEmail($email);
            if ($existing && (int)$existing['id'] !== (int)$user['id']) {
                $this->flash('error', 'Email is already in use.');
                $this->redirect("/admin/users/{$params['id']}");
            }
            $updateData['email'] = $email;
        }

        $phone = trim($request->post('phone', ''));
        if ($phone !== '') {
            $updateData['phone'] = $phone;
        }

        $country = trim($request->post('country', ''));
        if ($country !== '') {
            $updateData['country'] = $country;
        }

        $status = $request->post('status', '');
        if (in_array($status, ['active', 'banned', 'inactive'], true)) {
            $updateData['status'] = $status;
        }

        $newPassword = $request->post('new_password', '');
        if ($newPassword !== '') {
            if (strlen($newPassword) < 8) {
                $this->flash('error', 'New password must be at least 8 characters.');
                $this->redirect("/admin/users/{$params['id']}");
            }
            $updateData['password'] = $userModel->hashPassword($newPassword);
        }

        if (empty($updateData)) {
            $this->flash('info', 'No changes to save.');
            $this->redirect("/admin/users/{$params['id']}");
        }

        $updateData['updated_at'] = date('Y-m-d H:i:s');

        try {
            $userModel->update((int)$user['id'], $updateData);
            (new AuditLog())->log('admin_user_edited', "User #{$user['id']} profile updated by admin", Auth::id('admin'), $request->ip());
            $this->flash('success', 'User profile updated successfully.');
        } catch (\Throwable $e) {
            error_log('UsersController edit error: ' . $e->getMessage());
            $this->flash('error', 'Could not update user. Please try again.');
        }

        $this->redirect("/admin/users/{$params['id']}");
    }

    public function toggleStatus(Request $request, array $params): void
    {
        $this->requireAuth('admin');
        if (!Csrf::validateRequest($request)) {
            $this->flash('error', 'Invalid CSRF token.');
            $this->redirect('/admin/users');
        }

        $userModel = new UserModel();
        $user = $userModel->find((int)$params['id']);
        if ($user) {
            $newStatus = $user['status'] === 'active' ? 'banned' : 'active';
            $userModel->update((int)$user['id'], ['status' => $newStatus]);
            (new AuditLog())->log('user_status_change', "User #{$user['id']} status changed to {$newStatus}", Auth::id('admin'), $request->ip());
            $this->flash('success', "User status updated to {$newStatus}.");
        }
        $this->redirect('/admin/users');
    }

    public function addFunds(Request $request, array $params): void
    {
        $this->requireAuth('admin');
        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect("/admin/users/{$params['id']}/add-funds");
            }
            $amount   = (float)$request->post('amount', 0);
            $currency = strtoupper($request->post('currency', 'USD'));
            $note     = $request->post('note', '');

            if ($amount <= 0) {
                $this->flash('error', 'Invalid amount.');
                $this->redirect("/admin/users/{$params['id']}/add-funds");
            }

            $walletModel = new WalletModel();
            $transModel  = new TransactionModel();
            $walletModel->credit((int)$params['id'], $currency, $amount);
            $transModel->addTransaction((int)$params['id'], 'admin_credit', $amount, $currency, $note ?: 'Admin credit');
            (new AuditLog())->log('add_funds', "Added {$amount} {$currency} to user #{$params['id']}", Auth::id('admin'), $request->ip());
            $this->flash('success', "Funds added successfully.");
            $this->redirect("/admin/users/{$params['id']}");
        }

        $userModel = new UserModel();
        $user = $userModel->find((int)$params['id']);
        $this->view('admin/users/add-funds', [
            'title' => 'Add Funds',
            'user'  => $user,
            'admin' => Auth::user('admin'),
        ]);
    }
}
