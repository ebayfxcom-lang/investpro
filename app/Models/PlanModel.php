<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class PlanModel extends Model
{
    protected string $table = 'plans';

    public function getActivePlans(): array
    {
        return $this->findAll('status = ?', ['active'], 'sort_order ASC, id ASC');
    }

    public function getStats(): array
    {
        return [
            'total'  => $this->count(),
            'active' => $this->count('status = ?', ['active']),
        ];
    }
}
