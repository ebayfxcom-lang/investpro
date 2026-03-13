<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class WithdrawalMethodModel extends Model
{
    protected string $table = 'withdrawal_methods';

    public function getActiveMethods(): array
    {
        try {
            return $this->findAll("status = 'active'", [], 'sort_order ASC, id ASC');
        } catch (\Throwable) {
            return [];
        }
    }

    public function getAllMethods(): array
    {
        try {
            return $this->findAll('', [], 'sort_order ASC, id ASC');
        } catch (\Throwable) {
            return [];
        }
    }
}
