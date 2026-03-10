<?php
declare(strict_types=1);

namespace App\Core;

class Csrf
{
    private const TOKEN_KEY = '_csrf_token';
    private const TOKEN_LENGTH = 32;

    public static function getToken(): string
    {
        Session::getInstance();
        if (empty($_SESSION[self::TOKEN_KEY])) {
            $_SESSION[self::TOKEN_KEY] = bin2hex(random_bytes(self::TOKEN_LENGTH));
        }
        return $_SESSION[self::TOKEN_KEY];
    }

    public static function validate(string $token): bool
    {
        $stored = $_SESSION[self::TOKEN_KEY] ?? '';
        return hash_equals($stored, $token);
    }

    public static function validateRequest(Request $request): bool
    {
        $config = require dirname(__DIR__, 2) . '/config/app.php';
        $token  = $request->post($config['csrf_token_name']) ?? $request->header('X-CSRF-Token') ?? '';
        return self::validate($token);
    }

    public static function inputField(): string
    {
        $config = require dirname(__DIR__, 2) . '/config/app.php';
        $token  = self::getToken();
        return sprintf('<input type="hidden" name="%s" value="%s">', htmlspecialchars($config['csrf_token_name']), htmlspecialchars($token));
    }
}
