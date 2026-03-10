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
        http_response_code(404);
        echo '404 Not Found';
        return null;
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
