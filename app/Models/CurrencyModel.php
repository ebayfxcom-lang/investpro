<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class CurrencyModel extends Model
{
    protected string $table = 'currencies';

    public function getActiveCurrencies(): array
    {
        return $this->findAll('status = ?', ['active'], 'sort_order ASC, code ASC');
    }

    public function findByCode(string $code): ?array
    {
        return $this->db->fetchOne("SELECT * FROM currencies WHERE code = ?", [strtoupper($code)]);
    }

    public function getExchangeRates(): array
    {
        return $this->db->fetchAll("SELECT code, rate_to_usd FROM currencies WHERE status = 'active'");
    }
}
