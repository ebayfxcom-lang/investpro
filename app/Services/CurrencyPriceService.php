<?php
declare(strict_types=1);

namespace App\Services;

use App\Models\CurrencyModel;
use App\Models\CurrencyPriceHistoryModel;

class CurrencyPriceService
{
    private CurrencyModel $currencyModel;
    private CurrencyPriceHistoryModel $priceHistoryModel;

    // CoinGecko IDs for all 100 supported crypto symbols
    private const COINGECKO_IDS = [
        'BTC'     => 'bitcoin',
        'ETH'     => 'ethereum',
        'USDT'    => 'tether',
        'BNB'     => 'binancecoin',
        'XRP'     => 'ripple',
        'USDC'    => 'usd-coin',
        'SOL'     => 'solana',
        'TRX'     => 'tron',
        'DOGE'    => 'dogecoin',
        'WBT'     => 'whitebit',
        'ADA'     => 'cardano',
        'BCH'     => 'bitcoin-cash',
        'HYPE'    => 'hyperliquid',
        'LEO'     => 'leo-token',
        'XMR'     => 'monero',
        'LINK'    => 'chainlink',
        'XLM'     => 'stellar',
        'DAI'     => 'dai',
        'LTC'     => 'litecoin',
        'AVAX'    => 'avalanche-2',
        'HBAR'    => 'hedera-hashgraph',
        'PYUSD'   => 'paypal-usd',
        'SUI'     => 'sui',
        'ZEC'     => 'zcash',
        'SHIB'    => 'shiba-inu',
        'TON'     => 'the-open-network',
        'CRO'     => 'crypto-com-chain',
        'PAXG'    => 'pax-gold',
        'DOT'     => 'polkadot',
        'UNI'     => 'uniswap',
        'MNT'     => 'mantle',
        'PI'      => 'pi-network',
        'OKB'     => 'okb',
        'TAO'     => 'bittensor',
        'AAVE'    => 'aave',
        'NEAR'    => 'near',
        'BGB'     => 'bitget-token',
        'ICP'     => 'internet-computer',
        'ETC'     => 'ethereum-classic',
        'ONDO'    => 'ondo-finance',
        'KCS'     => 'kucoin-shares',
        'WLD'     => 'worldcoin-wld',
        'QNT'     => 'quant-network',
        'ENA'     => 'ethena',
        'KAS'     => 'kaspa',
        'RENDER'  => 'render-token',
        'ALGO'    => 'algorand',
        'FLR'     => 'flare-networks',
        'APT'     => 'aptos',
        'FIL'     => 'filecoin',
        'VET'     => 'vechain',
        'ARB'     => 'arbitrum',
        'JUP'     => 'jupiter-exchange-solana',
        'BONK'    => 'bonk',
        'TUSD'    => 'true-usd',
        'DCR'     => 'decred',
        'STX'     => 'blockstack',
        'CAKE'    => 'pancakeswap-token',
        'ZRO'     => 'layerzero',
        'SEI'     => 'sei-network',
        'DASH'    => 'dash',
        'CHZ'     => 'chiliz',
        'XTZ'     => 'tezos',
        'FET'     => 'fetch-ai',
        'CRV'     => 'curve-dao-token',
        'BTT'     => 'bittorrent',
        'BSV'     => 'bitcoin-sv',
        'INJ'     => 'injective-protocol',
        'TIA'     => 'celestia',
        'FLOKI'   => 'floki',
        'JASMY'   => 'jasmycoin',
        'GRT'     => 'the-graph',
        'IOTA'    => 'iota',
        'PYTH'    => 'pyth-network',
        'OP'      => 'optimism',
        'LDO'     => 'lido-dao',
        'ENS'     => 'ethereum-name-service',
        'LUNC'    => 'terra-luna',
        'SAND'    => 'the-sandbox',
        'HNT'     => 'helium',
        'PENDLE'  => 'pendle',
        'TWT'     => 'trust-wallet-token',
        'DEXE'    => 'dexe',
        'AXS'     => 'axie-infinity',
        'COMP'    => 'compound-governance-token',
        'THETA'   => 'theta-token',
        'NEO'     => 'neo',
        'MANA'    => 'decentraland',
        'GALA'    => 'gala',
        'AR'      => 'arweave',
        // Legacy/common aliases
        'MATIC'   => 'matic-network',
        'ATOM'    => 'cosmos',
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

        // Build list of CoinGecko IDs for currencies that have a mapping
        $codeToId = [];
        foreach ($cryptos as $c) {
            $code = strtoupper($c['code']);
            if (isset(self::COINGECKO_IDS[$code])) {
                $codeToId[$code] = self::COINGECKO_IDS[$code];
            } else {
                // Mark unmapped currencies as failed (no CoinGecko ID known)
                $failed[] = $code;
            }
        }

        if (empty($codeToId)) {
            return ['updated' => $updated, 'failed' => $failed];
        }

        // CoinGecko allows up to 250 IDs per request; chunk if needed
        $idChunks = array_chunk($codeToId, 200, true);
        $idToCode = array_flip($codeToId);

        foreach ($idChunks as $chunk) {
            $idsStr = implode(',', array_values($chunk));
            $url    = "https://api.coingecko.com/api/v3/simple/price?ids={$idsStr}&vs_currencies=usd,eur";

            $data = $this->fetchJson($url);
            if ($data === null) {
                foreach (array_keys($chunk) as $code) {
                    $failed[] = $code;
                }
                continue;
            }

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
