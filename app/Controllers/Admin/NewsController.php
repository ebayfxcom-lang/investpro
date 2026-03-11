<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\NewsModel;

class NewsController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');
        $newsModel = new NewsModel();

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/admin/news');
            }
            $action = $request->post('action', '');

            if ($action === 'create') {
                $newsModel->create([
                    'title'      => trim($request->post('title', '')),
                    'content'    => trim($request->post('content', '')),
                    'status'     => $request->post('status', 'draft'),
                    'published_at' => $request->post('status') === 'published' ? date('Y-m-d H:i:s') : null,
                    'created_at' => date('Y-m-d H:i:s'),
                ]);
                (new AuditLog())->log('news_created', 'News post created: ' . $request->post('title'), Auth::id('admin'), $request->ip());
                $this->flash('success', 'News post created.');
            }

            if ($action === 'update') {
                $id = (int)$request->post('news_id', 0);
                if ($id > 0) {
                    $updates = [
                        'title'      => trim($request->post('title', '')),
                        'content'    => trim($request->post('content', '')),
                        'status'     => $request->post('status', 'draft'),
                        'updated_at' => date('Y-m-d H:i:s'),
                    ];
                    if ($request->post('status') === 'published') {
                        $existing = $newsModel->find($id);
                        if ($existing && $existing['status'] !== 'published') {
                            $updates['published_at'] = date('Y-m-d H:i:s');
                        }
                    }
                    $newsModel->update($id, $updates);
                    $this->flash('success', 'News post updated.');
                }
            }

            if ($action === 'delete') {
                $id = (int)$request->post('news_id', 0);
                if ($id > 0) {
                    $newsModel->delete($id);
                    (new AuditLog())->log('news_deleted', "News #{$id} deleted", Auth::id('admin'), $request->ip());
                    $this->flash('success', 'News post deleted.');
                }
            }

            $this->redirect('/admin/news');
        }

        $page  = (int)($request->get('page', 1));
        $data  = $newsModel->paginate($page, 20, '', [], 'created_at DESC');

        $this->view('admin/news/index', [
            'title' => 'News Manager',
            'data'  => $data,
            'admin' => Auth::user('admin'),
        ]);
    }
}
