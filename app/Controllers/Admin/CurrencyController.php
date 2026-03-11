<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\CurrencyModel;
use App\Models\CurrencyPriceHistoryModel;
use App\Services\CurrencyPriceService;

class CurrencyController extends Controller
{
    private const MIN_EXCHANGE_RATE = 0.0000001;
    public function index(Request $request): void
    {
        $this->requireAuth('admin');

        $currencyModel = new CurrencyModel();

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/admin/currencies');
            }

            $action = $request->post('action', '');

            if ($action === 'add') {
                $code   = strtoupper(trim($request->post('code', '')));
                $name   = trim($request->post('name', ''));
                $symbol = trim($request->post('symbol', '$'));
                $type   = $request->post('type', 'fiat');
                if ($code && $name) {
                    if (!$currencyModel->findByCode($code)) {
                        $currencyModel->create([
                            'code'        => $code,
                            'name'        => $name,
                            'symbol'      => $symbol,
                            'type'        => $type,
                            'rate_to_usd' => 1.0,
                            'status'      => 'active',
                            'sort_order'  => 0,
                            'created_at'  => date('Y-m-d H:i:s'),
                        ]);
                        (new AuditLog())->log('currency_added', "Currency {$code} added", Auth::id('admin'), $request->ip());
                        $this->flash('success', "Currency {$code} added.");
                    } else {
                        $this->flash('error', "Currency {$code} already exists.");
                    }
                } else {
                    $this->flash('error', 'Code and name are required.');
                }
                $this->redirect('/admin/currencies');
            }

            if ($action === 'update') {
                $id   = (int)$request->post('currency_id', 0);
                $rate = (float)$request->post('rate_to_usd', 1.0);
                $status = $request->post('status', 'active');
                if ($id > 0) {
                    $currencyModel->update($id, [
                        'rate_to_usd' => max(self::MIN_EXCHANGE_RATE, $rate),
                        'status'      => $status,
                        'updated_at'  => date('Y-m-d H:i:s'),
                    ]);
                    (new AuditLog())->log('currency_updated', "Currency #{$id} updated", Auth::id('admin'), $request->ip());
                    $this->flash('success', 'Currency updated.');
                }
                $this->redirect('/admin/currencies');
            }

            // Inline rate update by currency code (sent from currencies table row)
            if ($action === 'update_rate') {
                $code = strtoupper(trim($request->post('code', '')));
                // Accept field name "rate" (sent by template) or "rate_to_usd"
                $rate = (float)($request->post('rate', null) ?? $request->post('rate_to_usd', 0));
                if ($code && $rate > 0) {
                    $currencyModel->updateRate($code, max(self::MIN_EXCHANGE_RATE, $rate));
                    (new AuditLog())->log('currency_rate_updated', "Currency {$code} rate updated to {$rate}", Auth::id('admin'), $request->ip());
                    $this->flash('success', "Rate for {$code} updated.");
                } else {
                    $this->flash('error', 'Invalid currency code or rate.');
                }
                $this->redirect('/admin/currencies');
            }

            if ($action === 'delete') {
                // Accept delete by code (from template) or by id
                $code = strtoupper(trim($request->post('code', '')));
                $id   = (int)$request->post('currency_id', 0);
                if ($code) {
                    $existing = $currencyModel->findByCode($code);
                    if ($existing) {
                        $currencyModel->delete((int)$existing['id']);
                        (new AuditLog())->log('currency_deleted', "Currency {$code} deleted", Auth::id('admin'), $request->ip());
                        $this->flash('success', 'Currency deleted.');
                    }
                } elseif ($id > 0) {
                    $currencyModel->delete($id);
                    (new AuditLog())->log('currency_deleted', "Currency #{$id} deleted", Auth::id('admin'), $request->ip());
                    $this->flash('success', 'Currency deleted.');
                }
                $this->redirect('/admin/currencies');
            }

