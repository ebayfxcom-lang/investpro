<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class DepositWalletModel extends Model
{
    protected string $table = 'deposit_wallets';

    public function getActiveWallets(): array
    {
        try {
            return $this->findAll("status = 'active'", [], 'currency_code ASC, network ASC');
        } catch (\Throwable) {
            return [];
        }
    }

    public function getWalletByCurrency(string $currencyCode, string $network = ''): ?array
    {
        try {
            if ($network !== '') {
                return $this->findBy(['currency_code' => $currencyCode, 'network' => $network, 'status' => 'active']);
            }
            $rows = $this->findAll("currency_code = ? AND status = 'active'", [$currencyCode], 'id ASC', 1);
            return $rows[0] ?? null;
        } catch (\Throwable) {
            return null;
        }
    }
}
