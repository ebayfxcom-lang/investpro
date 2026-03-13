<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class NewsletterGuestModel extends Model
{
    protected string $table = 'newsletter_guests';

    public function subscribe(string $email, ?string $whatsapp = null): string
    {
        $existing = $this->findBy(['email' => $email]);
        if ($existing) {
            if ($existing['status'] === 'unsubscribed') {
                $this->update((int)$existing['id'], ['status' => 'subscribed', 'whatsapp' => $whatsapp]);
                return 'resubscribed';
            }
            return 'already_subscribed';
        }
        $this->create([
            'email'       => $email,
            'whatsapp'    => $whatsapp,
            'status'      => 'subscribed',
            'token'       => bin2hex(random_bytes(32)),
            'created_at'  => date('Y-m-d H:i:s'),
        ]);
        return 'subscribed';
    }

    public function unsubscribeByToken(string $token): bool
    {
        $row = $this->db->fetchOne("SELECT * FROM newsletter_guests WHERE token = ?", [$token]);
        if ($row) {
            $this->update((int)$row['id'], ['status' => 'unsubscribed']);
            return true;
        }
        return false;
    }

    public function getActive(): array
    {
        return $this->findAll("status = 'subscribed'", [], 'created_at DESC');
    }

    /**
     * Get guest-only subscribers (subscribers whose email is NOT in the users table).
     */
    public function getNonUserSubscribers(): array
    {
        try {
            return $this->db->fetchAll(
                "SELECT ng.* FROM newsletter_guests ng
                 WHERE ng.status = 'subscribed'
                   AND ng.email NOT IN (SELECT email FROM users)
                 ORDER BY ng.created_at DESC"
            );
        } catch (\Throwable) {
            return [];
        }
    }
}
