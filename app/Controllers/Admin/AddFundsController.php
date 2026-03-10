<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Models\UserModel;

class AddFundsController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');

        $userModel = new UserModel();
        $page   = (int)($request->get('page', 1));
        $search = trim($request->get('search', ''));

        if ($search) {
            $where  = 'username LIKE ? OR email LIKE ?';
            $params = ["%{$search}%", "%{$search}%"];
        } else {
            $where  = '';
            $params = [];
        }

        $data = $userModel->paginate($page, 20, $where, $params);

        $this->view('admin/add-funds/index', [
            'title'  => 'Add Funds',
            'data'   => $data,
            'search' => $search,
            'admin'  => Auth::user('admin'),
        ]);
    }
}
