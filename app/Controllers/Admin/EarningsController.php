<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Models\EarningsModel;

class EarningsController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');

        $earningsModel = new EarningsModel();
        $page   = (int)($request->get('page', 1));
        $stats  = $earningsModel->getStats();
        $data   = $earningsModel->paginate($page, 20, '', [], 'created_at DESC');

        $this->view('admin/earnings/index', [
            'title'  => 'Earnings Overview',
            'stats'  => $stats,
            'data'   => $data,
            'admin'  => Auth::user('admin'),
        ]);
    }
}
