<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class BotProfileModel extends Model
{
    protected string $table = 'bot_profiles';

    public function getActive(): array
    {
        return $this->findAll("status = 'active'", [], 'id ASC');
    }

    public function getDueForPosting(): array
    {
        return $this->db->fetchAll(
            "SELECT * FROM bot_profiles
             WHERE status = 'active'
               AND (last_posted_at IS NULL
                    OR last_posted_at <= DATE_SUB(NOW(), INTERVAL post_frequency MINUTE))"
        );
    }
}
