<?php
declare(strict_types=1);

namespace App\Core;

use Smarty\Smarty;

abstract class Controller
{
    protected Smarty $smarty;
    protected Response $response;
    protected Session $session;

    public function __construct()
    {
        $this->response = new Response();
        $this->session  = Session::getInstance();
        $this->smarty   = $this->initSmarty();
    }

    private function initSmarty(): Smarty
    {
        $smarty = new Smarty();
        $root   = dirname(__DIR__, 2);
        $smarty->setTemplateDir($root . '/resources/templates');
        $smarty->setCompileDir($root . '/storage/cache/smarty/compile');
        $smarty->setCacheDir($root . '/storage/cache/smarty/cache');
        $smarty->setConfigDir($root . '/resources/config');
        $smarty->caching = false;

        $appConfig = require $root . '/config/app.php';
        $smarty->assign('app', $appConfig);
        $smarty->assign('session', $this->session);
        $smarty->assign('csrf_token', Csrf::getToken());
        $smarty->assign('flash', $this->session->getFlash());

        // Feature flags for conditional sidebar/menu rendering
        try {
            $settingsModel = new \App\Models\SettingsModel();
            $smarty->assign('settings_kyc_enabled',       (bool)$settingsModel->get('kyc_enabled', '0'));
            $smarty->assign('settings_community_enabled', (bool)$settingsModel->get('community_enabled', '0'));
            $smarty->assign('settings_rewards_enabled',   (bool)$settingsModel->get('rewards_hub_enabled', '0'));
        } catch (\Throwable $e) {
            $smarty->assign('settings_kyc_enabled',       false);
            $smarty->assign('settings_community_enabled', false);
            $smarty->assign('settings_rewards_enabled',   false);
        }

        // Register custom modifiers not built into Smarty 5
        $smarty->registerPlugin('modifier', 'ucfirst', fn($s) => ucfirst((string)$s));
        $smarty->registerPlugin('modifier', 'ceil', fn($n) => (int)ceil((float)$n));
        $smarty->registerPlugin('modifier', 'floor', fn($n) => (int)floor((float)$n));
        $smarty->registerPlugin('modifier', 'round', fn($n, $p = 0) => round((float)$n, (int)$p));
        $smarty->registerPlugin('modifier', 'min', fn($a, $b) => min($a, $b));
        $smarty->registerPlugin('modifier', 'max', fn($a, $b) => max($a, $b));
        $smarty->registerPlugin('modifier', 'abs', fn($n) => abs((float)$n));
        $smarty->registerPlugin('modifier', 'strtotime', fn($s) => strtotime((string)$s));
        $smarty->registerPlugin('modifier', 'json_encode', fn($v, int $flags = JSON_UNESCAPED_UNICODE | JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT) => json_encode($v, $flags));

        // Override built-in date_format to safely handle NULL/empty dates and
        // convert strftime-style format strings (%Y, %m, …) to date() patterns.
        // This ensures PHP 8.3 compatibility without relying on deprecated strftime().
        $smarty->registerPlugin('modifier', 'date_format', static function ($date, string $format = '%b %e, %Y'): string {
            if ($date === null || $date === '' || $date === false) {
                return '';
            }
            $ts = is_numeric($date) ? (int)$date : strtotime((string)$date);
            if ($ts === false || $ts === 0) {
                return '';
            }
            static $strftimeMap = [
                '%Y' => 'Y', '%y' => 'y', '%m' => 'm', '%d' => 'd', '%e' => 'j',
                '%H' => 'H', '%I' => 'h', '%M' => 'i', '%S' => 's', '%A' => 'l',
                '%a' => 'D', '%B' => 'F', '%b' => 'M', '%p' => 'A', '%P' => 'a',
                '%j' => 'z', '%Z' => 'T', '%z' => 'O', '%n' => "\n", '%t' => "\t",
            ];
            $phpFormat = str_replace(array_keys($strftimeMap), array_values($strftimeMap), $format);
            return date($phpFormat, $ts);
        });

        // Format a value for use in a native HTML <input type="date"> (YYYY-MM-DD).
        // Accepts a datetime string, Unix timestamp, or null/empty.
        $smarty->registerPlugin('modifier', 'to_input_date', static function ($date): string {
            if ($date === null || $date === '' || $date === false) {
                return '';
            }
            $ts = is_numeric($date) ? (int)$date : strtotime((string)$date);
            if ($ts === false || $ts === 0) {
                return '';
            }
            return date('Y-m-d', $ts);
        });

        // Format a value for use in a native HTML <input type="datetime-local"> (YYYY-MM-DDTHH:MM).
        // Accepts a datetime string, Unix timestamp, or null/empty.
        $smarty->registerPlugin('modifier', 'to_input_datetime', static function ($date): string {
            if ($date === null || $date === '' || $date === false) {
                return '';
            }
            $ts = is_numeric($date) ? (int)$date : strtotime((string)$date);
            if ($ts === false || $ts === 0) {
                return '';
            }
            return date('Y-m-d\TH:i', $ts);
        });

        return $smarty;
    }

    protected function view(string $template, array $data = []): void
    {
        foreach ($data as $key => $value) {
            $this->smarty->assign($key, $value);
        }
        $this->smarty->display($template . '.tpl');
    }

    protected function redirect(string $url): void
    {
        $this->response->redirect($url);
    }

    protected function json(mixed $data, int $code = 200): void
    {
        $this->response->json($data, $code);
    }

    protected function flash(string $type, string $message): void
    {
        $this->session->setFlash($type, $message);
    }

    protected function requireAuth(string $guard = 'user'): void
    {
        if (!Auth::check($guard)) {
            $this->redirect($guard === 'admin' ? '/admin/login' : '/login');
        }
    }
}
