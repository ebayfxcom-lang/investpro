<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\UserNoticeModel;

class NoticesController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');
        $model = new UserNoticeModel();

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/admin/notices');
            }

            $action = $request->post('action', '');

            if ($action === 'create') {
                $startsAt = $request->post('starts_at', '') ?: null;
                $endsAt   = $request->post('ends_at', '') ?: null;
                $model->create([
                    'title'        => trim($request->post('title', '')),
                    'body'         => trim($request->post('body', '')),
                    'notice_type'  => $request->post('notice_type', 'info'),
                    'display_type' => $request->post('display_type', 'banner'),
                    'target'       => $request->post('target', 'all'),
                    'status'       => $request->post('status', 'draft'),
                    'starts_at'    => $startsAt && ($ts = strtotime($startsAt)) !== false ? date('Y-m-d H:i:s', $ts) : null,
                    'ends_at'      => $endsAt && ($ts = strtotime($endsAt)) !== false ? date('Y-m-d H:i:s', $ts) : null,
                    'created_by'   => Auth::id('admin'),
                    'created_at'   => date('Y-m-d H:i:s'),
                ]);
                (new AuditLog())->log('notice_created', 'User notice created', Auth::id('admin'), $request->ip());
                $this->flash('success', 'Notice created.');
                $this->redirect('/admin/notices');
            }

            if ($action === 'update') {
                $id = (int)$request->post('notice_id', 0);
                if ($id > 0) {
                    $startsAt = $request->post('starts_at', '') ?: null;
                    $endsAt   = $request->post('ends_at', '') ?: null;
                    $model->update($id, [
                        'title'        => trim($request->post('title', '')),
                        'body'         => trim($request->post('body', '')),
                        'notice_type'  => $request->post('notice_type', 'info'),
                        'display_type' => $request->post('display_type', 'banner'),
                        'target'       => $request->post('target', 'all'),
                        'status'       => $request->post('status', 'draft'),
                        'starts_at'    => $startsAt && ($ts = strtotime($startsAt)) !== false ? date('Y-m-d H:i:s', $ts) : null,
                        'ends_at'      => $endsAt && ($ts = strtotime($endsAt)) !== false ? date('Y-m-d H:i:s', $ts) : null,
                    ]);
                    $this->flash('success', 'Notice updated.');
                }
                $this->redirect('/admin/notices');
            }

            if ($action === 'delete') {
                $id = (int)$request->post('notice_id', 0);
                if ($id > 0) {
                    $model->delete($id);
                    (new AuditLog())->log('notice_deleted', "Notice #{$id} deleted", Auth::id('admin'), $request->ip());
                    $this->flash('success', 'Notice deleted.');
                }
                $this->redirect('/admin/notices');
            }

            if ($action === 'publish') {
                $id = (int)$request->post('notice_id', 0);
                if ($id > 0) {
                    $model->update($id, ['status' => 'published']);
                    $this->flash('success', 'Notice published.');
                }
                $this->redirect('/admin/notices');
            }

            if ($action === 'expire') {
                $id = (int)$request->post('notice_id', 0);
                if ($id > 0) {
                    $model->update($id, ['status' => 'expired']);
                    $this->flash('success', 'Notice expired.');
                }
                $this->redirect('/admin/notices');
            }
        }

        $page = (int)($request->get('page', 1));
        $data = $model->adminPaginate($page, 20);

        $this->view('admin/notices/index', [
            'title' => 'User Notices',
            'data'  => $data,
            'admin' => Auth::user('admin'),
        ]);
    }
}
