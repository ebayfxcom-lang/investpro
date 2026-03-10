<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;

class NewsletterController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');

        $this->view('admin/newsletter/index', [
            'title' => 'Newsletter',
            'admin' => Auth::user('admin'),
        ]);
    }
}
