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

        $defaultStats = ['total' => 0, 'active' => 0, 'pending' => 0, 'total_amount' => 0, 'pending_amount' => 0, 'today' => 0, 'banned' => 0, 'new_today' => 0];
        try { $uStats = $userModel->getStats(); }       catch (\Throwable) { $uStats = $defaultStats; }
        try { $dStats = $depositModel->getStats(); }    catch (\Throwable) { $dStats = $defaultStats; }
        try { $wStats = $withdrawalModel->getStats(); } catch (\Throwable) { $wStats = $defaultStats; }
        try { $tStats = $transModel->getStats(); }      catch (\Throwable) { $tStats = $defaultStats; }
        try { $eStats = $earningsModel->getStats(); }   catch (\Throwable) { $eStats = $defaultStats; }
        try { $bals  = $walletModel->getTotalBalance(); } catch (\Throwable) { $bals = []; }

        $stats = [
            'users'        => $uStats,
            'deposits'     => $dStats,
            'withdrawals'  => $wStats,
            'transactions' => $tStats,
            'earnings'     => $eStats,
            'balances'     => $bals,
        ];

        try { $recentUsers        = $userModel->findAll('', [], 'created_at DESC', 10); }     catch (\Throwable) { $recentUsers = []; }
        try { $recentDeposits     = $depositModel->findAll('', [], 'created_at DESC', 10); }  catch (\Throwable) { $recentDeposits = []; }
        try { $pendingWithdrawals = $withdrawalModel->getPending(); }                         catch (\Throwable) { $pendingWithdrawals = []; }
        $recentLogs = (new AuditLog())->getRecent(15);

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
