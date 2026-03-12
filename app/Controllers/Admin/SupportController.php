<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\SupportTicketModel;

class SupportController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');
        $model  = new SupportTicketModel();
        $page   = (int)($request->get('page', 1));
        $status = $request->get('status', '');
        $deptId = (int)$request->get('department', 0);
        $data   = $model->adminPaginate($page, 25, $status, $deptId);
        $depts  = $this->getDepartments();

        $this->view('admin/support/index', [
            'title'  => 'Support Tickets',
            'data'   => $data,
            'depts'  => $depts,
            'filter_status' => $status,
            'filter_dept'   => $deptId,
            'admin'  => Auth::user('admin'),
        ]);
    }

    public function show(Request $request, array $params): void
    {
        $this->requireAuth('admin');
        $model  = new SupportTicketModel();
        $ticket = $model->getWithDepartment((int)$params['id']);
        if (!$ticket) {
            $this->flash('error', 'Ticket not found.');
            $this->redirect('/admin/support');
        }

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/admin/support/' . $params['id']);
            }

            $action = $request->post('action', '');

            if ($action === 'reply') {
                $body       = trim($request->post('body', ''));
                $isInternal = (bool)$request->post('is_internal', 0);
                if ($body) {
                    $model->addReply((int)$params['id'], Auth::id('admin'), $body, true, $isInternal);
                    if (!$isInternal) {
                        $model->update((int)$params['id'], ['status' => 'in_progress']);
                    }
                    (new AuditLog())->log('ticket_reply', "Replied to ticket #{$params['id']}", Auth::id('admin'), $request->ip());
                    $this->flash('success', 'Reply sent.');
                }
                $this->redirect('/admin/support/' . $params['id']);
            }

            if ($action === 'update_status') {
                $newStatus = $request->post('status', '');
                $allowed   = ['open','in_progress','waiting','resolved','closed'];
                if (in_array($newStatus, $allowed, true)) {
                    $updates = ['status' => $newStatus];
                    if ($newStatus === 'closed') {
                        $updates['closed_at'] = date('Y-m-d H:i:s');
                    }
                    $model->update((int)$params['id'], $updates);
                    $this->flash('success', 'Status updated.');
                }
                $this->redirect('/admin/support/' . $params['id']);
            }

            if ($action === 'assign') {
                $assignTo = (int)$request->post('assigned_to', 0);
                $model->update((int)$params['id'], ['assigned_to' => $assignTo ?: null]);
                $this->flash('success', 'Ticket assigned.');
                $this->redirect('/admin/support/' . $params['id']);
            }
        }

        $replies = $model->getReplies((int)$params['id'], true);

        $this->view('admin/support/show', [
            'title'   => 'Ticket ' . $ticket['reference'],
            'ticket'  => $ticket,
            'replies' => $replies,
            'admin'   => Auth::user('admin'),
        ]);
    }

    private function getDepartments(): array
    {
        try {
            $db = \App\Core\Database::getInstance();
            return $db->fetchAll("SELECT * FROM ticket_departments WHERE status = 'active' ORDER BY sort_order");
        } catch (\Throwable $e) {
            return [];
        }
    }
}
