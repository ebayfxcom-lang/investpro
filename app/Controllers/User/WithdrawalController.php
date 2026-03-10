<?php
declare(strict_types=1);

namespace App\Controllers\User;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\WithdrawalModel;
use App\Models\WalletModel;
use App\Models\TransactionModel;
use App\Models\SettingsModel;

class WithdrawalController extends Controller
{
    public function create(Request $request): void
    {
        $this->requireAuth('user');
        $authUser = Auth::user('user');
        $userId   = (int)$authUser['id'];

        $walletModel   = new WalletModel();
        $settingsModel = new SettingsModel();
        $wallets = $walletModel->getUserWallets($userId);

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/user/withdraw');
            }

            $amount   = (float)$request->post('amount', 0);
            $currency = strtoupper($request->post('currency', 'USD'));
            $address  = trim($request->post('address', ''));
            $method   = $request->post('method', 'bank');

            $minWithdraw = (float)($settingsModel->get('min_withdrawal', 10));
            $maxWithdraw = (float)($settingsModel->get('max_withdrawal', 100000));

            if ($amount < $minWithdraw || $amount > $maxWithdraw) {
                $this->flash('error', "Withdrawal amount must be between {$minWithdraw} and {$maxWithdraw}.");
                $this->redirect('/user/withdraw');
            }
            if (empty($address)) {
                $this->flash('error', 'Withdrawal address/account is required.');
                $this->redirect('/user/withdraw');
            }

            $balance = $walletModel->getBalance($userId, $currency);
            if ($balance < $amount) {
                $this->flash('error', 'Insufficient balance.');
                $this->redirect('/user/withdraw');
            }

            $walletModel->debit($userId, $currency, $amount);

            $withdrawalModel = new WithdrawalModel();
            $wId = $withdrawalModel->create([
                'user_id'    => $userId,
                'amount'     => $amount,
                'currency'   => $currency,
                'method'     => $method,
                'address'    => $address,
                'status'     => 'pending',
                'created_at' => date('Y-m-d H:i:s'),
            ]);

            $transModel = new TransactionModel();
            $transModel->addTransaction($userId, 'withdrawal', $amount, $currency, 'Withdrawal request', 'pending', (int)$wId);

            (new AuditLog())->log('withdrawal_requested', "Withdrawal of {$amount} {$currency} requested", $userId, $request->ip());
            $this->flash('success', 'Withdrawal request submitted. Pending admin approval.');
            $this->redirect('/user/withdrawals');
        }

        $this->view('user/withdrawal/create', [
            'title'   => 'Withdraw Funds',
            'wallets' => $wallets,
        ]);
    }

    public function history(Request $request): void
    {
        $this->requireAuth('user');
        $userId = (int)Auth::id('user');
        $withdrawalModel = new WithdrawalModel();
        $withdrawals = $withdrawalModel->getUserWithdrawals($userId);
        $this->view('user/withdrawal/history', [
            'title'       => 'Withdrawal History',
            'withdrawals' => $withdrawals,
        ]);
    }
}
