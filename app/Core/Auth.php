<?php
declare(strict_types=1);

namespace App\Core;

class Auth
{
    public static function login(array $user, string $guard = 'user'): void
    {
        $session = Session::getInstance();
        session_regenerate_id(true);
        $session->set("auth_{$guard}", [
            'id'       => $user['id'],
            'email'    => $user['email'],
            'username' => $user['username'] ?? $user['email'],
            'role'     => $user['role'] ?? 'user',
        ]);
    }

    public static function logout(string $guard = 'user'): void
    {
        $session = Session::getInstance();
        $session->remove("auth_{$guard}");
        if ($guard === 'user') {
            $session->destroy();
        }
    }

    public static function check(string $guard = 'user'): bool
    {
        $session = Session::getInstance();
        return $session->has("auth_{$guard}");
    }

    public static function user(string $guard = 'user'): ?array
    {
        $session = Session::getInstance();
        return $session->get("auth_{$guard}");
    }

    public static function id(string $guard = 'user'): ?int
    {
        $user = self::user($guard);
        return $user ? (int)$user['id'] : null;
    }

    public static function hasRole(string $role, string $guard = 'admin'): bool
    {
        $user = self::user($guard);
        return $user && $user['role'] === $role;
    }
}
