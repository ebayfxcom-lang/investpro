<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\NewsletterModel;
use App\Models\UserModel;

class NewsletterController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');
        $newsletterModel = new NewsletterModel();
        $userModel       = new UserModel();

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/admin/newsletter');
            }
            $action = $request->post('action', '');

            if ($action === 'create') {
                $subject    = trim($request->post('subject', ''));
                $senderName = trim($request->post('sender_name', ''));
                if ($subject === '') {
                    $this->flash('error', 'Subject is required.');
                    $this->redirect('/admin/newsletter');
                }
                $newsletterModel->create([
                    'subject'     => $subject,
                    'content'     => $request->post('content', ''),
                    'sender_name' => $senderName ?: null,
                    'recipients'  => $request->post('recipients', 'all'),
                    'status'      => 'draft',
                    'created_by'  => Auth::id('admin'),
                    'created_at'  => date('Y-m-d H:i:s'),
                ]);
                (new AuditLog())->log('newsletter_created', 'Newsletter draft created: ' . $subject, Auth::id('admin'), $request->ip());
                $this->flash('success', 'Newsletter draft saved.');
            }

            if ($action === 'update') {
                $id = (int)$request->post('newsletter_id', 0);
                if ($id > 0) {
                    $newsletterModel->update($id, [
                        'subject'    => trim($request->post('subject', '')),
                        'content'    => $request->post('content', ''),
                        'recipients' => $request->post('recipients', 'all'),
                        'updated_at' => date('Y-m-d H:i:s'),
                    ]);
                    $this->flash('success', 'Newsletter updated.');
                }
            }

            if ($action === 'send') {
                $id = (int)$request->post('newsletter_id', 0);
                $nl = $id > 0 ? $newsletterModel->find($id) : null;
                if ($nl && $nl['status'] === 'draft') {
                    // Count recipients based on audience type
                    $recipients = $nl['recipients'] ?? 'all';
                    $guestModel = new \App\Models\NewsletterGuestModel();
                    switch ($recipients) {
                        case 'active':
                            $count = $userModel->count("status = 'active'");
                            break;
                        case 'subscribers':
                            $count = $guestModel->count("status = 'subscribed'");
                            break;
                        case 'non_user_subscribers':
                            $count = count($guestModel->getNonUserSubscribers());
                            break;
                        case 'non_deposited':
                            $count = (int)(\App\Core\Database::getInstance()->fetchOne(
                                "SELECT COUNT(*) AS cnt FROM users u
                                 WHERE u.status = 'active'
                                   AND NOT EXISTS (SELECT 1 FROM deposits d WHERE d.user_id = u.id AND d.status != 'cancelled')"
                            )['cnt'] ?? 0);
                            break;
                        default: // 'all'
                            $count = $userModel->count();
                            break;
                    }
                    // Plan-based filtering
                    $planFilter = trim($request->post('plan_filter', ''));
                    if ($planFilter !== '' && in_array($recipients, ['all', 'active'], true)) {
                        try {
                            $count = (int)(\App\Core\Database::getInstance()->fetchOne(
                                "SELECT COUNT(DISTINCT d.user_id) AS cnt FROM deposits d
                                 JOIN plans p ON d.plan_id = p.id
                                 WHERE d.status = 'active' AND p.name = ?",
                                [$planFilter]
                            )['cnt'] ?? 0);
                        } catch (\Throwable) {
                            // keep existing count
                        }
                    }
                    $adminUser  = Auth::user('admin');
                    $senderName = $adminUser ? ($adminUser['username'] ?? '') : '';
                    // TODO: Integrate with EmailService to actually send emails to recipients.
                    $newsletterModel->markSent($id, $count, Auth::id('admin'), $senderName);
                    (new AuditLog())->log('newsletter_sent', "Newsletter #{$id} sent to {$count} recipients by {$senderName}", Auth::id('admin'), $request->ip());
                    $this->flash('success', "Newsletter sent to {$count} recipients.");
                } else {
                    $this->flash('error', 'Newsletter not found or already sent.');
                }
            }

            if ($action === 'delete') {
                $id = (int)$request->post('newsletter_id', 0);
                if ($id > 0) {
                    $newsletterModel->delete($id);
                    (new AuditLog())->log('newsletter_deleted', "Newsletter #{$id} deleted", Auth::id('admin'), $request->ip());
                    $this->flash('success', 'Newsletter deleted.');
                }
            }

            $this->redirect('/admin/newsletter');
        }

        $page  = (int)($request->get('page', 1));
        $data  = $newsletterModel->paginate($page, 20, '', [], 'created_at DESC');
        $stats = [
            'total'       => $newsletterModel->count(),
            'sent'        => $newsletterModel->count("status = 'sent'"),
            'drafts'      => $newsletterModel->count("status = 'draft'"),
            'subscribers' => (new \App\Models\NewsletterGuestModel())->count("status = 'subscribed'"),
        ];

        $this->view('admin/newsletter/index', [
            'title'  => 'Newsletter',
            'data'   => $data,
            'stats'  => $stats,
            'admin'  => Auth::user('admin'),
        ]);
    }
}
