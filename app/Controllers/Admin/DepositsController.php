<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\DepositModel;

class DepositsController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');
        $depositModel = new DepositModel();
        $page   = (int)($request->get('page', 1));
        $status = $request->get('status', '');

        $where  = $status ? 'status = ?' : '';
        $params = $status ? [$status] : [];

        $data = $depositModel->paginate($page, 20, $where, $params);

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
        $depositModel->update((int)$params['id'], [
            'status'     => 'active',
            'updated_at' => date('Y-m-d H:i:s'),
        ]);
        (new AuditLog())->log('deposit_approved', "Deposit #{$params['id']} approved", Auth::id('admin'), $request->ip());
        $this->flash('success', 'Deposit approved.');
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
