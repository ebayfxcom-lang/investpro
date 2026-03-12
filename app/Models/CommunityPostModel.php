<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class CommunityPostModel extends Model
{
    protected string $table = 'community_posts';

    public function getFeed(int $page = 1, int $perPage = 20): array
    {
        $total  = (int)($this->db->fetchOne(
            "SELECT COUNT(*) as cnt FROM community_posts WHERE status = 'active'"
        )['cnt'] ?? 0);
        $offset = ($page - 1) * $perPage;
        $items  = $this->db->fetchAll(
            "SELECT p.*, u.username,
                    (SELECT COUNT(*) FROM community_comments c WHERE c.post_id = p.id AND c.status = 'active') AS comment_count
             FROM community_posts p
             LEFT JOIN users u ON p.user_id = u.id
             WHERE p.status = 'active'
             ORDER BY p.created_at DESC
             LIMIT {$perPage} OFFSET {$offset}"
        );
        return [
            'items'       => $items,
            'total'       => $total,
            'page'        => $page,
            'per_page'    => $perPage,
            'total_pages' => (int)ceil($total / $perPage),
        ];
    }

    public function getPostWithUser(int $postId): ?array
    {
        return $this->db->fetchOne(
            "SELECT p.*, u.username FROM community_posts p
             LEFT JOIN users u ON p.user_id = u.id
             WHERE p.id = ? AND p.status = 'active'",
            [$postId]
        );
    }

    public function adminPaginate(int $page = 1, int $perPage = 20): array
    {
        $total  = (int)($this->db->fetchOne("SELECT COUNT(*) as cnt FROM community_posts")['cnt'] ?? 0);
        $offset = ($page - 1) * $perPage;
        $items  = $this->db->fetchAll(
            "SELECT p.*, u.username
             FROM community_posts p
             LEFT JOIN users u ON p.user_id = u.id
             ORDER BY p.created_at DESC
             LIMIT {$perPage} OFFSET {$offset}"
        );
        return [
            'items'       => $items,
            'total'       => $total,
            'page'        => $page,
            'per_page'    => $perPage,
            'total_pages' => (int)ceil($total / $perPage),
        ];
    }
}
