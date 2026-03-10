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
                        'rate_to_usd' => max(0.0000001, $rate),
                        'status'      => $status,
                        'updated_at'  => date('Y-m-d H:i:s'),
                    ]);
                    (new AuditLog())->log('currency_updated', "Currency #{$id} updated", Auth::id('admin'), $request->ip());
                    $this->flash('success', 'Currency updated.');
                }
                $this->redirect('/admin/currencies');
            }

            if ($action === 'delete') {
                $id = (int)$request->post('currency_id', 0);
                if ($id > 0) {
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

        $this->view('admin/currencies/index', [
            'title'         => 'Currency Management',
            'currencies'    => $currencies,
            'price_history' => $priceHistory,
            'admin'         => Auth::user('admin'),
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
}