            if ($action === 'sync') {
                $service = new CurrencyPriceService();
                $result  = $service->syncAll();
                $count   = count($result['updated']);
                (new AuditLog())->log('currency_sync', "Currency prices synced: {$count} updated", Auth::id('admin'), $request->ip());
                $this->flash('success', "Prices synced. Updated: " . implode(', ', $result['updated'] ?: ['none']));
                $this->redirect('/admin/currencies');
            }
        }

        $currencies   = $currencyModel->findAll('', [], 'sort_order ASC, code ASC');
        $priceHistory = (new CurrencyPriceHistoryModel())->getAllLatestPrices();
        $currencyStats = $currencyModel->getStats();

        $this->view('admin/currencies/index', [
            'title'          => 'Currency Management',
            'currencies'     => $currencies,
            'price_history'  => $priceHistory,
            'currency_stats' => $currencyStats,
            'admin'          => Auth::user('admin'),
        ]);
    }

    public function priceHistory(Request $request): void
    {
        $this->requireAuth('admin');

        $code = strtoupper(trim($request->get('code', '')));
        $days = max(1, min(365, (int)$request->get('days', 30)));

        $priceModel = new CurrencyPriceHistoryModel();
        $history    = $code ? $priceModel->getPriceHistory($code, $days) : $priceModel->getAllLatestPrices();

        $currencyModel = new CurrencyModel();
        $currencies    = $currencyModel->getActiveCurrencies();

        $this->view('admin/currencies/price-history', [
            'title'      => 'Price History',
            'history'    => $history,
            'currencies' => $currencies,
            'code'       => $code,
            'days'       => $days,
            'admin'      => Auth::user('admin'),
        ]);
    }

    /**
     * Dedicated crypto currencies management page.
     * Admins can enable/disable which crypto currencies are available for deposits/withdrawals.
     */
    public function crypto(Request $request): void
    {
        $this->requireAuth('admin');

        $currencyModel = new CurrencyModel();

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/admin/crypto-currencies');
            }
            $action = $request->post('action', '');

            if ($action === 'add') {
                $code   = strtoupper(trim($request->post('code', '')));
                $name   = trim($request->post('name', ''));
                $symbol = trim($request->post('symbol', ''));
                if ($code && $name) {
                    if (!$currencyModel->findByCode($code)) {
                        $currencyModel->create([
                            'code'        => $code,
                            'name'        => $name,
                            'symbol'      => $symbol ?: $code,
                            'type'        => 'crypto',
                            'rate_to_usd' => 1.0,
                            'status'      => 'active',
                            'sort_order'  => 100,
                            'created_at'  => date('Y-m-d H:i:s'),
                        ]);
                        (new AuditLog())->log('crypto_added', "Crypto {$code} added", Auth::id('admin'), $request->ip());
                        $this->flash('success', "Crypto currency {$code} added.");
                    } else {
                        $this->flash('error', "Currency {$code} already exists.");
                    }
                } else {
                    $this->flash('error', 'Code and name are required.');
                }
                $this->redirect('/admin/crypto-currencies');
            }

            if ($action === 'toggle') {
                $code     = strtoupper(trim($request->post('code', '')));
                $existing = $code ? $currencyModel->findByCode($code) : null;
                if ($existing) {
                    $newStatus = $existing['status'] === 'active' ? 'inactive' : 'active';
                    $currencyModel->update((int)$existing['id'], [
                        'status'     => $newStatus,
                        'updated_at' => date('Y-m-d H:i:s'),
                    ]);
                    (new AuditLog())->log('crypto_toggled', "Crypto {$code} status → {$newStatus}", Auth::id('admin'), $request->ip());
                    $this->flash('success', "Crypto {$code} is now {$newStatus}.");
                }
                $this->redirect('/admin/crypto-currencies');
            }

            if ($action === 'delete') {
                $code     = strtoupper(trim($request->post('code', '')));
                $existing = $code ? $currencyModel->findByCode($code) : null;
                if ($existing && $existing['type'] === 'crypto') {
                    $currencyModel->delete((int)$existing['id']);
                    (new AuditLog())->log('crypto_deleted', "Crypto {$code} deleted", Auth::id('admin'), $request->ip());
                    $this->flash('success', "Crypto {$code} deleted.");
                }
                $this->redirect('/admin/crypto-currencies');
            }

            if ($action === 'sync') {
                $service = new CurrencyPriceService();
                $result  = $service->syncAll();
                $count   = count($result['updated']);
                $this->flash('success', "Prices synced. Updated: " . implode(', ', $result['updated'] ?: ['none']));
                $this->redirect('/admin/crypto-currencies');
            }
        }

        $cryptos = $currencyModel->findAll("type = 'crypto'", [], 'sort_order ASC, code ASC');

        $this->view('admin/crypto-currencies/index', [
            'title'   => 'Crypto Currencies',
            'cryptos' => $cryptos,
            'admin'   => Auth::user('admin'),
        ]);
    }
}
