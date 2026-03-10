<?php
declare(strict_types=1);

namespace App\Services;

use App\Models\CurrencyModel;
use App\Models\CurrencyPriceHistoryModel;

class CurrencyPriceService
{
    private CurrencyModel $currencyModel;
    private CurrencyPriceHistoryModel $priceHistoryModel;

    // CoinGecko IDs for common crypto symbols
    private const COINGECKO_IDS = [
        'BTC'  => 'bitcoin',
        'ETH'  => 'ethereum',
        'LTC'  => 'litecoin',
        'XRP'  => 'ripple',
        'USDT' => 'tether',
        'USDC' => 'usd-coin',
        'BNB'  => 'binancecoin',
        'SOL'  => 'solana',
        'ADA'  => 'cardano',
        'DOGE' => 'dogecoin',
        'TRX'  => 'tron',
        'MATIC'=> 'matic-network',
    ];

    // ECB / open exchange for fiat rates (use exchangerate.host free API)
    private const FIAT_API = 'https://open.er-api.com/v6/latest/USD';

    public function __construct()
    {
        $this->currencyModel     = new CurrencyModel();
        $this->priceHistoryModel = new CurrencyPriceHistoryModel();
    }

    /**
     * Sync all active currencies: crypto from CoinGecko, fiat from exchange rate API.
     * Returns summary of updated currencies.
     */
    public function syncAll(): array
    {
        $currencies = $this->currencyModel->getActiveCurrencies();
        $updated    = [];
        $failed     = [];

        $cryptos = array_filter($currencies, fn($c) => $c['type'] === 'crypto');
        $fiats   = array_filter($currencies, fn($c) => $c['type'] === 'fiat' && $c['code'] !== 'USD');

        // Sync crypto
        if (!empty($cryptos)) {
            $result = $this->syncCryptoPrices($cryptos);
            $updated = array_merge($updated, $result['updated']);
            $failed  = array_merge($failed, $result['failed']);
        }

        // Sync fiat
        if (!empty($fiats)) {
            $result = $this->syncFiatRates($fiats);
            $updated = array_merge($updated, $result['updated']);
            $failed  = array_merge($failed, $result['failed']);
        }

        return ['updated' => $updated, 'failed' => $failed];
    }

    private function syncCryptoPrices(array $cryptos): array
    {
        $updated = [];
        $failed  = [];

        // Build list of CoinGecko IDs
        $ids = [];
        $codeToId = [];
        foreach ($cryptos as $c) {
            $code = strtoupper($c['code']);
            if (isset(self::COINGECKO_IDS[$code])) {
                $ids[]          = self::COINGECKO_IDS[$code];
                $codeToId[$code] = self::COINGECKO_IDS[$code];
            }
        }

        if (empty($ids)) {
            return ['updated' => $updated, 'failed' => $failed];
        }

        $idsStr = implode(',', $ids);
        $url    = "https://api.coingecko.com/api/v3/simple/price?ids={$idsStr}&vs_currencies=usd,eur";

        $data = $this->fetchJson($url);
        if ($data === null) {
            foreach ($cryptos as $c) {
                $failed[] = $c['code'];
            }
            return ['updated' => $updated, 'failed' => $failed];
        }

        // Build reverse map: geckoId => code
        $idToCode = array_flip($codeToId);

        foreach ($data as $geckoId => $prices) {
            $code = $idToCode[$geckoId] ?? null;
            if (!$code) {
                continue;
            }
            $priceUsd = (float)($prices['usd'] ?? 0);
            $priceEur = (float)($prices['eur'] ?? 0);
            if ($priceUsd <= 0) {
                $failed[] = $code;
                continue;
            }
            // Convention: rate_to_usd = units of this currency per 1 USD
            // e.g. 1 BTC = 65000 USD → rate_to_usd = 1/65000 ≈ 0.0000154
            $rateToUsd = 1.0 / $priceUsd;
            $this->currencyModel->updateRate($code, $rateToUsd);
            $this->priceHistoryModel->recordPrice($code, $priceUsd, $priceEur > 0 ? $priceEur : null, 'coingecko');
            $updated[] = $code;
        }

        return ['updated' => $updated, 'failed' => $failed];
    }

    private function syncFiatRates(array $fiats): array
    {
        $updated = [];
        $failed  = [];

        $data = $this->fetchJson(self::FIAT_API);
        if ($data === null || !isset($data['rates'])) {
            foreach ($fiats as $f) {
                $failed[] = $f['code'];
            }
            return ['updated' => $updated, 'failed' => $failed];
        }

        $rates = $data['rates'];
        $eurRate = isset($rates['EUR']) ? (float)$rates['EUR'] : null;

        foreach ($fiats as $fiat) {
            $code = strtoupper($fiat['code']);
            if (!isset($rates[$code])) {
                $failed[] = $code;
                continue;
            }
            // Convention: rate_to_usd = units of this currency per 1 USD
            // open.er-api gives USD-based rates: $rates['EUR'] = 0.92 means 1 USD = 0.92 EUR
            // So rate_to_usd for EUR = 0.92 (EUR per USD) — store directly.
            $rate     = (float)$rates[$code];
            $rateToUsd = $rate > 0 ? $rate : 1.0;
            // priceEur: how many units of this currency equal 1 EUR (cross-rate via USD)
            $priceEur  = ($eurRate && $eurRate > 0 && $rateToUsd > 0) ? $rateToUsd / $eurRate : null;

            $this->currencyModel->updateRate($code, $rateToUsd);
            $this->priceHistoryModel->recordPrice($code, $rateToUsd, $priceEur, 'er-api');
            $updated[] = $code;
        }

        return ['updated' => $updated, 'failed' => $failed];
    }

    private function fetchJson(string $url): ?array
    {
        $ctx = stream_context_create([
            'http' => [
                'timeout'       => 10,
                'user_agent'    => 'InvestPro/1.0',
                'ignore_errors' => true,
            ],
        ]);
        $resp = @file_get_contents($url, false, $ctx);
        if ($resp === false) {
            $this->log("Failed to fetch: {$url}");
            return null;
        }
        $decoded = json_decode($resp, true);
        if (!is_array($decoded)) {
            $this->log("Invalid JSON from: {$url}");
            return null;
        }
        return $decoded;
    }

    private function log(string $msg): void
    {
        $logDir  = dirname(__DIR__, 2) . '/storage/logs';
        $logFile = $logDir . '/currency_sync.log';
        $line    = '[' . date('Y-m-d H:i:s') . '] ' . $msg . PHP_EOL;
        @error_log($line, 3, $logFile);
    }
}
