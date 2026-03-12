<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class CommunityCommentModel extends Model
{
    protected string $table = 'community_comments';

    public function getByPost(int $postId): array
    {
        return $this->db->fetchAll(
            "SELECT c.*, u.username FROM community_comments c
             LEFT JOIN users u ON c.user_id = u.id
             WHERE c.post_id = ? AND c.status = 'active'
             ORDER BY c.created_at ASC",
            [$postId]
        );
    }
}
