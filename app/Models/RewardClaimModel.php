<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class RewardClaimModel extends Model
{
    protected string $table = 'reward_claims';

    public function hasClaimed(int $offerId, int $userId): bool
    {
        try {
            $row = $this->db->fetchOne(
                "SELECT id FROM reward_claims WHERE offer_id = ? AND user_id = ?",
                [$offerId, $userId]
            );
            return (bool)$row;
        } catch (\Throwable) {
            return false;
        }
    }

    public function claim(int $offerId, int $userId): bool
    {
        if ($this->hasClaimed($offerId, $userId)) {
            return false;
        }
        $this->create([
            'offer_id'   => $offerId,
            'user_id'    => $userId,
            'status'     => 'completed',
            'claimed_at' => date('Y-m-d H:i:s'),
        ]);
        return true;
    }

    public function getUserClaims(int $userId): array
    {
        try {
            return $this->db->fetchAll(
                "SELECT rc.*, ro.title, ro.reward_type, ro.reward_value
                 FROM reward_claims rc
                 JOIN reward_offers ro ON rc.offer_id = ro.id
                 WHERE rc.user_id = ?
                 ORDER BY rc.claimed_at DESC",
                [$userId]
            );
        } catch (\Throwable) {
            return [];
        }
    }

    /**
     * Get all claims for admin view (with user info and offer info).
     */
    public function getAdminClaims(int $limit = 100): array
    {
        try {
            return $this->db->fetchAll(
                "SELECT rc.*, ro.title as offer_title, ro.eligibility_rule, ro.rule_value,
                        u.username, u.email
                 FROM reward_claims rc
                 JOIN reward_offers ro ON rc.offer_id = ro.id
                 JOIN users u ON rc.user_id = u.id
                 ORDER BY rc.claimed_at DESC
                 LIMIT ?",
                [$limit]
            );
        } catch (\Throwable) {
            return [];
        }
    }
}
