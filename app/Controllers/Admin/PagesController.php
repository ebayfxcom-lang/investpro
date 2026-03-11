<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\CustomPageModel;

class PagesController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');
        $pageModel = new CustomPageModel();

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/admin/pages');
            }
            $action = $request->post('action', '');

            if ($action === 'create') {
                $title = trim($request->post('title', ''));
                $slug  = trim($request->post('slug', ''));
                if (!$slug) {
                    $slug = $pageModel->generateSlug($title);
                } else {
                    $slug = strtolower(preg_replace('/[^a-z0-9-]+/', '-', $slug));
                }
                $pageModel->create([
                    'title'            => $title,
                    'slug'             => $slug,
                    'content'          => $request->post('content', ''),
                    'meta_description' => trim($request->post('meta_description', '')),
                    'status'           => $request->post('status', 'draft'),
                    'created_at'       => date('Y-m-d H:i:s'),
                ]);
                (new AuditLog())->log('page_created', "Page created: {$title}", Auth::id('admin'), $request->ip());
                $this->flash('success', 'Page created.');
            }

            if ($action === 'update') {
                $id = (int)$request->post('page_id', 0);
                if ($id > 0) {
                    $pageModel->update($id, [
                        'title'            => trim($request->post('title', '')),
                        'slug'             => strtolower(preg_replace('/[^a-z0-9-]+/', '-', trim($request->post('slug', '')))),
                        'content'          => $request->post('content', ''),
                        'meta_description' => trim($request->post('meta_description', '')),
                        'status'           => $request->post('status', 'draft'),
                        'updated_at'       => date('Y-m-d H:i:s'),
                    ]);
                    $this->flash('success', 'Page updated.');
                }
            }

            if ($action === 'delete') {
                $id = (int)$request->post('page_id', 0);
                if ($id > 0) {
                    $pageModel->delete($id);
                    (new AuditLog())->log('page_deleted', "Page #{$id} deleted", Auth::id('admin'), $request->ip());
                    $this->flash('success', 'Page deleted.');
                }
            }

            $this->redirect('/admin/pages');
        }

        $pages = $pageModel->findAll('', [], 'title ASC');

        $this->view('admin/pages/index', [
            'title' => 'Custom Pages',
            'pages' => $pages,
            'admin' => Auth::user('admin'),
        ]);
    }
}
