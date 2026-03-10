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

    public function updateRate(string $code, float $rateToUsd): void
    {
        $this->db->query(
            "UPDATE currencies SET rate_to_usd = ?, updated_at = NOW() WHERE code = ?",
            [$rateToUsd, strtoupper($code)]
        );
    }

    public function getRateToUsd(string $code): float
    {
        if (strtoupper($code) === 'USD') {
            return 1.0;
        }
        $row = $this->findByCode($code);
        return $row ? (float)$row['rate_to_usd'] : 1.0;
    }

    public function convertToUsd(float $amount, string $fromCurrency): float
    {
        $rate = $this->getRateToUsd($fromCurrency);
        return $rate > 0 ? $amount / $rate : $amount;
    }

    public function convertFromUsd(float $usdAmount, string $toCurrency): float
    {
        $rate = $this->getRateToUsd($toCurrency);
        return $usdAmount * $rate;
    }

    public function convertToEur(float $amount, string $fromCurrency): float
    {
        $usdAmount = $this->convertToUsd($amount, $fromCurrency);
        $eurRate   = $this->getRateToUsd('EUR');
        return $eurRate > 0 ? $usdAmount * $eurRate : $usdAmount;
    }

    public function getStats(): array
    {
        return [
            'total'  => $this->count(),
            'active' => $this->count('status = ?', ['active']),
            'fiat'   => $this->count('type = ?', ['fiat']),
            'crypto' => $this->count('type = ?', ['crypto']),
        ];
    }
}
