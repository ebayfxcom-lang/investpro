<?php
declare(strict_types=1);

namespace App\Controllers\User;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Models\UserModel;
use App\Models\DepositModel;
use App\Models\WithdrawalModel;
use App\Models\TransactionModel;
use App\Models\EarningsModel;
use App\Models\WalletModel;
use App\Models\ReferralModel;

class DashboardController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('user');
        $authUser = Auth::user('user');
        $userId   = (int)$authUser['id'];

        $userModel       = new UserModel();
        $depositModel    = new DepositModel();
        $withdrawalModel = new WithdrawalModel();
        $transModel      = new TransactionModel();
        $earningsModel   = new EarningsModel();
        $walletModel     = new WalletModel();
        $referralModel   = new ReferralModel();

        $user            = $userModel->find($userId);
        $wallets         = $walletModel->getUserWallets($userId);
        $activeDeposits  = $depositModel->getActiveDeposits($userId);
        $recentTrans     = $transModel->getUserTransactions($userId, 10);
        $referralStats   = $referralModel->getReferralStats($userId);
        $totalDeposited  = $depositModel->getTotalDepositsByUser($userId);
        $totalEarnings   = $earningsModel->getTotalEarnings($userId);

        $this->view('user/dashboard', [
            'title'           => 'My Dashboard',
            'user'            => $user,
            'wallets'         => $wallets,
            'active_deposits' => $activeDeposits,
            'recent_trans'    => $recentTrans,
            'referral_stats'  => $referralStats,
            'total_deposited' => $totalDeposited,
            'total_earnings'  => $totalEarnings,
        ]);
    }
}
