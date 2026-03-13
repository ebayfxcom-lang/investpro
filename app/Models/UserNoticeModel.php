<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class UserNoticeModel extends Model
{
    protected string $table = 'user_notices';

    public function getActiveForUser(int $userId, string $accountType = 'normal', bool $hasDeposit = false): array
    {
        $now = date('Y-m-d H:i:s');
        try {
            $notices = $this->db->fetchAll(
                "SELECT n.* FROM user_notices n
                 WHERE n.status = 'published'
                   AND (n.starts_at IS NULL OR n.starts_at <= ?)
                   AND (n.ends_at IS NULL OR n.ends_at >= ?)
                   AND n.id NOT IN (
                       SELECT nr.notice_id FROM user_notice_reads nr WHERE nr.user_id = ?
                   )
                 ORDER BY n.created_at DESC",
                [$now, $now, $userId]
            );
        } catch (\Throwable) {
            // Tables may not exist yet; return empty notices
            return [];
        }

        return array_filter($notices, function ($notice) use ($accountType, $hasDeposit) {
            $t = $notice['target'];
            if ($t === 'all') return true;
            if ($t === 'deposited' && $hasDeposit) return true;
            if ($t === 'free' && !$hasDeposit) return true;
            if ($t === 'representatives' && $accountType === 'representative') return true;
            if ($t === 'leaders' && $accountType === 'team_leader') return true;
            if ($t === 'team' && in_array($accountType, ['representative','team_leader'])) return true;
            return false;
        });
    }

    public function markRead(int $noticeId, int $userId): void
    {
        try {
            $this->db->query(
                "INSERT IGNORE INTO user_notice_reads (notice_id, user_id) VALUES (?, ?)",
                [$noticeId, $userId]
            );
        } catch (\Throwable) {
            // Table may not exist yet; silently ignore
        }
    }

    public function adminPaginate(int $page = 1, int $perPage = 20): array
    {
        try {
            return $this->paginate($page, $perPage, '', [], 'id DESC');
        } catch (\Throwable) {
            return ['items' => [], 'total' => 0, 'page' => $page, 'per_page' => $perPage, 'total_pages' => 0];
        }
    }
}
