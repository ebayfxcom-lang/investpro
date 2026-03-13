<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class CommunityCommentModel extends Model
{
    protected string $table = 'community_comments';

    public function getByPost(int $postId): array
    {
        try {
            return $this->db->fetchAll(
                "SELECT c.*, COALESCE(u.username, b.display_name, 'Bot') AS username
                 FROM community_comments c
                 LEFT JOIN users u ON c.user_id = u.id
                 LEFT JOIN bot_profiles b ON c.bot_id = b.id
                 WHERE c.post_id = ? AND c.status = 'active'
                 ORDER BY c.created_at ASC",
                [$postId]
            );
        } catch (\Throwable) {
            return [];
        }
    }
}
