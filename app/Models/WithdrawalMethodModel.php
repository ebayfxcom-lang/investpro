<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class WithdrawalMethodModel extends Model
{
    protected string $table = 'withdrawal_methods';

    public function getActiveMethods(): array
    {
        return $this->findAll("status = 'active'", [], 'sort_order ASC, id ASC');
    }

    public function getAllMethods(): array
    {
        return $this->findAll('', [], 'sort_order ASC, id ASC');
    }
}
