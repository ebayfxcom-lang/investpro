<?php
declare(strict_types=1);

namespace App\Services;

/**
 * TOTP (Time-based One-Time Password) service.
 * Implements RFC 6238 / RFC 4226 in pure PHP without external dependencies.
 */
class TotpService
{
    private const DIGITS    = 6;
    private const PERIOD    = 30;
    private const ALGORITHM = 'sha1';
    private const WINDOW    = 1; // allow 1 period before/after

    /**
     * Generate a new random base32-encoded secret.
     */
    public function generateSecret(): string
    {
        $bytes = random_bytes(20); // 160-bit secret
        return $this->base32Encode($bytes);
    }

    /**
     * Generate a TOTP code for the given secret and optional timestamp.
     */
    public function generateCode(string $secret, ?int $timestamp = null): string
    {
        $timestamp ??= time();
        $counter    = (int)floor($timestamp / self::PERIOD);
        return $this->hotp($secret, $counter);
    }

    /**
     * Verify a TOTP code, allowing for clock drift within WINDOW periods.
     */
    public function verify(string $secret, string $code, ?int $timestamp = null): bool
    {
        $timestamp ??= time();
        $code       = trim($code);
        if (!ctype_digit($code) || strlen($code) !== self::DIGITS) {
            return false;
        }
        $counter = (int)floor($timestamp / self::PERIOD);
        for ($i = -self::WINDOW; $i <= self::WINDOW; $i++) {
            if (hash_equals($this->hotp($secret, $counter + $i), $code)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Build an otpauth:// URI for QR code generation.
     */
    public function getProvisioningUri(string $secret, string $accountName, string $issuer): string
    {
        return sprintf(
            'otpauth://totp/%s:%s?secret=%s&issuer=%s&algorithm=SHA1&digits=%d&period=%d',
            rawurlencode($issuer),
            rawurlencode($accountName),
            $secret,
            rawurlencode($issuer),
            self::DIGITS,
            self::PERIOD
        );
    }

    /**
     * Generate a QR code URL using the Google Charts API (no API key needed).
     */
    public function getQrCodeUrl(string $provisioningUri): string
    {
        return 'https://chart.googleapis.com/chart?chs=200x200&chld=M|0&cht=qr&chl='
            . rawurlencode($provisioningUri);
    }

    /**
     * Generate backup codes (plain text, should be shown once and hashed before storage).
     */
    public function generateBackupCodes(int $count = 8): array
    {
        $codes = [];
        for ($i = 0; $i < $count; $i++) {
            $codes[] = strtoupper(bin2hex(random_bytes(4)));
        }
        return $codes;
    }

    /**
     * Hash backup codes for storage.
     */
    public function hashBackupCodes(array $codes): array
    {
        return array_map(fn($c) => password_hash(strtoupper($c), PASSWORD_BCRYPT), $codes);
    }

    /**
     * Verify a backup code against stored hashed codes.
     * Returns the index of the matched code (to remove it), or -1 if none matched.
     */
    public function verifyBackupCode(string $code, array $hashedCodes): int
    {
        $code = strtoupper(trim($code));
        foreach ($hashedCodes as $index => $hash) {
            if (password_verify($code, $hash)) {
                return $index;
            }
        }
        return -1;
    }

    // -----------------------------------------------------------------------
    // Private helpers
    // -----------------------------------------------------------------------

    private function hotp(string $secret, int $counter): string
    {
        $key     = $this->base32Decode($secret);
        $message = pack('N*', 0) . pack('N*', $counter);
        $hash    = hash_hmac(self::ALGORITHM, $message, $key, true);
        $offset  = ord($hash[-1]) & 0x0F;
        $code    = (
            ((ord($hash[$offset])     & 0x7F) << 24) |
            ((ord($hash[$offset + 1]) & 0xFF) << 16) |
            ((ord($hash[$offset + 2]) & 0xFF) << 8) |
            (ord($hash[$offset + 3])  & 0xFF)
        ) % (10 ** self::DIGITS);
        return str_pad((string)$code, self::DIGITS, '0', STR_PAD_LEFT);
    }

    private function base32Encode(string $data): string
    {
        $alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
        $output   = '';
        $buffer   = 0;
        $bitsLeft = 0;
        foreach (str_split($data) as $byte) {
            $buffer   = ($buffer << 8) | ord($byte);
            $bitsLeft += 8;
            while ($bitsLeft >= 5) {
                $output   .= $alphabet[($buffer >> ($bitsLeft - 5)) & 0x1F];
                $bitsLeft -= 5;
            }
        }
        if ($bitsLeft > 0) {
            $output .= $alphabet[($buffer << (5 - $bitsLeft)) & 0x1F];
        }
        return $output;
    }

    private function base32Decode(string $data): string
    {
        $alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
        $data     = strtoupper(rtrim($data, '='));
        $output   = '';
        $buffer   = 0;
        $bitsLeft = 0;
        foreach (str_split($data) as $char) {
            $pos = strpos($alphabet, $char);
            if ($pos === false) {
                continue;
            }
            $buffer   = ($buffer << 5) | $pos;
            $bitsLeft += 5;
            if ($bitsLeft >= 8) {
                $output   .= chr(($buffer >> ($bitsLeft - 8)) & 0xFF);
                $bitsLeft -= 8;
            }
        }
        return $output;
    }
}
