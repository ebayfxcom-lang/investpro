<?php
declare(strict_types=1);

namespace App\Services;

use App\Models\BotProfileModel;
use App\Models\CommunityPostModel;
use App\Models\CommunityCommentModel;
use App\Models\CommunityLikeModel;
use App\Models\UserModel;
use App\Core\Database;

class BotService
{
    private BotProfileModel      $botModel;
    private CommunityPostModel   $postModel;
    private CommunityCommentModel $commentModel;
    private CommunityLikeModel   $likeModel;

    // Sample bot posts by tone category
    private array $postTemplates = [
        'general' => [
            "Great returns this month! 🚀 This platform keeps delivering.",
            "Just checked my portfolio — steady growth as expected. 📈",
            "Another successful investment cycle. Love the transparency here!",
            "Consistently impressed by the performance. Highly recommend!",
            "Compounding interest is truly magical. Watching my earnings grow daily!",
        ],
        'financial' => [
            "Diversification is key. Spreading across multiple plans has been smart.",
            "The ROI here beats most traditional savings accounts by a wide margin.",
            "Passive income is the goal. This platform is helping me get there.",
            "Risk-adjusted returns look excellent this quarter.",
            "My financial advisor was skeptical, but the results speak for themselves.",
        ],
        'motivational' => [
            "Don't wait for the perfect moment — start investing today! 💪",
            "Financial freedom starts with a single step. This platform made it easy.",
            "Small consistent deposits lead to big results over time. Keep going!",
            "Every day you delay is a day of potential earnings lost. Start now!",
            "Building wealth is a journey, not a destination. Enjoying every milestone!",
        ],
        'community' => [
            "Shoutout to the support team — always quick and helpful! 👏",
            "The community here is amazing. Everyone so supportive!",
            "Loving the transparency of this platform. Keep it up!",
            "Referred my brother last week. He's already seeing results!",
            "This is the most trustworthy investment platform I've used.",
        ],
    ];

    private array $commentTemplates = [
        "Totally agree with this! 👍",
        "Same experience here. Keep it up!",
        "This is inspiring. Thanks for sharing!",
        "100%! The results have been amazing.",
        "Great post! More people need to hear this.",
        "Congrats on the gains! 🎉",
        "Couldn't have said it better myself.",
        "This platform is truly exceptional.",
        "You're absolutely right. Consistency pays off!",
        "Love seeing positive experiences like this!",
    ];

    public function __construct()
    {
        $this->botModel     = new BotProfileModel();
        $this->postModel    = new CommunityPostModel();
        $this->commentModel = new CommunityCommentModel();
        $this->likeModel    = new CommunityLikeModel();
    }

    /**
     * Run all bot activity: posting, liking, commenting.
     */
    public function run(): array
    {
        $stats = ['posts' => 0, 'likes' => 0, 'comments' => 0];

        $botsToPost = $this->botModel->getDueForPosting();
        foreach ($botsToPost as $bot) {
            if ($this->botPost($bot)) {
                $stats['posts']++;
            }
        }

        $activeBots = $this->botModel->getActive();
        if (!empty($activeBots)) {
            $stats['likes']    = $this->runLikes($activeBots);
            $stats['comments'] = $this->runComments($activeBots);
        }

        return $stats;
    }

    private function botPost(array $bot): bool
    {
        try {
            $tone = $bot['tone_category'] ?? 'general';
            $templates = $this->postTemplates[$tone] ?? $this->postTemplates['general'];
            $content   = $templates[array_rand($templates)];

            // Append keywords if configured
            $keywords = json_decode($bot['keywords'] ?? '[]', true);
            if (!empty($keywords)) {
                $kw = $keywords[array_rand($keywords)];
                // Only append if it makes the sentence more natural
                if (strlen($content) + strlen($kw) < 200) {
                    $content .= ' #' . preg_replace('/\s+/', '', $kw);
                }
            }

            $this->postModel->create([
                'user_id'    => null,
                'bot_id'     => (int)$bot['id'],
                'content'    => $content,
                'is_bot'     => 1,
                'status'     => 'active',
                'created_at' => date('Y-m-d H:i:s'),
            ]);

            $this->botModel->update((int)$bot['id'], ['last_posted_at' => date('Y-m-d H:i:s')]);
            return true;
        } catch (\Throwable $e) {
            error_log('BotService botPost error: ' . $e->getMessage());
            return false;
        }
    }

