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
$router->get('/login/2fa', [User\AuthController::class, 'verifyTwoFactor']);
$router->post('/login/2fa', [User\AuthController::class, 'verifyTwoFactor']);
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
$router->get('/user/deposit/pay', [User\DepositController::class, 'pay']);
$router->post('/user/deposit/pay', [User\DepositController::class, 'pay']);
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

// KYC
$router->get('/user/kyc', [User\KycController::class, 'index']);
$router->post('/user/kyc', [User\KycController::class, 'index']);

// Community
$router->get('/user/community', [User\CommunityController::class, 'index']);
$router->post('/user/community/post', [User\CommunityController::class, 'create']);
$router->post('/user/community/like', [User\CommunityController::class, 'like']);
$router->post('/user/community/comment', [User\CommunityController::class, 'comment']);

// Rewards Hub
$router->get('/user/rewards', [User\RewardsController::class, 'index']);
$router->post('/user/rewards/claim', [User\RewardsController::class, 'claim']);

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
$router->get('/admin/users/{id}', [Admin\UsersController::class, 'show']);
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

// Deposit Wallets (System Wallets)
$router->get('/admin/deposit-wallets', [Admin\DepositWalletsController::class, 'index']);
$router->get('/admin/deposit-wallets/create', [Admin\DepositWalletsController::class, 'create']);
$router->post('/admin/deposit-wallets/create', [Admin\DepositWalletsController::class, 'create']);
$router->get('/admin/deposit-wallets/{id}/edit', [Admin\DepositWalletsController::class, 'edit']);
$router->post('/admin/deposit-wallets/{id}/edit', [Admin\DepositWalletsController::class, 'edit']);
$router->post('/admin/deposit-wallets/{id}/delete', [Admin\DepositWalletsController::class, 'delete']);

// Deposits
$router->get('/admin/deposits', [Admin\DepositsController::class, 'index']);
$router->get('/admin/deposits/expiring', [Admin\DepositsController::class, 'expiring']);
$router->post('/admin/deposits/{id}/approve', [Admin\DepositsController::class, 'approve']);
$router->post('/admin/deposits/{id}/reject', [Admin\DepositsController::class, 'reject']);

// Withdrawals
$router->get('/admin/withdrawals', [Admin\WithdrawalsController::class, 'index']);
$router->get('/admin/withdrawals/{id}', [Admin\WithdrawalsController::class, 'show']);
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
$router->post('/admin/settings/currencies', [Admin\SettingsController::class, 'currencies']);
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
$router->post('/admin/faq', [Admin\FaqController::class, 'index']);

// News
$router->get('/admin/news', [Admin\NewsController::class, 'index']);
$router->post('/admin/news', [Admin\NewsController::class, 'index']);

// Custom Pages
$router->get('/admin/pages', [Admin\PagesController::class, 'index']);
$router->post('/admin/pages', [Admin\PagesController::class, 'index']);

// Newsletter (public)
$router->get('/newsletter/subscribe', [App\Controllers\NewsletterController::class, 'subscribe']);
$router->post('/newsletter/subscribe', [App\Controllers\NewsletterController::class, 'subscribe']);
$router->get('/newsletter/unsubscribe', [App\Controllers\NewsletterController::class, 'unsubscribe']);

// Newsletter
$router->get('/admin/newsletter', [Admin\NewsletterController::class, 'index']);
$router->post('/admin/newsletter', [Admin\NewsletterController::class, 'index']);

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

// Crypto Currencies (separate page)
$router->get('/admin/crypto-currencies', [Admin\CurrencyController::class, 'crypto']);
$router->post('/admin/crypto-currencies', [Admin\CurrencyController::class, 'crypto']);

// Exchange Rates
$router->get('/admin/exchange-rates', [Admin\ExchangeRatesController::class, 'index']);
$router->post('/admin/exchange-rates', [Admin\ExchangeRatesController::class, 'index']);

// Spin Rewards
$router->get('/admin/spin', [Admin\SpinController::class, 'index']);
$router->post('/admin/spin', [Admin\SpinController::class, 'index']);
$router->get('/admin/spin/history', [Admin\SpinController::class, 'history']);

// KYC
$router->get('/admin/kyc', [Admin\KycController::class, 'index']);
$router->get('/admin/kyc/{id}', [Admin\KycController::class, 'show']);
$router->post('/admin/kyc/{id}/approve', [Admin\KycController::class, 'approve']);
$router->post('/admin/kyc/{id}/reject', [Admin\KycController::class, 'reject']);

// Community
$router->get('/admin/community', [Admin\CommunityController::class, 'index']);
$router->post('/admin/community/{id}/delete', [Admin\CommunityController::class, 'deletePost']);
$router->get('/admin/community/bots', [Admin\CommunityController::class, 'bots']);
$router->post('/admin/community/bots', [Admin\CommunityController::class, 'bots']);

// Rewards Hub
$router->get('/admin/rewards', [Admin\RewardsController::class, 'index']);
$router->post('/admin/rewards', [Admin\RewardsController::class, 'index']);

// Withdrawal Methods
$router->get('/admin/withdrawal-methods', [Admin\WithdrawalMethodsController::class, 'index']);
$router->post('/admin/withdrawal-methods', [Admin\WithdrawalMethodsController::class, 'index']);

// Scam Reports (admin)
$router->get('/admin/scam-reports', [Admin\ScamReportsController::class, 'index']);
$router->post('/admin/scam-reports', [Admin\ScamReportsController::class, 'index']);
$router->get('/admin/scam-reports/{id}', [Admin\ScamReportsController::class, 'show']);

// User Spin
$router->get('/user/spin', [User\SpinController::class, 'index']);
$router->post('/user/spin', [User\SpinController::class, 'index']);

// Scam report submission (public)
$router->get('/report-scam', [User\ScamReportController::class, 'create']);
$router->post('/report-scam', [User\ScamReportController::class, 'create']);

// Notices
$router->get('/admin/notices', [Admin\NoticesController::class, 'index']);
$router->post('/admin/notices', [Admin\NoticesController::class, 'index']);

// SEO/Meta Manager
$router->get('/admin/seo', [Admin\SeoController::class, 'index']);
$router->post('/admin/seo', [Admin\SeoController::class, 'index']);

// Team Roles & Members
$router->get('/admin/team', [Admin\TeamController::class, 'index']);
$router->get('/admin/team/members', [Admin\TeamController::class, 'members']);
$router->post('/admin/team/members', [Admin\TeamController::class, 'members']);
$router->get('/admin/team/{id}/edit', [Admin\TeamController::class, 'editRole']);
$router->post('/admin/team/{id}/edit', [Admin\TeamController::class, 'editRole']);

// Support Tickets (Admin)
$router->get('/admin/support', [Admin\SupportController::class, 'index']);
$router->get('/admin/support/{id}', [Admin\SupportController::class, 'show']);
$router->post('/admin/support/{id}', [Admin\SupportController::class, 'show']);

// Support Tickets (User)
$router->get('/user/support', [User\SupportController::class, 'index']);
$router->get('/user/support/create', [User\SupportController::class, 'create']);
$router->post('/user/support/create', [User\SupportController::class, 'create']);
$router->get('/user/support/{id}', [User\SupportController::class, 'show']);
$router->post('/user/support/{id}', [User\SupportController::class, 'show']);

// Notices (mark read via AJAX)
$router->post('/user/notices/read', [User\DashboardController::class, 'markNoticeRead']);

// Quick Navigation
$router->get('/admin/quick-nav', [Admin\QuickNavController::class, 'index']);

return $router;
