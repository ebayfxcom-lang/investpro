<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Models\UserModel;
use App\Models\DepositModel;
use App\Models\WithdrawalModel;
use App\Models\TransactionModel;
use App\Models\EarningsModel;
use App\Models\WalletModel;
use App\Core\AuditLog;

class DashboardController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');

        $userModel       = new UserModel();
        $depositModel    = new DepositModel();
        $withdrawalModel = new WithdrawalModel();
        $transModel      = new TransactionModel();
        $earningsModel   = new EarningsModel();
        $walletModel     = new WalletModel();

        $stats = [
            'users'        => $userModel->getStats(),
            'deposits'     => $depositModel->getStats(),
            'withdrawals'  => $withdrawalModel->getStats(),
            'transactions' => $transModel->getStats(),
            'earnings'     => $earningsModel->getStats(),
            'balances'     => $walletModel->getTotalBalance(),
        ];

        $recentUsers        = $userModel->findAll('', [], 'created_at DESC', 10);
        $recentDeposits     = $depositModel->findAll('', [], 'created_at DESC', 10);
        $pendingWithdrawals = $withdrawalModel->getPending();
        $recentLogs         = (new AuditLog())->getRecent(15);

        $this->view('admin/dashboard', [
            'title'              => 'Admin Dashboard',
            'stats'              => $stats,
            'recent_users'       => $recentUsers,
            'recent_deposits'    => $recentDeposits,
            'pending_withdrawals'=> $pendingWithdrawals,
            'recent_logs'        => $recentLogs,
            'admin'              => Auth::user('admin'),
        ]);
    }
}
