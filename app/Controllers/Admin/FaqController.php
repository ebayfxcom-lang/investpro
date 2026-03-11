<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\FaqModel;

class FaqController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');
        $faqModel = new FaqModel();

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/admin/faq');
            }
            $action = $request->post('action', '');

            if ($action === 'create') {
                $faqModel->create([
                    'question'   => trim($request->post('question', '')),
                    'answer'     => trim($request->post('answer', '')),
                    'category'   => $request->post('category', 'general'),
                    'sort_order' => (int)$request->post('sort_order', 0),
                    'status'     => $request->post('status', 'active'),
                    'created_at' => date('Y-m-d H:i:s'),
                ]);
                (new AuditLog())->log('faq_created', 'New FAQ item created', Auth::id('admin'), $request->ip());
                $this->flash('success', 'FAQ item created.');
            }

            if ($action === 'update') {
                $id = (int)$request->post('faq_id', 0);
                if ($id > 0) {
                    $faqModel->update($id, [
                        'question'   => trim($request->post('question', '')),
                        'answer'     => trim($request->post('answer', '')),
                        'category'   => $request->post('category', 'general'),
                        'sort_order' => (int)$request->post('sort_order', 0),
                        'status'     => $request->post('status', 'active'),
                        'updated_at' => date('Y-m-d H:i:s'),
                    ]);
                    $this->flash('success', 'FAQ item updated.');
                }
            }

            if ($action === 'delete') {
                $id = (int)$request->post('faq_id', 0);
                if ($id > 0) {
                    $faqModel->delete($id);
                    (new AuditLog())->log('faq_deleted', "FAQ #{$id} deleted", Auth::id('admin'), $request->ip());
                    $this->flash('success', 'FAQ item deleted.');
                }
            }

            $this->redirect('/admin/faq');
        }

        $faqs = $faqModel->findAll('', [], 'sort_order ASC, id ASC');

        $this->view('admin/faq/index', [
            'title'      => 'FAQ Manager',
            'faqs'       => $faqs,
            'categories' => $faqModel->getCategories(),
            'admin'      => Auth::user('admin'),
        ]);
    }
}
