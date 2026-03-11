<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class ScamReportModel extends Model
{
    protected string $table = 'scam_reports';

    public function getPending(): array
    {
        return $this->findAll("status = 'pending'", [], 'created_at DESC');
    }

    public function getStats(): array
    {
        return [
            'total'     => $this->count(),
            'pending'   => $this->count("status = 'pending'"),
            'confirmed' => $this->count("status = 'confirmed'"),
            'dismissed' => $this->count("status = 'dismissed'"),
        ];
    }
}
