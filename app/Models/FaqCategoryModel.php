<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class FaqCategoryModel extends Model
{
    protected string $table = 'faq_categories';

    public function findBySlug(string $slug): ?array
    {
        return $this->db->fetchOne(
            "SELECT * FROM faq_categories WHERE slug = ?",
            [$slug]
        );
    }

    public function slugify(string $name): string
    {
        $slug = strtolower(trim($name));
        $slug = preg_replace('/[^a-z0-9]+/', '-', $slug);
        return trim($slug, '-');
    }
}
