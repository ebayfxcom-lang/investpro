<?php
declare(strict_types=1);

namespace App\Controllers\User;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\WithdrawalModel;
use App\Models\WithdrawalMethodModel;
use App\Models\WalletModel;
use App\Models\TransactionModel;
use App\Models\SettingsModel;
use App\Services\ConversionService;

class WithdrawalController extends Controller
{
    public function create(Request $request): void
    {
        $this->requireAuth('user');
        $authUser = Auth::user('user');
        $userId   = (int)$authUser['id'];

        $walletModel   = new WalletModel();
        $settingsModel = new SettingsModel();
        $methodModel   = new WithdrawalMethodModel();
        $wallets       = $walletModel->getUserWallets($userId);
        $methods       = $methodModel->getActiveMethods();

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/user/withdraw');
            }

            $methodId = (int)$request->post('method_id', 0);
            $amount   = (float)$request->post('amount', 0);
            $address  = trim($request->post('address', ''));
            $memo     = trim($request->post('memo', ''));

            // Validate method
            $method = $methodModel->find($methodId);
            if (!$method || $method['status'] !== 'active') {
                $this->flash('error', 'Invalid withdrawal method selected.');
                $this->redirect('/user/withdraw');
            }

            $currency  = $method['currency'];
            $network   = $method['network'];
            $minAmount = (float)$method['min_amount'];

            $minWithdraw = max($minAmount, (float)($settingsModel->get('min_withdrawal', 10)));
            $maxWithdraw = (float)($settingsModel->get('max_withdrawal', 100000));

            if ($amount < $minWithdraw) {
                $this->flash('error', "Minimum withdrawal for this method is {$minWithdraw} {$currency}.");
                $this->redirect('/user/withdraw');
            }
            if ($maxWithdraw > 0 && $amount > $maxWithdraw) {
                $this->flash('error', "Maximum withdrawal is {$maxWithdraw}.");
                $this->redirect('/user/withdraw');
            }
            if (empty($address)) {
                $this->flash('error', 'Withdrawal address is required.');
                $this->redirect('/user/withdraw');
            }

            // Validate address format if regex provided
            if (!empty($method['address_regex']) && !preg_match('/' . $method['address_regex'] . '/', $address)) {
                $this->flash('error', 'Invalid withdrawal address format for the selected network.');
                $this->redirect('/user/withdraw');
            }

            $balance = $walletModel->getBalance($userId, $currency);
            if ($balance < $amount) {
                $this->flash('error', "Insufficient {$currency} balance. Available: {$balance}");
                $this->redirect('/user/withdraw');
            }

            // Calculate fee and actual crypto amount
            $fee       = (float)$method['fee'];
            $feeAmount = $fee + ($amount * (float)$method['fee_percent'] / 100);
            $netAmount = $amount - $feeAmount;

            $walletModel->debit($userId, $currency, $amount);

            // Build conversion snapshot
            $conversionService = new ConversionService();
            $snapshot = $conversionService->buildSnapshot($amount, $currency);

            $withdrawalModel = new WithdrawalModel();
            $wId = $withdrawalModel->create([
                'user_id'             => $userId,
                'amount'              => $amount,
                'fee'                 => $feeAmount,
                'currency'            => $currency,
                'network'             => $network,
                'method'              => $method['name'],
                'address'             => $address,
                'memo'                => $memo ?: null,
                'actual_crypto_amount'=> $netAmount,
                'status'              => 'pending',
                'created_at'          => date('Y-m-d H:i:s'),
                'usd_amount'          => $snapshot['usd_amount'],
                'eur_amount'          => $snapshot['eur_amount'],
                'rate_snapshot'       => $snapshot['rate_snapshot'],
            ]);

            $transModel = new TransactionModel();
            $transModel->addTransaction($userId, 'withdrawal', $amount, $currency, 'Withdrawal request', 'pending', (int)$wId);

            (new AuditLog())->log('withdrawal_requested', "Withdrawal of {$amount} {$currency} via {$method['name']} requested", $userId, $request->ip());
            $this->flash('success', 'Withdrawal request submitted. Pending admin approval.');
            $this->redirect('/user/withdrawals');
        }

        $this->view('user/withdrawal/create', [
            'title'   => 'Withdraw Funds',
            'wallets' => $wallets,
            'methods' => $methods,
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
