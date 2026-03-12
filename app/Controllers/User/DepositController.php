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
        $planModel          = new PlanModel();
        $depositWalletModel = new DepositWalletModel();
        $plans              = $planModel->getActivePlans();
        $systemWallets      = $depositWalletModel->getActiveWallets();

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
            $network  = strtoupper($request->post('network', ''));

            $plan = $planModel->find($planId);
            if (!$plan || $plan['status'] !== 'active') {
                $this->flash('error', 'Invalid plan selected.');
                $this->redirect('/user/deposit');
            }
            if ($amount <= 0 || ($amount < (float)$plan['min_amount']) || ($plan['max_amount'] > 0 && $amount > (float)$plan['max_amount'])) {
                $this->flash('error', 'Amount is outside plan limits.');
                $this->redirect('/user/deposit');
            }

            // Find suitable wallet address for the selected currency + network
            $wallet = $depositWalletModel->getWalletByCurrency($currency, $network);
            if (!$wallet) {
                $wallet = $depositWalletModel->getWalletByCurrency($currency);
            }

            // Calculate actual crypto amount
            $conversionService  = new ConversionService();
            $actualCryptoAmount = $conversionService->convert($amount, $plan['currency'] ?? 'USD', $currency);
            $snapshot           = $conversionService->buildSnapshot($amount, $plan['currency'] ?? 'USD');

            // Store deposit intent in session and redirect to payment page
            $this->session->set('deposit_intent', [
                'plan_id'             => $planId,
                'amount'              => $amount,
                'currency'            => $currency,
                'network'             => $network ?: ($wallet['network'] ?? ''),
                'actual_crypto_amount'=> round($actualCryptoAmount, 8),
                'rate_snapshot'       => $snapshot['rate_snapshot'],
                'usd_amount'          => $snapshot['usd_amount'],
                'eur_amount'          => $snapshot['eur_amount'],
                'wallet_address'      => $wallet['wallet_address'] ?? null,
                'memo'                => $wallet['memo'] ?? null,
                'confirmations'       => $wallet['confirmations'] ?? 3,
                'wallet_id'           => $wallet['id'] ?? null,
            ]);

            $this->redirect('/user/deposit/pay');
        }

        $this->view('user/deposit/create', [
            'title'          => 'Make a Deposit',
            'plans'          => $plans,
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
        $network      = (string)($intent['network'] ?? '');
        $systemWallet = $depositWalletModel->getWalletByCurrency($currency, $network);
        if (!$systemWallet && $network) {
            $systemWallet = $depositWalletModel->getWalletByCurrency($currency);
        }

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

            $depositModel = new DepositModel();
            $depositId    = $depositModel->create([
                'user_id'             => $userId,
                'plan_id'             => (int)$intent['plan_id'],
                'amount'              => $amount,
                'currency'            => $currency,
                'network'             => $network,
                'deposit_address'     => $systemWallet['wallet_address'] ?? null,
                'actual_crypto_amount'=> $intent['actual_crypto_amount'] ?? null,
                'fiat_amount'         => $amount,
                'memo'                => $systemWallet['memo'] ?? null,
                'status'              => 'pending',
                'tx_hash'             => $txHash,
                'created_at'          => date('Y-m-d H:i:s'),
                'usd_amount'          => $intent['usd_amount'] ?? null,
                'eur_amount'          => $intent['eur_amount'] ?? null,
                'rate_snapshot'       => $intent['rate_snapshot'] ?? null,
            ]);

            $transModel = new TransactionModel();
            $transModel->addTransaction($userId, 'deposit', $amount, $currency, "Deposit - {$plan['name']} (pending)", 'pending', (int)$depositId);

            (new AuditLog())->log('deposit_submitted', "User #{$userId} submitted deposit of {$amount} {$currency} on plan {$plan['name']}", $userId, $request->ip());

            $this->session->remove('deposit_intent');
            $this->flash('success', 'Deposit submitted! It will be activated once your transaction is confirmed.');
            $this->redirect('/user/deposits/history');
        }

        // Build QR code for wallet address
        $walletAddress = $systemWallet['wallet_address'] ?? ($intent['wallet_address'] ?? null);
        $cryptoAmount  = $intent['actual_crypto_amount'] ?? null;
        $memo          = $systemWallet['memo'] ?? ($intent['memo'] ?? null);
        $qrData        = $walletAddress;
        if ($walletAddress && $cryptoAmount) {
            // Payment URI format where supported
            $qrData = $this->buildPaymentUri($currency, $walletAddress, $cryptoAmount, $memo);
        }
        $qrCodeUrl = $walletAddress ? $this->buildQrCodeUrl($qrData) : null;

        $this->view('user/deposit/pay', [
            'title'          => 'Send Payment',
            'plan'           => $plan,
            'intent'         => $intent,
            'system_wallet'  => $systemWallet,
            'qr_code_url'    => $qrCodeUrl,
            'wallet_address' => $walletAddress,
            'crypto_amount'  => $cryptoAmount,
            'memo'           => $memo,
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

    private function buildPaymentUri(string $currency, string $address, float $amount, ?string $memo): string
    {
        $uri = match (strtoupper($currency)) {
            'BTC'  => "bitcoin:{$address}?amount=" . number_format($amount, 8, '.', ''),
            'ETH'  => "ethereum:{$address}?value=" . number_format($amount, 8, '.', ''),
            'LTC'  => "litecoin:{$address}?amount=" . number_format($amount, 8, '.', ''),
            default => $address,
        };
        if ($memo && !in_array(strtoupper($currency), ['BTC', 'ETH', 'LTC'], true)) {
            // For currencies that use memo/tag, just return the address for QR
            return $address;
        }
        return $uri;
    }

    private function buildQrCodeUrl(string $data): string
    {
        // Return the raw data; QR rendering is done client-side
        return $data;
    }
}
