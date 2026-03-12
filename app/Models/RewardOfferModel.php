<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class RewardOfferModel extends Model
{
    protected string $table = 'reward_offers';

    public function getActiveOffers(): array
    {
        $now = date('Y-m-d H:i:s');
        return $this->db->fetchAll(
            "SELECT * FROM reward_offers
             WHERE status = 'active'
               AND (start_at IS NULL OR start_at <= ?)
               AND (end_at IS NULL OR end_at >= ?)
             ORDER BY sort_order ASC, id ASC",
            [$now, $now]
        );
    }

    public function getExpiredOffers(): array
    {
        $now = date('Y-m-d H:i:s');
        return $this->db->fetchAll(
            "SELECT * FROM reward_offers
             WHERE end_at < ? OR status = 'expired'
             ORDER BY end_at DESC",
            [$now]
        );
    }

    public function incrementImpressions(int $offerId): void
    {
        $this->db->query("UPDATE reward_offers SET impressions = impressions + 1 WHERE id = ?", [$offerId]);
    }

    public function getClaimCount(int $offerId): int
    {
        $row = $this->db->fetchOne("SELECT COUNT(*) as cnt FROM reward_claims WHERE offer_id = ?", [$offerId]);
        return (int)($row['cnt'] ?? 0);
    }

    public function adminPaginate(int $page = 1, int $perPage = 20): array
    {
        $total  = $this->count();
        $offset = ($page - 1) * $perPage;
        $items  = $this->findAll('', [], 'sort_order ASC, id DESC', $perPage, $offset);
        return [
            'items'       => $items,
            'total'       => $total,
            'page'        => $page,
            'per_page'    => $perPage,
            'total_pages' => (int)ceil($total / $perPage),
        ];
    }
}
