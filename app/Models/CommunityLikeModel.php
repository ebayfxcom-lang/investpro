<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class CommunityLikeModel extends Model
{
    protected string $table = 'community_likes';

    public function hasLiked(int $postId, int $userId): bool
    {
        $row = $this->db->fetchOne(
            "SELECT id FROM community_likes WHERE post_id = ? AND user_id = ?",
            [$postId, $userId]
        );
        return (bool)$row;
    }

    public function toggle(int $postId, int $userId): bool
    {
        if ($this->hasLiked($postId, $userId)) {
            $this->db->query("DELETE FROM community_likes WHERE post_id = ? AND user_id = ?", [$postId, $userId]);
            $this->db->query("UPDATE community_posts SET likes_count = GREATEST(0, likes_count - 1) WHERE id = ?", [$postId]);
            return false;
        } else {
            $this->db->query(
                "INSERT IGNORE INTO community_likes (post_id, user_id, created_at) VALUES (?, ?, NOW())",
                [$postId, $userId]
            );
            $this->db->query("UPDATE community_posts SET likes_count = likes_count + 1 WHERE id = ?", [$postId]);
            return true;
        }
    }
}
