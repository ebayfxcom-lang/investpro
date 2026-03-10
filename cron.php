<?php
declare(strict_types=1);

// Ensure this is only run from CLI
if (PHP_SAPI !== 'cli') {
    http_response_code(403);
    exit('CLI only');
}

define('ROOT_DIR', __DIR__);

require ROOT_DIR . '/vendor/autoload.php';

$task = $argv[1] ?? 'help';

$cron = new \App\Services\CronService();
$cron->run($task);
