<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class SpinSettingsModel extends Model
{
    protected string $table = 'spin_settings';

    public function getSettings(): array
    {
        $row = $this->find(1);
        return $row ?: ['enabled' => 1, 'spin_price' => 1.0, 'daily_free_spins' => 1];
    }

    public function saveSettings(array $data): void
    {
        $existing = $this->find(1);
        if ($existing) {
            $this->update(1, $data);
        } else {
            $this->create(array_merge(['id' => 1], $data));
        }
    }
}
