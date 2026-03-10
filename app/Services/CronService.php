<?php
declare(strict_types=1);

namespace App\Services;

/**
 * CLI cron script - run via:
 *   php cron.php earnings
 *   php cron.php expired
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
            'earnings' => $this->processEarnings(),
            'expired'  => $this->processExpired(),
            default    => $this->showHelp(),
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

    private function showHelp(): void
    {
        echo "Usage: php cron.php [task]\n";
        echo "Tasks: earnings, expired\n";
    }
}
