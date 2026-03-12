<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\DepositModel;
use App\Models\PlanModel;
use App\Models\TransactionModel;

class DepositsController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');
        $depositModel = new DepositModel();
        $page   = (int)($request->get('page', 1));
        $status = $request->get('status', '');

        $where  = $status ? 'd.status = ?' : '';
        $params = $status ? [$status] : [];

        $data = $depositModel->paginateWithUsers($page, 20, $where, $params);

        $this->view('admin/deposits/index', [
            'title'  => 'Deposits',
            'data'   => $data,
            'status' => $status,
            'admin'  => Auth::user('admin'),
        ]);
    }

    public function expiring(Request $request): void
    {
        $this->requireAuth('admin');
        $depositModel = new DepositModel();
        $expiring = $depositModel->getExpiringDeposits(7);
        $this->view('admin/deposits/expiring', [
            'title'    => 'Expiring Deposits',
            'deposits' => $expiring,
            'admin'    => Auth::user('admin'),
        ]);
    }

    public function approve(Request $request, array $params): void
    {
        $this->requireAuth('admin');
        if (!Csrf::validateRequest($request)) {
            $this->flash('error', 'Invalid CSRF token.');
            $this->redirect('/admin/deposits');
        }
        $depositModel = new DepositModel();
        $deposit = $depositModel->find((int)$params['id']);
        if (!$deposit) {
            $this->flash('error', 'Deposit not found.');
            $this->redirect('/admin/deposits');
        }

        // Calculate expiry from plan duration
        $planModel     = new PlanModel();
        $plan          = $planModel->find((int)$deposit['plan_id']);
        $durationValue = (int)($plan['duration_value'] ?? 0);
        $durationUnit  = $plan['duration_unit'] ?? 'day';
        if ($durationValue <= 0) {
            $durationValue = (int)($plan['duration_days'] ?? 30);
            $durationUnit  = 'day';
        }
        if ($durationValue <= 0) {
            $durationValue = 30;
        }
        $unitMap   = ['hour' => 'hour', 'day' => 'day', 'week' => 'week', 'month' => 'month', 'year' => 'year'];
        $phpUnit   = $unitMap[$durationUnit] ?? 'day';
        $expiresAt = date('Y-m-d H:i:s', strtotime("+{$durationValue} {$phpUnit}"));

        $depositModel->update((int)$params['id'], [
            'status'     => 'active',
            'expires_at' => $expiresAt,
            'updated_at' => date('Y-m-d H:i:s'),
        ]);

        // Mark the associated pending transaction as completed
        $transModel = new TransactionModel();
        $transModel->markDepositTransactionCompleted((int)$params['id']);

        (new AuditLog())->log('deposit_approved', "Deposit #{$params['id']} approved", Auth::id('admin'), $request->ip());
        $this->flash('success', 'Deposit approved and activated.');
        $this->redirect('/admin/deposits');
    }

    public function reject(Request $request, array $params): void
    {
        $this->requireAuth('admin');
        if (!Csrf::validateRequest($request)) {
            $this->flash('error', 'Invalid CSRF token.');
            $this->redirect('/admin/deposits');
        }
        $depositModel = new DepositModel();
        $depositModel->update((int)$params['id'], [
            'status'     => 'rejected',
            'updated_at' => date('Y-m-d H:i:s'),
        ]);
        (new AuditLog())->log('deposit_rejected', "Deposit #{$params['id']} rejected", Auth::id('admin'), $request->ip());
        $this->flash('success', 'Deposit rejected.');
        $this->redirect('/admin/deposits');
    }
}
