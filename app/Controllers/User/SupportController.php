<?php
declare(strict_types=1);

namespace App\Controllers\User;

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
        $this->requireAuth('user');
        $userId = (int)Auth::id('user');
        $model  = new SupportTicketModel();
        $tickets = $model->getForUser($userId);
        $depts   = $this->getDepartments();

        $this->view('user/support/index', [
            'title'   => 'Support Tickets',
            'tickets' => $tickets,
            'depts'   => $depts,
        ]);
    }

    public function create(Request $request): void
    {
        $this->requireAuth('user');
        $depts = $this->getDepartments();

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/user/support/create');
            }

            $model      = new SupportTicketModel();
            $userId     = (int)Auth::id('user');
            $deptId     = (int)$request->post('department_id', 0);
            $subject    = trim($request->post('subject', ''));
            $body       = trim($request->post('body', ''));

            if (!$subject || !$body || !$deptId) {
                $this->flash('error', 'Please fill in all required fields.');
                $this->redirect('/user/support/create');
            }

            $ref = $model->generateReference();
            $ticketId = $model->create([
                'reference'     => $ref,
                'user_id'       => $userId,
                'department_id' => $deptId,
                'subject'       => substr($subject, 0, 300),
                'priority'      => $request->post('priority', 'normal'),
                'status'        => 'open',
                'created_at'    => date('Y-m-d H:i:s'),
            ]);
            $model->addReply((int)$ticketId, $userId, $body, false, false);
            (new AuditLog())->log('ticket_created', "Ticket {$ref} created", $userId, $request->ip());
            $this->flash('success', "Ticket {$ref} created. We'll get back to you soon.");
            $this->redirect('/user/support');
        }

        $this->view('user/support/create', [
            'title' => 'Open a Support Ticket',
            'depts' => $depts,
        ]);
    }

    public function show(Request $request, array $params): void
    {
        $this->requireAuth('user');
        $userId = (int)Auth::id('user');
        $model  = new SupportTicketModel();
        $ticket = $model->getWithDepartment((int)$params['id']);

        if (!$ticket || (int)$ticket['user_id'] !== $userId) {
            $this->flash('error', 'Ticket not found.');
            $this->redirect('/user/support');
        }

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/user/support/' . $params['id']);
            }
            $body = trim($request->post('body', ''));
            if ($body && $ticket['status'] !== 'closed') {
                $model->addReply((int)$params['id'], $userId, $body, false, false);
                $model->update((int)$params['id'], ['status' => 'open']);
                $this->flash('success', 'Reply sent.');
            }
            $this->redirect('/user/support/' . $params['id']);
        }

        $replies = $model->getReplies((int)$params['id'], false);

        $this->view('user/support/show', [
            'title'   => 'Ticket ' . $ticket['reference'],
            'ticket'  => $ticket,
            'replies' => $replies,
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
