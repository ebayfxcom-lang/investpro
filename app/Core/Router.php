<?php
declare(strict_types=1);

namespace App\Core;

class Router
{
    private array $routes = [];

    public function get(string $path, array|callable $handler): void
    {
        $this->routes['GET'][$path] = $handler;
    }

    public function post(string $path, array|callable $handler): void
    {
        $this->routes['POST'][$path] = $handler;
    }

    public function resolve(Request $request): mixed
    {
        $method = $request->method();
        $path   = $request->path();

        foreach ($this->routes[$method] ?? [] as $pattern => $handler) {
            $params = $this->matchRoute($pattern, $path);
            if ($params !== false) {
                return $this->dispatch($handler, $params, $request);
            }
        }
        $this->render404($path);
        return null;
    }

    private function render404(string $path): void
    {
        http_response_code(404);
        $appConfig = require dirname(__DIR__, 2) . '/config/app.php';
        $siteName  = $appConfig['name'] ?? 'InvestPro';
        echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8">'
            . '<meta name="viewport" content="width=device-width,initial-scale=1">'
            . '<title>404 – Page Not Found | ' . htmlspecialchars($siteName) . '</title>'
            . '<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">'
            . '<style>'
            . 'body{background:#f0f2f5;font-family:"Segoe UI",sans-serif;display:flex;align-items:center;justify-content:center;min-height:100vh;margin:0}'
            . '.box{background:#fff;border-radius:16px;padding:3rem 2.5rem;text-align:center;box-shadow:0 4px 32px rgba(0,0,0,.08);max-width:480px;width:100%}'
            . '.code{font-size:5rem;font-weight:900;color:#1e40af;line-height:1}'
            . 'h2{color:#1f2937;margin:.5rem 0 1rem}'
            . 'p{color:#6b7280;margin-bottom:1.5rem}'
            . '.btn-home{background:#1e40af;color:#fff;border:none;padding:.65rem 2rem;border-radius:8px;text-decoration:none;font-weight:600}'
            . '.btn-home:hover{background:#1e3a8a;color:#fff}'
            . '</style></head><body>'
            . '<div class="box">'
            . '<div class="code">404</div>'
            . '<h2>Page Not Found</h2>'
            . '<p>The page you are looking for doesn\'t exist or has been moved.</p>'
            . '<a href="/" class="btn-home">Return to Homepage</a>'
            . '</div></body></html>';
    }

    private function matchRoute(string $pattern, string $path): array|false
    {
        $regex = preg_replace('/\{([a-zA-Z_][a-zA-Z0-9_]*)\}/', '(?P<$1>[^/]+)', $pattern);
        $regex = '@^' . $regex . '$@';
        if (preg_match($regex, $path, $matches)) {
            return array_filter($matches, 'is_string', ARRAY_FILTER_USE_KEY);
        }
        return false;
    }

    private function dispatch(array|callable $handler, array $params, Request $request): mixed
    {
        if (is_callable($handler)) {
            return $handler($request, $params);
        }
        [$class, $method] = $handler;
        $controller = new $class();
        return $controller->$method($request, $params);
    }
}
