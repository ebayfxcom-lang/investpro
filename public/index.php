<?php
declare(strict_types=1);

define('ROOT_DIR', dirname(__DIR__));
define('APP_START', microtime(true));

// Autoload
require ROOT_DIR . '/vendor/autoload.php';

// Error handling
$appConfig = require ROOT_DIR . '/config/app.php';
if ($appConfig['debug'] ?? false) {
    ini_set('display_errors', '1');
    error_reporting(E_ALL);
} else {
    ini_set('display_errors', '0');
    error_reporting(0);
}

date_default_timezone_set($appConfig['timezone'] ?? 'UTC');

// Initialize session
\App\Core\Session::getInstance();

// Bootstrap request
$request = new \App\Core\Request();

// Ensure storage directories exist
foreach ([
    ROOT_DIR . '/storage/cache/smarty/compile',
    ROOT_DIR . '/storage/cache/smarty/cache',
    ROOT_DIR . '/storage/logs',
] as $dir) {
    if (!is_dir($dir)) {
        mkdir($dir, 0775, true);
    }
}

// Load and resolve routes
try {
    $router = require ROOT_DIR . '/routes/web.php';
    $router->resolve($request);
} catch (\Throwable $e) {
    $logDir = ROOT_DIR . '/storage/logs';
    if (is_dir($logDir)) {
        $logFile = $logDir . '/error.log';
        $logLine = '[' . date('Y-m-d H:i:s') . '] ' . get_class($e) . ': ' . $e->getMessage()
            . ' in ' . $e->getFile() . ':' . $e->getLine() . PHP_EOL;
        error_log($logLine, 3, $logFile);
    }

    if ($appConfig['debug'] ?? false) {
        http_response_code(500);
        echo '<pre><strong>' . htmlspecialchars(get_class($e)) . '</strong>: '
            . htmlspecialchars($e->getMessage()) . "\n\n"
            . htmlspecialchars($e->getTraceAsString()) . '</pre>';
    } else {
        http_response_code(500);
        echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8">'
            . '<meta name="viewport" content="width=device-width,initial-scale=1">'
            . '<title>500 – Server Error</title>'
            . '<style>body{font-family:Segoe UI,sans-serif;background:#f0f2f5;display:flex;'
            . 'align-items:center;justify-content:center;min-height:100vh;margin:0}'
            . '.box{background:#fff;border-radius:12px;padding:3rem;text-align:center;'
            . 'box-shadow:0 4px 24px rgba(0,0,0,.08);max-width:480px}'
            . 'h1{color:#dc2626;margin-bottom:.5rem}p{color:#6b7280}'
            . 'a{color:#1e40af;text-decoration:none}'
            . '</style></head><body>'
            . '<div class="box"><h1>500 – Internal Server Error</h1>'
            . '<p>Something went wrong on our end. Please try again in a few moments.</p>'
            . '<p><a href="/">Return to homepage</a></p></div>'
            . '</body></html>';
    }
}
