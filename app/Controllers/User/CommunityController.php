<?php
declare(strict_types=1);

namespace App\Controllers\User;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\CommunityPostModel;
use App\Models\CommunityCommentModel;
use App\Models\CommunityLikeModel;
use App\Models\RestrictedKeywordModel;
use App\Models\SettingsModel;

class CommunityController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('user');

        $settingsModel = new SettingsModel();
        if (!$settingsModel->get('community_enabled', '0')) {
            $this->flash('error', 'Community feature is not currently available.');
            $this->redirect('/user/dashboard');
        }

        $page      = (int)($request->get('page', 1));
        $postModel = new CommunityPostModel();
        $feed      = $postModel->getFeed($page, 20);

        $commentModel = new CommunityCommentModel();
        foreach ($feed['items'] as &$post) {
            $post['comments'] = $commentModel->getByPost((int)$post['id']);
        }
        unset($post);

        $authUser = Auth::user('user');
        $this->view('user/community/index', [
            'title'    => 'Community Square',
            'feed'     => $feed,
            'authUser' => $authUser,
        ]);
    }

    public function create(Request $request): void
    {
        $this->requireAuth('user');

        $settingsModel = new SettingsModel();
        if (!$settingsModel->get('community_enabled', '0')) {
            $this->json(['success' => false, 'error' => 'Community feature is disabled.'], 403);
            return;
        }

        if (!Csrf::validateRequest($request)) {
            $this->json(['success' => false, 'error' => 'Invalid CSRF token.'], 403);
            return;
        }

        $userId  = (int)Auth::id('user');
        $content = trim($request->post('content', ''));

        if (strlen($content) < 5) {
            $this->json(['success' => false, 'error' => 'Post must be at least 5 characters.'], 422);
            return;
        }
        if (strlen($content) > 1000) {
            $this->json(['success' => false, 'error' => 'Post must be under 1000 characters.'], 422);
            return;
        }

        // Basic profanity/spam filter
        $content = $this->sanitizeContent($content);

        $keywordModel = new RestrictedKeywordModel();
        $status = $keywordModel->containsRestricted($content) ? 'pending' : 'active';

        $postModel = new CommunityPostModel();
        $postId    = $postModel->create([
            'user_id'    => $userId,
            'content'    => $content,
            'is_bot'     => 0,
            'status'     => $status,
            'created_at' => date('Y-m-d H:i:s'),
        ]);

        (new AuditLog())->log('community_post_created', "Post #{$postId} created", $userId, $request->ip());
        $this->json(['success' => true, 'post_id' => $postId]);
    }

    public function like(Request $request): void
    {
        $this->requireAuth('user');

        if (!Csrf::validateRequest($request)) {
            $this->json(['success' => false, 'error' => 'Invalid CSRF token.'], 403);
            return;
        }

        $userId    = (int)Auth::id('user');
        $postId    = (int)$request->post('post_id', 0);
        $likeModel = new CommunityLikeModel();
        $liked     = $likeModel->toggle($postId, $userId);

        $this->json(['success' => true, 'liked' => $liked]);
    }

    public function comment(Request $request): void
    {
        $this->requireAuth('user');

        $settingsModel = new SettingsModel();
        if (!$settingsModel->get('community_enabled', '0')) {
            $this->json(['success' => false, 'error' => 'Community feature is disabled.'], 403);
            return;
        }

        if (!Csrf::validateRequest($request)) {
            $this->json(['success' => false, 'error' => 'Invalid CSRF token.'], 403);
            return;
        }

        $userId  = (int)Auth::id('user');
        $postId  = (int)$request->post('post_id', 0);
        $content = trim($request->post('content', ''));

        if (strlen($content) < 2 || strlen($content) > 500) {
            $this->json(['success' => false, 'error' => 'Comment must be 2–500 characters.'], 422);
            return;
        }

        $content       = $this->sanitizeContent($content);
        $commentModel  = new CommunityCommentModel();
        $commentId     = $commentModel->create([
            'post_id'    => $postId,
            'user_id'    => $userId,
            'content'    => $content,
            'status'     => 'active',
            'created_at' => date('Y-m-d H:i:s'),
        ]);

        $this->json(['success' => true, 'comment_id' => $commentId, 'content' => $content]);
    }

    private function sanitizeContent(string $content): string
    {
        // Strip HTML tags and encode special chars
        return htmlspecialchars(strip_tags($content), ENT_QUOTES, 'UTF-8');
    }
}
