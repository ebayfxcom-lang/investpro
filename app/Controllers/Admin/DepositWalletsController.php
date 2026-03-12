<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\DepositWalletModel;

class DepositWalletsController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');
        $model   = new DepositWalletModel();
        $wallets = $model->findAll('', [], 'currency_code ASC, network ASC');

        $this->view('admin/deposit-wallets/index', [
            'title'   => 'System Deposit Wallets',
            'wallets' => $wallets,
            'admin'   => Auth::user('admin'),
        ]);
    }

    public function create(Request $request): void
    {
        $this->requireAuth('admin');

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/admin/deposit-wallets/create');
            }

            $currencyCode   = strtoupper(trim($request->post('currency_code', '')));
            $network        = trim($request->post('network', ''));
            $walletAddress  = trim($request->post('wallet_address', ''));
            $memo           = trim($request->post('memo', ''));
            $instructions   = trim($request->post('instructions', ''));
            $minDeposit     = (float)$request->post('min_deposit', 0);
            $confirmations  = max(1, (int)$request->post('confirmations', 3));
            $status         = $request->post('status', 'active') === 'active' ? 'active' : 'inactive';

            if (!$currencyCode || !$walletAddress) {
                $this->flash('error', 'Currency code and wallet address are required.');
                $this->redirect('/admin/deposit-wallets/create');
            }

            $model = new DepositWalletModel();
            $model->create([
                'currency_code'  => $currencyCode,
                'network'        => $network,
                'wallet_address' => $walletAddress,
                'memo'           => $memo ?: null,
                'instructions'   => $instructions ?: null,
                'min_deposit'    => $minDeposit,
                'confirmations'  => $confirmations,
                'status'         => $status,
                'created_at'     => date('Y-m-d H:i:s'),
            ]);
            (new AuditLog())->log('deposit_wallet_created', "Deposit wallet {$currencyCode}/{$network} created", Auth::id('admin'), $request->ip());
            $this->flash('success', 'Deposit wallet created successfully.');
            $this->redirect('/admin/deposit-wallets');
        }

        $this->view('admin/deposit-wallets/form', [
            'title'  => 'Add Deposit Wallet',
            'wallet' => null,
            'admin'  => Auth::user('admin'),
        ]);
    }

    public function edit(Request $request, array $params): void
    {
        $this->requireAuth('admin');
        $model  = new DepositWalletModel();
        $wallet = $model->find((int)$params['id']);
        if (!$wallet) {
            $this->flash('error', 'Wallet not found.');
            $this->redirect('/admin/deposit-wallets');
        }

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect("/admin/deposit-wallets/{$params['id']}/edit");
            }

            $currencyCode   = strtoupper(trim($request->post('currency_code', '')));
            $network        = trim($request->post('network', ''));
            $walletAddress  = trim($request->post('wallet_address', ''));
            $memo           = trim($request->post('memo', ''));
            $instructions   = trim($request->post('instructions', ''));
            $minDeposit     = (float)$request->post('min_deposit', 0);
            $confirmations  = max(1, (int)$request->post('confirmations', 3));
            $status         = $request->post('status', 'active') === 'active' ? 'active' : 'inactive';

            if (!$currencyCode || !$walletAddress) {
                $this->flash('error', 'Currency code and wallet address are required.');
                $this->redirect("/admin/deposit-wallets/{$params['id']}/edit");
            }

            $model->update((int)$params['id'], [
                'currency_code'  => $currencyCode,
                'network'        => $network,
                'wallet_address' => $walletAddress,
                'memo'           => $memo ?: null,
                'instructions'   => $instructions ?: null,
                'min_deposit'    => $minDeposit,
                'confirmations'  => $confirmations,
                'status'         => $status,
                'updated_at'     => date('Y-m-d H:i:s'),
            ]);
            (new AuditLog())->log('deposit_wallet_updated', "Deposit wallet #{$params['id']} updated", Auth::id('admin'), $request->ip());
            $this->flash('success', 'Deposit wallet updated.');
            $this->redirect('/admin/deposit-wallets');
        }

        $this->view('admin/deposit-wallets/form', [
            'title'  => 'Edit Deposit Wallet',
            'wallet' => $wallet,
            'admin'  => Auth::user('admin'),
        ]);
    }

    public function delete(Request $request, array $params): void
    {
        $this->requireAuth('admin');
        if (!Csrf::validateRequest($request)) {
            $this->flash('error', 'Invalid CSRF token.');
            $this->redirect('/admin/deposit-wallets');
        }
        $model = new DepositWalletModel();
        $model->delete((int)$params['id']);
        (new AuditLog())->log('deposit_wallet_deleted', "Deposit wallet #{$params['id']} deleted", Auth::id('admin'), $request->ip());
        $this->flash('success', 'Deposit wallet deleted.');
        $this->redirect('/admin/deposit-wallets');
    }
}
