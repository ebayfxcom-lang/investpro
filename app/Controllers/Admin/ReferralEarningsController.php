<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Models\ReferralModel;

class ReferralEarningsController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');

        $referralModel = new ReferralModel();
        $page  = (int)($request->get('page', 1));
        $data  = $referralModel->paginate($page, 20, '', [], 'created_at DESC');

        $this->view('admin/referrals/index', [
            'title' => 'Referral Earnings',
            'data'  => $data,
            'admin' => Auth::user('admin'),
        ]);
    }
}
