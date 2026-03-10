<?php
declare(strict_types=1);

namespace App\Core;

class Response
{
    public function redirect(string $url, int $code = 302): void
    {
        http_response_code($code);
        header('Location: ' . $url);
        exit;
    }

    public function json(mixed $data, int $code = 200): void
    {
        http_response_code($code);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        exit;
    }

    public function status(int $code): self
    {
        http_response_code($code);
        return $this;
    }

    public function header(string $name, string $value): self
    {
        header("{$name}: {$value}");
        return $this;
    }
}
