<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\CommunityPostModel;
use App\Models\BotProfileModel;
use App\Models\RestrictedKeywordModel;

class CommunityController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');

        $postModel = new CommunityPostModel();
        $page      = (int)($request->get('page', 1));
        $data      = $postModel->adminPaginate($page, 30);

        $this->view('admin/community/index', [
            'title' => 'Community Feed',
            'data'  => $data,
            'admin' => Auth::user('admin'),
        ]);
    }

    public function createPost(Request $request): void
    {
        $this->requireAuth('admin');

        if (!Csrf::validateRequest($request)) {
            $this->flash('error', 'Invalid CSRF token.');
            $this->redirect('/admin/community');
        }

        $content = trim($request->post('content', ''));
        if (strlen($content) < 5) {
            $this->flash('error', 'Post must be at least 5 characters.');
            $this->redirect('/admin/community');
        }
        if (strlen($content) > 2000) {
            $this->flash('error', 'Post must be under 2000 characters.');
            $this->redirect('/admin/community');
        }

        $content = htmlspecialchars(strip_tags($content), ENT_QUOTES, 'UTF-8');
        $adminId = Auth::id('admin');

        $postModel = new CommunityPostModel();
        try {
            $postId = $postModel->create([
                'user_id'    => null,
                'bot_id'     => null,
                'content'    => $content,
                'is_bot'     => 0,
                'is_featured'=> (int)$request->post('is_featured', 0),
                'is_hidden'  => 0,
                'status'     => 'active',
                'created_at' => date('Y-m-d H:i:s'),
            ]);
            (new AuditLog())->log('admin_community_post_created', "Admin post #{$postId} created", $adminId, $request->ip());
            $this->flash('success', 'Post published to community.');
        } catch (\Throwable $e) {
            error_log('Admin createPost error: ' . $e->getMessage());
            $this->flash('error', 'Could not create post. Please ensure database migrations are up to date.');
        }
        $this->redirect('/admin/community');
    }

    public function deletePost(Request $request, array $params): void
    {
        $this->requireAuth('admin');
        if (!Csrf::validateRequest($request)) {
            $this->flash('error', 'Invalid CSRF token.');
            $this->redirect('/admin/community');
        }

        $postModel = new CommunityPostModel();
        $post      = $postModel->find((int)$params['id']);
        if ($post) {
            $postModel->update((int)$params['id'], ['status' => 'deleted']);
            (new AuditLog())->log('community_post_deleted', "Post #{$params['id']} deleted by admin", Auth::id('admin'), $request->ip());
            $this->flash('success', 'Post deleted.');
        }
        $this->redirect('/admin/community');
    }

    public function bots(Request $request): void
    {
        $this->requireAuth('admin');

        $botModel = new BotProfileModel();

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/admin/community/bots');
            }

            $action = $request->post('action', '');

            if ($action === 'create_bot') {
                $botModel->create([
                    'display_name'   => trim($request->post('display_name', 'Bot User')),
                    'tone_category'  => $request->post('tone_category', 'general'),
                    'keywords'       => json_encode(array_filter(array_map('trim', explode(',', $request->post('keywords', ''))))),
                    'post_frequency' => max(5, (int)$request->post('post_frequency', 60)),
                    'status'         => $request->post('status', 'active'),
                    'created_at'     => date('Y-m-d H:i:s'),
                ]);
                (new AuditLog())->log('bot_created', 'Bot profile created', Auth::id('admin'), $request->ip());
                $this->flash('success', 'Bot profile created.');
                $this->redirect('/admin/community/bots');
            }

            if ($action === 'delete_bot') {
                $botId = (int)$request->post('bot_id', 0);
                if ($botId > 0) {
                    $botModel->delete($botId);
                    (new AuditLog())->log('bot_deleted', "Bot #{$botId} deleted", Auth::id('admin'), $request->ip());
                    $this->flash('success', 'Bot profile deleted.');
                }
                $this->redirect('/admin/community/bots');
            }

            if ($action === 'toggle_bot') {
                $botId  = (int)$request->post('bot_id', 0);
                $bot    = $botModel->find($botId);
                if ($bot) {
                    $newStatus = $bot['status'] === 'active' ? 'inactive' : 'active';
                    $botModel->update($botId, ['status' => $newStatus]);
                    $this->flash('success', "Bot {$newStatus}.");
                }
                $this->redirect('/admin/community/bots');
            }
        }

        $bots = $botModel->findAll('', [], 'id ASC');

        $this->view('admin/community/bots', [
            'title' => 'Bot Profiles',
            'bots'  => $bots,
            'admin' => Auth::user('admin'),
        ]);
    }

    public function keywords(Request $request): void
    {
        $this->requireAuth('admin');
        $model = new RestrictedKeywordModel();

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/admin/community/keywords');
            }
            $action = $request->post('action', '');
            if ($action === 'add') {
                $kw = trim($request->post('keyword', ''));
                if ($kw) {
                    try {
                        $model->create(['keyword' => $kw, 'created_by' => Auth::id('admin'), 'created_at' => date('Y-m-d H:i:s')]);
                        $this->flash('success', 'Keyword added.');
                    } catch (\Throwable $e) {
                        $this->flash('error', 'Keyword already exists.');
                    }
                }
            } elseif ($action === 'delete') {
                $id = (int)$request->post('keyword_id', 0);
                if ($id > 0) {
                    $model->delete($id);
                    $this->flash('success', 'Keyword removed.');
                }
            }
            $this->redirect('/admin/community/keywords');
        }

        $this->view('admin/community/keywords', [
            'title'    => 'Restricted Keywords',
            'keywords' => $model->getAll(),
            'admin'    => Auth::user('admin'),
        ]);
    }

    public function hidePost(Request $request, array $params): void
    {
        $this->requireAuth('admin');
        if (!Csrf::validateRequest($request)) {
            $this->flash('error', 'Invalid CSRF token.');
            $this->redirect('/admin/community');
        }
        $postModel = new CommunityPostModel();
        $post = $postModel->find((int)$params['id']);
        if ($post) {
            $newStatus = $post['is_hidden'] ? 0 : 1;
            $postModel->update((int)$params['id'], ['is_hidden' => $newStatus]);
            (new AuditLog())->log('community_post_hidden', "Post #{$params['id']} " . ($newStatus ? 'hidden' : 'unhidden'), Auth::id('admin'), $request->ip());
            $this->flash('success', $newStatus ? 'Post hidden.' : 'Post unhidden.');
        }
        $this->redirect('/admin/community');
    }

    public function featurePost(Request $request, array $params): void
    {
        $this->requireAuth('admin');
        if (!Csrf::validateRequest($request)) {
            $this->flash('error', 'Invalid CSRF token.');
            $this->redirect('/admin/community');
        }
        $postModel = new CommunityPostModel();
        $post = $postModel->find((int)$params['id']);
        if ($post) {
            $newVal = $post['is_featured'] ? 0 : 1;
            $postModel->update((int)$params['id'], ['is_featured' => $newVal]);
            (new AuditLog())->log('community_post_featured', "Post #{$params['id']} " . ($newVal ? 'featured' : 'unfeatured'), Auth::id('admin'), $request->ip());
            $this->flash('success', $newVal ? 'Post featured.' : 'Post unfeatured.');
        }
        $this->redirect('/admin/community');
    }
}
