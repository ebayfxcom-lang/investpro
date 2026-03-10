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
