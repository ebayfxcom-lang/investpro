<?php
declare(strict_types=1);

namespace App\Services;

use App\Models\CurrencyModel;

class ConversionService
{
    private CurrencyModel $currencyModel;

    public function __construct()
    {
        $this->currencyModel = new CurrencyModel();
    }

    /**
     * Build a conversion snapshot for a given amount and currency.
     * Returns an array with usd_amount, eur_amount, and rate_snapshot.
     */
    public function buildSnapshot(float $amount, string $currency): array
    {
        $currency = strtoupper($currency);

        $rateToUsd = $this->currencyModel->getRateToUsd($currency);
        $usdAmount = $this->currencyModel->convertToUsd($amount, $currency);
        $eurAmount = $this->currencyModel->convertToEur($amount, $currency);

        // Get EUR rate for snapshot
        $eurRateToUsd = $this->currencyModel->getRateToUsd('EUR');

        $snapshot = [
            'from_currency' => $currency,
            'amount'        => $amount,
            'rate_to_usd'   => $rateToUsd,
            'eur_rate_to_usd' => $eurRateToUsd,
            'usd_amount'    => round($usdAmount, 8),
            'eur_amount'    => round($eurAmount, 8),
            'snapshot_at'   => date('Y-m-d H:i:s'),
        ];

        return [
            'usd_amount'    => round($usdAmount, 8),
            'eur_amount'    => round($eurAmount, 8),
            'rate_snapshot' => json_encode($snapshot),
        ];
    }

    /**
     * Convert an amount between two currencies using current rates.
     */
    public function convert(float $amount, string $from, string $to): float
    {
        $from = strtoupper($from);
        $to   = strtoupper($to);
        if ($from === $to) {
            return $amount;
        }
        $usdAmount = $this->currencyModel->convertToUsd($amount, $from);
        return $this->currencyModel->convertFromUsd($usdAmount, $to);
    }

    /**
     * Get all current rates relative to USD.
     */
    public function getAllRates(): array
    {
        $currencies = $this->currencyModel->getActiveCurrencies();
        $rates = [];
        foreach ($currencies as $c) {
            $rates[$c['code']] = (float)$c['rate_to_usd'];
        }
        return $rates;
    }
}
