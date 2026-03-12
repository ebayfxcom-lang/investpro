<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class NewsletterGuestModel extends Model
{
    protected string $table = 'newsletter_guests';

    public function subscribe(string $email, ?string $whatsapp = null): bool
    {
        $existing = $this->findBy(['email' => $email]);
        if ($existing) {
            if ($existing['status'] === 'unsubscribed') {
                $this->update((int)$existing['id'], ['status' => 'subscribed', 'whatsapp' => $whatsapp]);
            }
            return true;
        }
        $this->create([
            'email'       => $email,
            'whatsapp'    => $whatsapp,
            'status'      => 'subscribed',
            'token'       => bin2hex(random_bytes(32)),
            'created_at'  => date('Y-m-d H:i:s'),
        ]);
        return true;
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
}
