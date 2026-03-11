<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class CustomPageModel extends Model
{
    protected string $table = 'custom_pages';

    public function getPublished(): array
    {
        return $this->findAll("status = 'published'", [], 'title ASC');
    }

    public function findBySlug(string $slug): ?array
    {
        return $this->db->fetchOne("SELECT * FROM custom_pages WHERE slug = ?", [$slug]);
    }

    public function publish(int $id): void
    {
        $this->update($id, ['status' => 'published', 'updated_at' => date('Y-m-d H:i:s')]);
    }

    public function unpublish(int $id): void
    {
        $this->update($id, ['status' => 'draft', 'updated_at' => date('Y-m-d H:i:s')]);
    }

    public function generateSlug(string $title): string
    {
        $slug = strtolower(preg_replace('/[^a-z0-9]+/i', '-', trim($title)));
        $slug = trim($slug, '-');
        // Ensure uniqueness
        $base  = $slug;
        $count = 1;
        while ($this->findBySlug($slug)) {
            $slug = $base . '-' . $count;
            $count++;
        }
        return $slug;
    }
}
