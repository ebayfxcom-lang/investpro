<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\WithdrawalModel;
use App\Models\WalletModel;

class WithdrawalsController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');
        $withdrawalModel = new WithdrawalModel();
        $page   = (int)($request->get('page', 1));
        $status = $request->get('status', '');

        $where  = $status ? 'status = ?' : '';
        $params = $status ? [$status] : [];

        $data = $withdrawalModel->paginate($page, 20, $where, $params);

        $this->view('admin/withdrawals/index', [
            'title'  => 'Withdrawals',
            'data'   => $data,
            'status' => $status,
            'admin'  => Auth::user('admin'),
        ]);
    }

    public function approve(Request $request, array $params): void
    {
        $this->requireAuth('admin');
        if (!Csrf::validateRequest($request)) {
            $this->flash('error', 'Invalid CSRF token.');
            $this->redirect('/admin/withdrawals');
        }
        $withdrawalModel = new WithdrawalModel();
        $withdrawal = $withdrawalModel->find((int)$params['id']);
        if ($withdrawal && $withdrawal['status'] === 'pending') {
            $withdrawalModel->update((int)$params['id'], [
                'status'     => 'approved',
                'updated_at' => date('Y-m-d H:i:s'),
            ]);
            (new AuditLog())->log('withdrawal_approved', "Withdrawal #{$params['id']} approved", Auth::id('admin'), $request->ip());
            $this->flash('success', 'Withdrawal approved.');
        }
        $this->redirect('/admin/withdrawals');
    }

    public function reject(Request $request, array $params): void
    {
        $this->requireAuth('admin');
        if (!Csrf::validateRequest($request)) {
            $this->flash('error', 'Invalid CSRF token.');
            $this->redirect('/admin/withdrawals');
        }
        $withdrawalModel = new WithdrawalModel();
        $withdrawal = $withdrawalModel->find((int)$params['id']);
        if ($withdrawal && $withdrawal['status'] === 'pending') {
            // Refund wallet
            $walletModel = new WalletModel();
            $walletModel->credit((int)$withdrawal['user_id'], $withdrawal['currency'], (float)$withdrawal['amount']);
            $withdrawalModel->update((int)$params['id'], [
                'status'     => 'rejected',
                'updated_at' => date('Y-m-d H:i:s'),
            ]);
            (new AuditLog())->log('withdrawal_rejected', "Withdrawal #{$params['id']} rejected + refunded", Auth::id('admin'), $request->ip());
            $this->flash('success', 'Withdrawal rejected and funds refunded.');
        }
        $this->redirect('/admin/withdrawals');
    }
}
