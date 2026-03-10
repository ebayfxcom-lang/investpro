<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\BlacklistModel;

class BlacklistController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');

        $blacklistModel = new BlacklistModel();
        $page   = (int)($request->get('page', 1));
        $data   = $blacklistModel->paginate($page, 20, '', [], 'created_at DESC');

        $this->view('admin/blacklist/index', [
            'title' => 'Blacklist',
            'data'  => $data,
            'admin' => Auth::user('admin'),
        ]);
    }

    public function add(Request $request): void
    {
        $this->requireAuth('admin');

        if (!Csrf::validateRequest($request)) {
            $this->flash('error', 'Invalid CSRF token.');
            $this->redirect('/admin/blacklist');
        }

        $value     = trim($request->post('value', ''));
        $type      = $request->post('type', 'ip');
        $reason    = trim($request->post('reason', ''));
        $expiresAt = $request->post('expires_at') ?: null;

        if ($value === '') {
            $this->flash('error', 'Value is required.');
            $this->redirect('/admin/blacklist');
        }

        $blacklistModel = new BlacklistModel();
        $blacklistModel->addEntry($value, $type, $reason, $expiresAt);
        (new AuditLog())->log('blacklist_add', "Added {$type} to blacklist: {$value}", Auth::id('admin'), $request->ip());
        $this->flash('success', 'Entry added to blacklist.');
        $this->redirect('/admin/blacklist');
    }

    public function remove(Request $request, array $params): void
    {
        $this->requireAuth('admin');

        if (!Csrf::validateRequest($request)) {
            $this->flash('error', 'Invalid CSRF token.');
            $this->redirect('/admin/blacklist');
        }

        $blacklistModel = new BlacklistModel();
        $blacklistModel->delete((int)$params['id']);
        (new AuditLog())->log('blacklist_remove', "Removed blacklist entry #{$params['id']}", Auth::id('admin'), $request->ip());
        $this->flash('success', 'Entry removed from blacklist.');
        $this->redirect('/admin/blacklist');
    }
}
