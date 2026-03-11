<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class NewsletterModel extends Model
{
    protected string $table = 'newsletters';

    public function getSent(): array
    {
        return $this->findAll("status = 'sent'", [], 'sent_at DESC');
    }

    public function getDrafts(): array
    {
        return $this->findAll("status = 'draft'", [], 'created_at DESC');
    }

    public function markSent(int $id, int $sentCount, ?int $sentByUserId = null, ?string $senderName = null): void
    {
        $data = [
            'status'     => 'sent',
            'sent_at'    => date('Y-m-d H:i:s'),
            'sent_count' => $sentCount,
            'updated_at' => date('Y-m-d H:i:s'),
        ];
        if ($sentByUserId !== null) {
            $data['sent_by'] = $sentByUserId;
        }
        if ($senderName !== null) {
            $data['sender_name'] = $senderName;
        }
        $this->update($id, $data);
    }
}
