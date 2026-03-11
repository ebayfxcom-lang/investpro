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

            $code = strtoupper(trim($request->post('code', '')));
            $rate = (float)$request->post('rate_to_usd', 1.0);

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