    private function runLikes(array $bots): int
    {
        $count = 0;
        try {
            $db = Database::getInstance();

            // Get team user posts → bots like 100%
            $teamPosts = $db->fetchAll(
                "SELECT p.id FROM community_posts p
                 INNER JOIN users u ON u.id = p.user_id
                 WHERE p.status = 'active' AND u.team_role_id IS NOT NULL
                   AND p.is_bot = 0
                 ORDER BY p.created_at DESC LIMIT 20"
            );
            foreach ($teamPosts as $post) {
                foreach ($bots as $bot) {
                    if (!$this->likeModel->hasLiked((int)$post['id'], null, (int)$bot['id'])) {
                        $this->likeModel->botLike((int)$post['id'], (int)$bot['id']);
                        $count++;
                    }
                }
            }

            // Get recent normal user posts → bots like ~10%
            $normalPosts = $db->fetchAll(
                "SELECT p.id FROM community_posts p
                 LEFT JOIN users u ON u.id = p.user_id
                 WHERE p.status = 'active' AND p.is_bot = 0
                   AND (u.team_role_id IS NULL OR p.user_id IS NULL)
                 ORDER BY p.created_at DESC LIMIT 50"
            );
            foreach ($normalPosts as $post) {
                if (random_int(1, 10) !== 1) {
                    continue; // ~10% chance
                }
                $bot = $bots[array_rand($bots)];
                if (!$this->likeModel->hasLiked((int)$post['id'], null, (int)$bot['id'])) {
                    $this->likeModel->botLike((int)$post['id'], (int)$bot['id']);
                    $count++;
                }
            }
        } catch (\Throwable $e) {
            error_log('BotService runLikes error: ' . $e->getMessage());
        }
        return $count;
    }

    private function runComments(array $bots): int
    {
        $count = 0;
        try {
            $db = Database::getInstance();

            // Comment on recent team posts
            $teamPosts = $db->fetchAll(
                "SELECT p.id FROM community_posts p
                 INNER JOIN users u ON u.id = p.user_id
                 WHERE p.status = 'active' AND u.team_role_id IS NOT NULL
                   AND p.is_bot = 0
                 ORDER BY p.created_at DESC LIMIT 10"
            );
            foreach ($teamPosts as $post) {
                $bot     = $bots[array_rand($bots)];
                $already = $db->fetchOne(
                    "SELECT id FROM community_comments WHERE post_id = ? AND bot_id = ? AND status = 'active' LIMIT 1",
                    [(int)$post['id'], (int)$bot['id']]
                );
                if (!$already) {
                    $text = $this->commentTemplates[array_rand($this->commentTemplates)];
                    $this->commentModel->create([
                        'post_id'    => (int)$post['id'],
                        'user_id'    => null,
                        'bot_id'     => (int)$bot['id'],
                        'content'    => $text,
                        'status'     => 'active',
                        'created_at' => date('Y-m-d H:i:s'),
                    ]);
                    $count++;
                }
            }

            // Randomly comment on recent normal posts (~20% chance)
            $normalPosts = $db->fetchAll(
                "SELECT p.id FROM community_posts p
                 WHERE p.status = 'active' AND p.is_bot = 0
                 ORDER BY p.created_at DESC LIMIT 30"
            );
            foreach ($normalPosts as $post) {
                if (random_int(1, 5) !== 1) {
                    continue; // ~20% chance
                }
                $bot     = $bots[array_rand($bots)];
                $already = $db->fetchOne(
                    "SELECT id FROM community_comments WHERE post_id = ? AND bot_id = ? AND status = 'active' LIMIT 1",
                    [(int)$post['id'], (int)$bot['id']]
                );
                if (!$already) {
                    $text = $this->commentTemplates[array_rand($this->commentTemplates)];
                    $this->commentModel->create([
                        'post_id'    => (int)$post['id'],
                        'user_id'    => null,
                        'bot_id'     => (int)$bot['id'],
                        'content'    => $text,
                        'status'     => 'active',
                        'created_at' => date('Y-m-d H:i:s'),
                    ]);
                    $count++;
                }
            }
        } catch (\Throwable $e) {
            error_log('BotService runComments error: ' . $e->getMessage());
        }
        return $count;
    }
}
