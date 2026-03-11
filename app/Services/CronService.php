<?php
declare(strict_types=1);

namespace App\Services;

/**
 * CLI cron script - run via:
 *   php cron.php earnings
 *   php cron.php expired
 *   php cron.php price_sync
 */
class CronService
{
    private InvestmentService $investmentService;

    public function __construct()
    {
        $this->investmentService = new InvestmentService();
    }

    public function run(string $task): void
    {
        match ($task) {
            'earnings'   => $this->processEarnings(),
            'expired'    => $this->processExpired(),
            'price_sync' => $this->syncPrices(),
            default      => $this->showHelp(),
        };
    }

    private function processEarnings(): void
    {
        echo "[" . date('Y-m-d H:i:s') . "] Processing earnings...\n";
        $result = $this->investmentService->processEarnings();
        echo "[" . date('Y-m-d H:i:s') . "] Done. Processed: {$result['processed']}, Total paid: {$result['total_paid']}\n";
    }

    private function processExpired(): void
    {
        echo "[" . date('Y-m-d H:i:s') . "] Processing expired deposits...\n";
        $result = $this->investmentService->processExpiredDeposits();
        echo "[" . date('Y-m-d H:i:s') . "] Done. Processed: {$result['processed']}\n";
    }

    private function syncPrices(): void
    {
        echo "[" . date('Y-m-d H:i:s') . "] Syncing currency prices...\n";
        $service = new CurrencyPriceService();
        $result  = $service->syncAll();
        $updatedList = implode(', ', $result['updated'] ?: ['none']);
        $failedList  = implode(', ', $result['failed']  ?: ['none']);
        echo "[" . date('Y-m-d H:i:s') . "] Updated: {$updatedList}\n";
        echo "[" . date('Y-m-d H:i:s') . "] Failed: {$failedList}\n";
    }

    private function showHelp(): void
    {
        echo "Usage: php cron.php [task]\n";
        echo "Tasks: earnings, expired, price_sync\n";
    }
}
