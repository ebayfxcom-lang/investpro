<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Models\TransactionModel;

class TransactionsController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');
        $transModel = new TransactionModel();
        $page   = (int)($request->get('page', 1));
        $type   = $request->get('type', '');

        $where  = $type ? 'type = ?' : '';
        $params = $type ? [$type] : [];

        $data = $transModel->paginate($page, 20, $where, $params);

        $this->view('admin/transactions/index', [
            'title' => 'Transactions',
            'data'  => $data,
            'type'  => $type,
            'admin' => Auth::user('admin'),
        ]);
    }
}
