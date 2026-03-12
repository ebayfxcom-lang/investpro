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
}
