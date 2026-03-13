<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class SeoPageModel extends Model
{
    protected string $table = 'seo_pages';

    public function getAllPages(): array
    {
        try {
            return $this->findAll('', [], 'page_key ASC');
        } catch (\Throwable) {
            return [];
        }
    }

    public function getByKey(string $key): ?array
    {
        try {
            return $this->findBy(['page_key' => $key]);
        } catch (\Throwable) {
            return null;
        }
    }

    public function upsert(string $key, array $data): void
    {
        $existing = $this->getByKey($key);
        if ($existing) {
            $this->update((int)$existing['id'], $data);
        } else {
            $data['page_key'] = $key;
            $this->create($data);
        }
    }
}
