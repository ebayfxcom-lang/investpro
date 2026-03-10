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
$router = require ROOT_DIR . '/routes/web.php';
$router->resolve($request);
