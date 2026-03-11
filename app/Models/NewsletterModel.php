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

    public function markSent(int $id, int $sentCount): void
    {
        $this->update($id, [
            'status'     => 'sent',
            'sent_at'    => date('Y-m-d H:i:s'),
            'sent_count' => $sentCount,
            'updated_at' => date('Y-m-d H:i:s'),
        ]);
    }
}
