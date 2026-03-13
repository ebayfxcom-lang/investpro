<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\FaqModel;
use App\Models\FaqCategoryModel;

class FaqController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');
        $faqModel      = new FaqModel();
        $categoryModel = new FaqCategoryModel();

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/admin/faq');
            }
            $action = $request->post('action', '');

            // ── FAQ item actions ──────────────────────────────────────
            if ($action === 'create') {
                $question = trim($request->post('question', ''));
                $answer   = trim($request->post('answer', ''));
                if ($question === '' || $answer === '') {
                    $this->flash('error', 'Question and answer are required.');
                    $this->redirect('/admin/faq');
                }
                try {
                    $faqModel->create([
                        'question'    => $question,
                        'answer'      => $answer,
                        'category'    => $request->post('category', 'general'),
                        'category_id' => ((int)$request->post('category_id', 0)) ?: null,
                        'sort_order'  => (int)$request->post('sort_order', 0),
                        'status'      => $request->post('status', 'active'),
                        'created_at'  => date('Y-m-d H:i:s'),
                    ]);
                } catch (\Throwable $e) {
                    error_log('FaqController create error: ' . $e->getMessage());
                    // Retry without extended columns (pre-migration 004/005 schema)
                    try {
                        $faqModel->create([
                            'question'   => $question,
                            'answer'     => $answer,
                            'sort_order' => (int)$request->post('sort_order', 0),
                            'created_at' => date('Y-m-d H:i:s'),
                        ]);
                    } catch (\Throwable) {
                        $this->flash('error', 'Could not create FAQ. Please run the latest database migration.');
                        $this->redirect('/admin/faq');
                    }
                }
                (new AuditLog())->log('faq_created', 'New FAQ item created', Auth::id('admin'), $request->ip());
                $this->flash('success', 'FAQ item created.');
            }

            if ($action === 'update') {
                $id = (int)$request->post('faq_id', 0);
                if ($id > 0) {
                    try {
                        $faqModel->update($id, [
                            'question'    => trim($request->post('question', '')),
                            'answer'      => trim($request->post('answer', '')),
                            'category'    => $request->post('category', 'general'),
                            'category_id' => ((int)$request->post('category_id', 0)) ?: null,
                            'sort_order'  => (int)$request->post('sort_order', 0),
                            'status'      => $request->post('status', 'active'),
                            'updated_at'  => date('Y-m-d H:i:s'),
                        ]);
                        $this->flash('success', 'FAQ item updated.');
                    } catch (\Throwable $e) {
                        error_log('FaqController update error: ' . $e->getMessage());
                        // Retry without extended columns (pre-migration 005 schema)
                        try {
                            $faqModel->update($id, [
                                'question'   => trim($request->post('question', '')),
                                'answer'     => trim($request->post('answer', '')),
                                'sort_order' => (int)$request->post('sort_order', 0),
                                'status'     => $request->post('status', 'active'),
                            ]);
                            $this->flash('success', 'FAQ item updated (partial - please run migration 009).');
                        } catch (\Throwable) {
                            $this->flash('error', 'Could not update FAQ. Please run the latest database migration.');
                        }
                    }
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

            // ── Custom category management ──────────────────────────
            if ($action === 'create_category') {
                $name = trim($request->post('cat_name', ''));
                if ($name === '') {
                    $this->flash('error', 'Category name is required.');
                    $this->redirect('/admin/faq');
                }
                try {
                    $slug = $categoryModel->slugify($name);
                    // Ensure unique slug using counter-based approach
                    $baseSlug = $slug;
                    $counter  = 2;
                    while ($categoryModel->findBySlug($slug)) {
                        $slug = $baseSlug . '-' . $counter++;
                    }
                    $categoryModel->create([
                        'name'       => $name,
                        'slug'       => $slug,
                        'status'     => 'active',
                        'sort_order' => (int)$request->post('cat_sort_order', 0),
                        'created_at' => date('Y-m-d H:i:s'),
                    ]);
                    (new AuditLog())->log('faq_category_created', "FAQ category '{$name}' created", Auth::id('admin'), $request->ip());
                    $this->flash('success', "Category '{$name}' created.");
                } catch (\Throwable $e) {
                    error_log('FaqController create_category: ' . $e->getMessage());
                    $this->flash('error', 'Could not create category. Please run the latest migration first.');
                }
            }

            if ($action === 'toggle_category') {
                $catId = (int)$request->post('category_id', 0);
                if ($catId > 0) {
                    try {
                        $cat = $categoryModel->find($catId);
                        if ($cat) {
                            $newStatus = $cat['status'] === 'active' ? 'inactive' : 'active';
                            $categoryModel->update($catId, ['status' => $newStatus, 'updated_at' => date('Y-m-d H:i:s')]);
                            $this->flash('success', 'Category status updated.');
                        }
                    } catch (\Throwable $e) {
                        $this->flash('error', 'Could not update category.');
                    }
                }
            }

            if ($action === 'delete_category') {
                $catId = (int)$request->post('category_id', 0);
                if ($catId > 0) {
                    try {
                        $categoryModel->delete($catId);
                        (new AuditLog())->log('faq_category_deleted', "FAQ category #{$catId} deleted", Auth::id('admin'), $request->ip());
                        $this->flash('success', 'Category deleted.');
                    } catch (\Throwable $e) {
                        $this->flash('error', 'Could not delete category.');
                    }
                }
            }

            $this->redirect('/admin/faq');
        }

        $faqs       = $faqModel->findAll('', [], 'sort_order ASC, id ASC');
        $categories = $faqModel->getCategories();

        $this->view('admin/faq/index', [
            'title'      => 'FAQ Manager',
            'faqs'       => $faqs,
            'categories' => $categories,
            'admin'      => Auth::user('admin'),
        ]);
    }
}
