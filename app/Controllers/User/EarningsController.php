<?php
declare(strict_types=1);

namespace App\Controllers\User;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Models\EarningsModel;
use App\Models\ReferralModel;

class EarningsController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('user');
        $userId = (int)Auth::id('user');

        $earningsModel = new EarningsModel();
        $referralModel = new ReferralModel();

        $earnings        = $earningsModel->getUserEarnings($userId);
        $totalEarnings   = $earningsModel->getTotalEarnings($userId);
        $referralEarnings = $referralModel->getUserEarnings($userId);
        $referralTotal   = $referralModel->getTotalEarnings($userId);

        $this->view('user/earnings', [
            'title'             => 'My Earnings',
            'earnings'          => $earnings,
            'total_earnings'    => $totalEarnings,
            'referral_earnings' => $referralEarnings,
            'referral_total'    => $referralTotal,
        ]);
    }
}
