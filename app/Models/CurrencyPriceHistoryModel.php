<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class CurrencyPriceHistoryModel extends Model
{
    protected string $table = 'currency_price_history';

    public function recordPrice(string $code, float $priceUsd, ?float $priceEur = null, string $source = 'api'): void
    {
        $this->create([
            'currency_code' => strtoupper($code),
            'price_usd'     => $priceUsd,
            'price_eur'     => $priceEur,
            'source'        => $source,
            'recorded_at'   => date('Y-m-d H:i:s'),
        ]);
    }

    public function getLatestPrice(string $code): ?array
    {
        return $this->db->fetchOne(
            "SELECT * FROM currency_price_history WHERE currency_code = ? ORDER BY recorded_at DESC LIMIT 1",
            [strtoupper($code)]
        );
    }

    public function getPriceHistory(string $code, int $days = 30): array
    {
        return $this->db->fetchAll(
            "SELECT * FROM currency_price_history WHERE currency_code = ? AND recorded_at >= DATE_SUB(NOW(), INTERVAL ? DAY) ORDER BY recorded_at ASC",
            [strtoupper($code), $days]
        );
    }

    public function getAllLatestPrices(): array
    {
        return $this->db->fetchAll(
            "SELECT cph.* FROM currency_price_history cph
             INNER JOIN (
               SELECT currency_code, MAX(recorded_at) as max_date
               FROM currency_price_history GROUP BY currency_code
             ) latest ON cph.currency_code = latest.currency_code AND cph.recorded_at = latest.max_date"
        );
    }
}
