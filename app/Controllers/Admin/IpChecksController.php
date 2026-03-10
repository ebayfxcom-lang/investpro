<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\BlacklistModel;

class IpChecksController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');

        $blacklistModel = new BlacklistModel();
        $page   = (int)($request->get('page', 1));
        $query  = trim($request->get('q', ''));
        $result = null;

        if ($query !== '') {
            $result = $blacklistModel->isBlacklisted($query, 'ip')
                ? ['status' => 'blocked', 'ip' => $query]
                : ['status' => 'clean', 'ip' => $query];
        }

        $data = $blacklistModel->paginate($page, 20, "type = 'ip'", [], 'created_at DESC');

        $this->view('admin/ip-checks/index', [
            'title'  => 'IP Checks',
            'data'   => $data,
            'query'  => $query,
            'result' => $result,
            'admin'  => Auth::user('admin'),
        ]);
    }

    public function block(Request $request): void
    {
        $this->requireAuth('admin');

        if (!Csrf::validateRequest($request)) {
            $this->flash('error', 'Invalid CSRF token.');
            $this->redirect('/admin/ip-checks');
        }

        $ip     = trim($request->post('ip', ''));
        $reason = trim($request->post('reason', ''));

        if ($ip === '' || !filter_var($ip, FILTER_VALIDATE_IP)) {
            $this->flash('error', 'A valid IP address is required.');
            $this->redirect('/admin/ip-checks');
        }

        $blacklistModel = new BlacklistModel();
        $blacklistModel->addEntry($ip, 'ip', $reason);
        (new AuditLog())->log('ip_blocked', "Blocked IP: {$ip}", Auth::id('admin'), $request->ip());
        $this->flash('success', "IP {$ip} has been blocked.");
        $this->redirect('/admin/ip-checks');
    }

    public function unblock(Request $request, array $params): void
    {
        $this->requireAuth('admin');

        if (!Csrf::validateRequest($request)) {
            $this->flash('error', 'Invalid CSRF token.');
            $this->redirect('/admin/ip-checks');
        }

        $blacklistModel = new BlacklistModel();
        $blacklistModel->delete((int)$params['id']);
        (new AuditLog())->log('ip_unblocked', "Removed blocked IP entry #{$params['id']}", Auth::id('admin'), $request->ip());
        $this->flash('success', 'IP has been unblocked.');
        $this->redirect('/admin/ip-checks');
    }
}
