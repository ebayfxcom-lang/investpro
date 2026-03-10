<?php
declare(strict_types=1);

namespace App\Controllers\User;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Models\UserModel;
use App\Models\ReferralModel;

class ReferralController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('user');
        $userId    = (int)Auth::id('user');
        $userModel = new UserModel();
        $user      = $userModel->find($userId);

        $referralModel = new ReferralModel();
        $stats    = $referralModel->getReferralStats($userId);
        $referrals = $userModel->getReferrals($userId);
        $earnings  = $referralModel->getUserEarnings($userId);

        $appConfig = require dirname(__DIR__, 3) . '/config/app.php';
        $refLink   = rtrim($appConfig['url'], '/') . '/register?ref=' . $user['referral_code'];

        $this->view('user/referral/index', [
            'title'     => 'Referrals',
            'user'      => $user,
            'stats'     => $stats,
            'referrals' => $referrals,
            'earnings'  => $earnings,
            'ref_link'  => $refLink,
        ]);
    }
}
