<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class NewsModel extends Model
{
    protected string $table = 'news';

    public function getPublished(): array
    {
        return $this->findAll("status = 'published'", [], 'published_at DESC, id DESC');
    }

    public function publish(int $id): void
    {
        $this->update($id, [
            'status'       => 'published',
            'published_at' => date('Y-m-d H:i:s'),
            'updated_at'   => date('Y-m-d H:i:s'),
        ]);
    }

    public function unpublish(int $id): void
    {
        $this->update($id, [
            'status'     => 'draft',
            'updated_at' => date('Y-m-d H:i:s'),
        ]);
    }
}
