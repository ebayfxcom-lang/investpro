<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class FaqModel extends Model
{
    protected string $table = 'faq';

    public function getActive(): array
    {
        return $this->findAll("status = 'active'", [], 'sort_order ASC, id ASC');
    }

    public function getByCategory(string $category): array
    {
        return $this->findAll("status = 'active' AND category = ?", [$category], 'sort_order ASC, id ASC');
    }

    /**
     * Returns active categories from faq_categories table.
     * Falls back to built-in list if the table does not yet exist.
     */
    public function getCategories(): array
    {
        try {
            $rows = $this->db->fetchAll(
                "SELECT * FROM faq_categories ORDER BY sort_order ASC, name ASC"
            );
            if (!empty($rows)) {
                return $rows;
            }
        } catch (\Throwable) {
            // Table may not exist yet; fall through to built-in list
        }

        // Built-in fallback
        return array_map(fn($slug) => [
            'id'         => null,
            'name'       => ucfirst($slug),
            'slug'       => $slug,
            'status'     => 'active',
            'sort_order' => 0,
        ], $this->getBuiltinCategorySlugs());
    }

    /**
     * Returns only active categories.
     */
    public function getActiveCategories(): array
    {
        try {
            $rows = $this->db->fetchAll(
                "SELECT * FROM faq_categories WHERE status = 'active' ORDER BY sort_order ASC, name ASC"
            );
            if ($rows !== []) {
                return $rows;
            }
        } catch (\Throwable) {
            // fall through
        }

        return array_map(fn($slug) => [
            'id'         => null,
            'name'       => ucfirst($slug),
            'slug'       => $slug,
            'status'     => 'active',
            'sort_order' => 0,
        ], $this->getBuiltinCategorySlugs());
    }

    private function getBuiltinCategorySlugs(): array
    {
        return ['general', 'account', 'deposits', 'withdrawals', 'referral', 'investments', 'security'];
    }
}

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
