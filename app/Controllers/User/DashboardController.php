<?php
declare(strict_types=1);

namespace App\Controllers\User;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Models\UserModel;
use App\Models\DepositModel;
use App\Models\WithdrawalModel;
use App\Models\TransactionModel;
use App\Models\EarningsModel;
use App\Models\WalletModel;
use App\Models\ReferralModel;
use App\Models\UserNoticeModel;

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
        $noticeModel     = new UserNoticeModel();

        $user            = $userModel->find($userId);
        try { $wallets        = $walletModel->getUserWallets($userId); } catch (\Throwable) { $wallets = []; }
        try { $activeDeposits = $depositModel->getActiveDeposits($userId); } catch (\Throwable) { $activeDeposits = []; }
        try { $recentTrans    = $transModel->getUserTransactions($userId, 10); } catch (\Throwable) { $recentTrans = []; }
        try { $referralStats  = $referralModel->getReferralStats($userId); } catch (\Throwable) { $referralStats = ['total_referrals' => 0, 'total_earnings' => 0.0, 'pending' => 0.0]; }
        try { $totalDeposited = $depositModel->getTotalDepositsByUser($userId); } catch (\Throwable) { $totalDeposited = 0.0; }
        try { $totalEarnings  = $earningsModel->getTotalEarnings($userId); } catch (\Throwable) { $totalEarnings = 0.0; }

        $userHasDeposit  = !empty($activeDeposits);
        $notices         = $noticeModel->getActiveForUser($userId, $user['account_type'] ?? 'normal', $userHasDeposit);

        $this->view('user/dashboard', [
            'title'           => 'My Dashboard',
            'user'            => $user,
            'wallets'         => $wallets,
            'active_deposits' => $activeDeposits,
            'recent_trans'    => $recentTrans,
            'referral_stats'  => $referralStats,
            'total_deposited' => $totalDeposited,
            'total_earnings'  => $totalEarnings,
            'notices'         => $notices,
        ]);
    }

    public function markNoticeRead(Request $request): void
    {
        $this->requireAuth('user');
        if (!Csrf::validateRequest($request)) {
            $this->json(['success' => false], 403);
            return;
        }
        $noticeId = (int)$request->post('notice_id', 0);
        if ($noticeId > 0) {
            $model = new UserNoticeModel();
            $model->markRead($noticeId, (int)Auth::id('user'));
        }
        $this->json(['success' => true]);
    }
}
