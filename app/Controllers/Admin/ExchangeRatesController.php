<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\CurrencyModel;
use App\Services\ConversionService;
use App\Services\CurrencyPriceService;

class ExchangeRatesController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');

        $currencyModel = new CurrencyModel();

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/admin/exchange-rates');
            }

            $action = $request->post('action', '');

            // Sync all rates from external APIs
            if ($action === 'sync') {
                $service = new CurrencyPriceService();
                $result  = $service->syncAll();
                $count   = count($result['updated']);
                (new AuditLog())->log('exchange_rates_synced', "Exchange rates synced: {$count} updated", Auth::id('admin'), $request->ip());
                $this->flash('success', "Rates synced. Updated: " . implode(', ', $result['updated'] ?: ['none']));
                $this->redirect('/admin/exchange-rates');
            }

            // Manual single-rate update (action=update)
            $code = strtoupper(trim($request->post('code', '')));
            // Template sends field "rate"; also accept "rate_to_usd" for backwards compatibility
            $rate = (float)($request->post('rate', null) ?? $request->post('rate_to_usd', 0));

            if ($code && $rate > 0) {
                $currencyModel->updateRate($code, $rate);
                (new AuditLog())->log('exchange_rate_updated', "Rate updated: {$code} = {$rate} USD", Auth::id('admin'), $request->ip());
                $this->flash('success', "Exchange rate for {$code} updated.");
            } else {
                $this->flash('error', 'Invalid code or rate.');
            }
            $this->redirect('/admin/exchange-rates');
        }

        $conversionService = new ConversionService();
        $rates             = $conversionService->getAllRates();
        $currencies        = $currencyModel->findAll('', [], 'code ASC');

        $this->view('admin/exchange-rates/index', [
            'title'      => 'Exchange Rates',
            'rates'      => $rates,
            'currencies' => $currencies,
            'admin'      => Auth::user('admin'),
        ]);
    }
}
