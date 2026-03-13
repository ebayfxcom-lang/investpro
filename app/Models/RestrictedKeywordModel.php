<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class RestrictedKeywordModel extends Model
{
    protected string $table = 'restricted_keywords';

    public function getAll(): array
    {
        return $this->findAll('', [], 'keyword ASC');
    }

    public function containsRestricted(string $content): bool
    {
        $keywords = $this->getAll();
        $lower    = mb_strtolower($content);
        foreach ($keywords as $kw) {
            if (str_contains($lower, mb_strtolower($kw['keyword']))) {
                return true;
            }
        }
        return false;
    }
}
