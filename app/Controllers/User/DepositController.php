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
use App\Models\WalletModel;
use App\Models\TransactionModel;
use App\Services\ConversionService;

class DepositController extends Controller
{
    public function create(Request $request): void
    {
        $this->requireAuth('user');
        $planModel = new PlanModel();
        $plans = $planModel->getActivePlans();

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/user/deposit');
            }

            $authUser  = Auth::user('user');
            $userId    = (int)$authUser['id'];
            $planId    = (int)$request->post('plan_id', 0);
            $amount    = (float)$request->post('amount', 0);
            $currency  = strtoupper($request->post('currency', 'USD'));

            $plan = $planModel->find($planId);
            if (!$plan || $plan['status'] !== 'active') {
                $this->flash('error', 'Invalid plan selected.');
                $this->redirect('/user/deposit');
            }
            if ($amount < (float)$plan['min_amount'] || ($plan['max_amount'] > 0 && $amount > (float)$plan['max_amount'])) {
                $this->flash('error', 'Amount is outside plan limits.');
                $this->redirect('/user/deposit');
            }

            $walletModel = new WalletModel();
            $balance = $walletModel->getBalance($userId, $currency);
            if ($balance < $amount) {
                $this->flash('error', 'Insufficient balance.');
                $this->redirect('/user/deposit');
            }

            $walletModel->debit($userId, $currency, $amount);

            // Build conversion snapshot
            $conversionService = new ConversionService();
            $snapshot = $conversionService->buildSnapshot($amount, $currency);

            // Calculate expiry based on flexible duration_value + duration_unit.
            // When duration_value is not set, fall back to duration_days with unit 'day'.
            $durationValue = (int)($plan['duration_value'] ?? 0);
            $durationUnit  = $plan['duration_unit'] ?? 'day';
            if ($durationValue <= 0) {
                // Legacy fallback: always treat duration_days as days
                $durationValue = (int)($plan['duration_days'] ?? 30);
                $durationUnit  = 'day';
            }
            // Normalise unit to PHP date modifier
            $unitMap = [
                'hour'  => 'hour',
                'day'   => 'day',
                'week'  => 'week',
                'month' => 'month',
                'year'  => 'year',
            ];
            $phpUnit   = $unitMap[$durationUnit] ?? 'day';
            $expiresAt = date('Y-m-d H:i:s', strtotime("+{$durationValue} {$phpUnit}"));

            $depositModel = new DepositModel();
            $depositId = $depositModel->create([
                'user_id'       => $userId,
                'plan_id'       => $planId,
                'amount'        => $amount,
                'currency'      => $currency,
                'status'        => 'active',
                'expires_at'    => $expiresAt,
                'created_at'    => date('Y-m-d H:i:s'),
                'usd_amount'    => $snapshot['usd_amount'],
                'eur_amount'    => $snapshot['eur_amount'],
                'rate_snapshot' => $snapshot['rate_snapshot'],
            ]);

            $transModel = new TransactionModel();
            $transModel->addTransaction($userId, 'deposit', $amount, $currency, "Deposit - {$plan['name']}", 'completed', (int)$depositId);

            (new AuditLog())->log('deposit_created', "New deposit of {$amount} {$currency} on plan {$plan['name']}", $userId, $request->ip());
            $this->flash('success', 'Deposit successful! Your investment is now active.');
            $this->redirect('/user/deposits/active');
        }

        $this->view('user/deposit/create', [
            'title' => 'Make a Deposit',
            'plans' => $plans,
        ]);
    }

    public function active(Request $request): void
    {
        $this->requireAuth('user');
        $userId = (int)Auth::id('user');
        $depositModel = new DepositModel();
        $deposits = $depositModel->getActiveDeposits($userId);
        $this->view('user/deposit/active', [
            'title'    => 'Active Deposits',
            'deposits' => $deposits,
        ]);
    }

    public function history(Request $request): void
    {
        $this->requireAuth('user');
        $userId = (int)Auth::id('user');
        $depositModel = new DepositModel();
        $deposits = $depositModel->getUserDeposits($userId);
        $this->view('user/deposit/history', [
            'title'    => 'Deposit History',
            'deposits' => $deposits,
        ]);
    }
}
