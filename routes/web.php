<?php
declare(strict_types=1);

use App\Core\Router;
use App\Controllers\Admin;
use App\Controllers\User;

$router = new Router();

// ============================================================
// PUBLIC ROUTES
// ============================================================
$router->get('/', [User\AuthController::class, 'login']);
$router->get('/login', [User\AuthController::class, 'login']);
$router->post('/login', [User\AuthController::class, 'login']);
$router->get('/register', [User\AuthController::class, 'register']);
$router->post('/register', [User\AuthController::class, 'register']);
$router->get('/logout', [User\AuthController::class, 'logout']);

// ============================================================
// USER ROUTES
// ============================================================
$router->get('/user/dashboard', [User\DashboardController::class, 'index']);

// Deposits
$router->get('/user/deposit', [User\DepositController::class, 'create']);
$router->post('/user/deposit', [User\DepositController::class, 'create']);
$router->get('/user/deposits/active', [User\DepositController::class, 'active']);
$router->get('/user/deposits/history', [User\DepositController::class, 'history']);

// Withdrawals
$router->get('/user/withdraw', [User\WithdrawalController::class, 'create']);
$router->post('/user/withdraw', [User\WithdrawalController::class, 'create']);
$router->get('/user/withdrawals', [User\WithdrawalController::class, 'history']);

// Earnings
$router->get('/user/earnings', [User\EarningsController::class, 'index']);

// Referrals
$router->get('/user/referrals', [User\ReferralController::class, 'index']);

// Security
$router->get('/user/security', [User\SecurityController::class, 'index']);
$router->post('/user/security', [User\SecurityController::class, 'index']);

// Settings
$router->get('/user/settings', [User\SettingsController::class, 'index']);
$router->post('/user/settings', [User\SettingsController::class, 'index']);

// ============================================================
// ADMIN ROUTES
// ============================================================
$router->get('/admin/login', [Admin\AuthController::class, 'login']);
$router->post('/admin/login', [Admin\AuthController::class, 'login']);
$router->get('/admin/logout', [Admin\AuthController::class, 'logout']);

$router->get('/admin/dashboard', [Admin\DashboardController::class, 'index']);

// Users
$router->get('/admin/users', [Admin\UsersController::class, 'index']);
$router->get('/admin/users/add-funds', [Admin\AddFundsController::class, 'index']);
$router->get('/admin/users/{id}', [Admin\UsersController::class, 'view']);
$router->post('/admin/users/{id}/toggle-status', [Admin\UsersController::class, 'toggleStatus']);
$router->get('/admin/users/{id}/add-funds', [Admin\UsersController::class, 'addFunds']);
$router->post('/admin/users/{id}/add-funds', [Admin\UsersController::class, 'addFunds']);

// Plans
$router->get('/admin/plans', [Admin\PlansController::class, 'index']);
$router->get('/admin/plans/create', [Admin\PlansController::class, 'create']);
$router->post('/admin/plans/create', [Admin\PlansController::class, 'create']);
$router->get('/admin/plans/{id}/edit', [Admin\PlansController::class, 'edit']);
$router->post('/admin/plans/{id}/edit', [Admin\PlansController::class, 'edit']);
$router->post('/admin/plans/{id}/delete', [Admin\PlansController::class, 'delete']);

// Deposits
$router->get('/admin/deposits', [Admin\DepositsController::class, 'index']);
$router->get('/admin/deposits/expiring', [Admin\DepositsController::class, 'expiring']);
$router->post('/admin/deposits/{id}/approve', [Admin\DepositsController::class, 'approve']);
$router->post('/admin/deposits/{id}/reject', [Admin\DepositsController::class, 'reject']);

// Withdrawals
$router->get('/admin/withdrawals', [Admin\WithdrawalsController::class, 'index']);
$router->post('/admin/withdrawals/{id}/approve', [Admin\WithdrawalsController::class, 'approve']);
$router->post('/admin/withdrawals/{id}/reject', [Admin\WithdrawalsController::class, 'reject']);

// Transactions
$router->get('/admin/transactions', [Admin\TransactionsController::class, 'index']);

// Settings
$router->get('/admin/settings', [Admin\SettingsController::class, 'index']);
$router->post('/admin/settings', [Admin\SettingsController::class, 'index']);
$router->get('/admin/settings/referral', [Admin\SettingsController::class, 'referral']);
$router->post('/admin/settings/referral', [Admin\SettingsController::class, 'referral']);
$router->get('/admin/settings/currencies', [Admin\SettingsController::class, 'currencies']);
$router->get('/admin/settings/email-templates', [Admin\SettingsController::class, 'emailTemplates']);
$router->get('/admin/settings/security', [Admin\SettingsController::class, 'security']);
$router->post('/admin/settings/security', [Admin\SettingsController::class, 'security']);

// Earnings
$router->get('/admin/earnings', [Admin\EarningsController::class, 'index']);

// Blacklist
$router->get('/admin/blacklist', [Admin\BlacklistController::class, 'index']);
$router->post('/admin/blacklist/add', [Admin\BlacklistController::class, 'add']);
$router->post('/admin/blacklist/{id}/remove', [Admin\BlacklistController::class, 'remove']);

// Referral Earnings
$router->get('/admin/referrals', [Admin\ReferralEarningsController::class, 'index']);

// FAQ
$router->get('/admin/faq', [Admin\FaqController::class, 'index']);

// News
$router->get('/admin/news', [Admin\NewsController::class, 'index']);

// Custom Pages
$router->get('/admin/pages', [Admin\PagesController::class, 'index']);

// Newsletter
$router->get('/admin/newsletter', [Admin\NewsletterController::class, 'index']);

// Performance
$router->get('/admin/performance', [Admin\PerformanceController::class, 'index']);

// IP Checks
$router->get('/admin/ip-checks', [Admin\IpChecksController::class, 'index']);
$router->post('/admin/ip-checks/block', [Admin\IpChecksController::class, 'block']);
$router->post('/admin/ip-checks/{id}/unblock', [Admin\IpChecksController::class, 'unblock']);

// Admin Profile
$router->get('/admin/profile', [Admin\ProfileController::class, 'index']);
$router->post('/admin/profile', [Admin\ProfileController::class, 'index']);

// Currencies
$router->get('/admin/currencies', [Admin\CurrencyController::class, 'index']);
$router->post('/admin/currencies', [Admin\CurrencyController::class, 'index']);
$router->get('/admin/currencies/price-history', [Admin\CurrencyController::class, 'priceHistory']);

// Exchange Rates
$router->get('/admin/exchange-rates', [Admin\ExchangeRatesController::class, 'index']);
$router->post('/admin/exchange-rates', [Admin\ExchangeRatesController::class, 'index']);

// Spin Rewards
$router->get('/admin/spin', [Admin\SpinController::class, 'index']);
$router->post('/admin/spin', [Admin\SpinController::class, 'index']);
$router->get('/admin/spin/history', [Admin\SpinController::class, 'history']);

return $router;
