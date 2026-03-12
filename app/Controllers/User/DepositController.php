<?php
declare(strict_types=1);

namespace App\Controllers\User;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\PlanModel;
use App\Models\DepositModel;
use App\Models\TransactionModel;
use App\Models\DepositWalletModel;
use App\Services\ConversionService;

class DepositController extends Controller
{
    public function create(Request $request): void
    {
        $this->requireAuth('user');
        $planModel         = new PlanModel();
        $depositWalletModel = new DepositWalletModel();
        $plans             = $planModel->getActivePlans();
        $systemWallets     = $depositWalletModel->getActiveWallets();

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/user/deposit');
            }

            $authUser = Auth::user('user');
            $userId   = (int)$authUser['id'];
            $planId   = (int)$request->post('plan_id', 0);
            $amount   = (float)$request->post('amount', 0);
            $currency = strtoupper($request->post('currency', 'BTC'));

            $plan = $planModel->find($planId);
            if (!$plan || $plan['status'] !== 'active') {
                $this->flash('error', 'Invalid plan selected.');
                $this->redirect('/user/deposit');
            }
            if ($amount <= 0 || ($amount < (float)$plan['min_amount']) || ($plan['max_amount'] > 0 && $amount > (float)$plan['max_amount'])) {
                $this->flash('error', 'Amount is outside plan limits.');
                $this->redirect('/user/deposit');
            }

            // Store deposit intent in session and redirect to payment page
            $this->session->set('deposit_intent', [
                'plan_id'  => $planId,
                'amount'   => $amount,
                'currency' => $currency,
            ]);

            $this->redirect('/user/deposit/pay');
        }

        $this->view('user/deposit/create', [
            'title'         => 'Make a Deposit',
            'plans'         => $plans,
            'system_wallets' => $systemWallets,
        ]);
    }

    public function pay(Request $request): void
    {
        $this->requireAuth('user');

        $intent = $this->session->get('deposit_intent');
        if (!$intent) {
            $this->flash('error', 'Please select a plan and amount first.');
            $this->redirect('/user/deposit');
        }

        $planModel          = new PlanModel();
        $depositWalletModel = new DepositWalletModel();
        $plan               = $planModel->find((int)$intent['plan_id']);

        if (!$plan || $plan['status'] !== 'active') {
            $this->session->remove('deposit_intent');
            $this->flash('error', 'Selected plan is no longer available.');
            $this->redirect('/user/deposit');
        }

        $currency     = (string)$intent['currency'];
        $systemWallet = $depositWalletModel->getWalletByCurrency($currency);

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/user/deposit/pay');
            }

            $txHash = trim($request->post('tx_hash', ''));
            if ($txHash === '') {
                $this->flash('error', 'Please enter your transaction hash / ID.');
                $this->redirect('/user/deposit/pay');
            }

            $authUser = Auth::user('user');
            $userId   = (int)$authUser['id'];
            $amount   = (float)$intent['amount'];

            // Build conversion snapshot
            $conversionService = new ConversionService();
            $snapshot          = $conversionService->buildSnapshot($amount, $currency);

            $depositModel = new DepositModel();
            $depositId    = $depositModel->create([
                'user_id'        => $userId,
                'plan_id'        => (int)$intent['plan_id'],
                'amount'         => $amount,
                'currency'       => $currency,
                'status'         => 'pending',
                'tx_hash'        => $txHash,
                'created_at'     => date('Y-m-d H:i:s'),
                'usd_amount'     => $snapshot['usd_amount'],
                'eur_amount'     => $snapshot['eur_amount'],
                'rate_snapshot'  => $snapshot['rate_snapshot'],
            ]);

            $transModel = new TransactionModel();
            $transModel->addTransaction($userId, 'deposit', $amount, $currency, "Deposit - {$plan['name']} (pending)", 'pending', (int)$depositId);

            (new AuditLog())->log('deposit_submitted', "User #{$userId} submitted deposit of {$amount} {$currency} on plan {$plan['name']}", $userId, $request->ip());

            $this->session->remove('deposit_intent');
            $this->flash('success', 'Deposit submitted! It will be activated once your transaction is confirmed by an admin.');
            $this->redirect('/user/deposits/history');
        }

        $this->view('user/deposit/pay', [
            'title'         => 'Send Payment',
            'plan'          => $plan,
            'intent'        => $intent,
            'system_wallet' => $systemWallet,
        ]);
    }

    public function active(Request $request): void
    {
        $this->requireAuth('user');
        $userId       = (int)Auth::id('user');
        $depositModel = new DepositModel();
        $deposits     = $depositModel->getActiveDeposits($userId);
        $this->view('user/deposit/active', [
            'title'    => 'Active Deposits',
            'deposits' => $deposits,
        ]);
    }

    public function history(Request $request): void
    {
        $this->requireAuth('user');
        $userId       = (int)Auth::id('user');
        $depositModel = new DepositModel();
        $deposits     = $depositModel->getUserDeposits($userId);
        $this->view('user/deposit/history', [
            'title'    => 'Deposit History',
            'deposits' => $deposits,
        ]);
    }
}
