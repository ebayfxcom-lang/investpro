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

    public function getCategories(): array
    {
        return ['general', 'account', 'deposits', 'withdrawals', 'referral', 'investments', 'security'];
    }
}
