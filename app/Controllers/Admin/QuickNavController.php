<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;

class QuickNavController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');

        $navGroups = [
            'Overview' => [
                ['label' => 'Dashboard', 'url' => '/admin/dashboard', 'icon' => 'fas fa-tachometer-alt'],
                ['label' => 'Performance', 'url' => '/admin/performance', 'icon' => 'fas fa-chart-line'],
            ],
            'Investments' => [
                ['label' => 'Investment Plans', 'url' => '/admin/plans', 'icon' => 'fas fa-layer-group'],
                ['label' => 'Create Plan', 'url' => '/admin/plans/create', 'icon' => 'fas fa-plus'],
                ['label' => 'All Deposits', 'url' => '/admin/deposits', 'icon' => 'fas fa-arrow-down-to-bracket'],
                ['label' => 'Expiring Deposits', 'url' => '/admin/deposits/expiring', 'icon' => 'fas fa-clock'],
                ['label' => 'System Wallets', 'url' => '/admin/deposit-wallets', 'icon' => 'fas fa-wallet'],
                ['label' => 'All Withdrawals', 'url' => '/admin/withdrawals', 'icon' => 'fas fa-money-bill-transfer'],
                ['label' => 'Withdrawal Methods', 'url' => '/admin/withdrawal-methods', 'icon' => 'fas fa-sliders'],
                ['label' => 'All Transactions', 'url' => '/admin/transactions', 'icon' => 'fas fa-list-alt'],
                ['label' => 'Earnings', 'url' => '/admin/earnings', 'icon' => 'fas fa-coins'],
            ],
            'Users' => [
                ['label' => 'All Users', 'url' => '/admin/users', 'icon' => 'fas fa-users'],
                ['label' => 'Blacklist', 'url' => '/admin/blacklist', 'icon' => 'fas fa-ban'],
                ['label' => 'Referral Earnings', 'url' => '/admin/referrals', 'icon' => 'fas fa-share-nodes'],
                ['label' => 'IP Checks', 'url' => '/admin/ip-checks', 'icon' => 'fas fa-shield-halved'],
                ['label' => 'KYC Verification', 'url' => '/admin/kyc', 'icon' => 'fas fa-id-card'],
            ],
            'Team & Roles' => [
                ['label' => 'Team Roles', 'url' => '/admin/team', 'icon' => 'fas fa-users-gear'],
                ['label' => 'Team Members', 'url' => '/admin/team/members', 'icon' => 'fas fa-user-tie'],
            ],
            'Content & SEO' => [
                ['label' => 'News', 'url' => '/admin/news', 'icon' => 'fas fa-newspaper'],
                ['label' => 'FAQ', 'url' => '/admin/faq', 'icon' => 'fas fa-question-circle'],
                ['label' => 'Custom Pages', 'url' => '/admin/pages', 'icon' => 'fas fa-file-alt'],
                ['label' => 'Newsletter', 'url' => '/admin/newsletter', 'icon' => 'fas fa-envelope'],
                ['label' => 'SEO & Meta', 'url' => '/admin/seo', 'icon' => 'fas fa-search'],
            ],
            'Support' => [
                ['label' => 'Support Tickets', 'url' => '/admin/support', 'icon' => 'fas fa-headset'],
                ['label' => 'User Notices', 'url' => '/admin/notices', 'icon' => 'fas fa-bell'],
                ['label' => 'Scam Reports', 'url' => '/admin/scam-reports', 'icon' => 'fas fa-flag'],
            ],
            'Community' => [
                ['label' => 'Community Feed', 'url' => '/admin/community', 'icon' => 'fas fa-comments'],
                ['label' => 'Bot Profiles', 'url' => '/admin/community/bots', 'icon' => 'fas fa-robot'],
            ],
            'Finance' => [
                ['label' => 'Currencies', 'url' => '/admin/currencies', 'icon' => 'fas fa-dollar-sign'],
                ['label' => 'Crypto Currencies', 'url' => '/admin/crypto-currencies', 'icon' => 'fab fa-bitcoin'],
                ['label' => 'Exchange Rates', 'url' => '/admin/exchange-rates', 'icon' => 'fas fa-chart-bar'],
                ['label' => 'Rewards Hub', 'url' => '/admin/rewards', 'icon' => 'fas fa-gift'],
                ['label' => 'Spin Settings', 'url' => '/admin/spin', 'icon' => 'fas fa-gamepad'],
                ['label' => 'Spin History', 'url' => '/admin/spin/history', 'icon' => 'fas fa-history'],
            ],
            'Settings' => [
                ['label' => 'General Settings', 'url' => '/admin/settings', 'icon' => 'fas fa-cog'],
                ['label' => 'Referral Settings', 'url' => '/admin/settings/referral', 'icon' => 'fas fa-share-nodes'],
                ['label' => 'Currency Settings', 'url' => '/admin/settings/currencies', 'icon' => 'fas fa-dollar-sign'],
                ['label' => 'Email Templates', 'url' => '/admin/settings/email-templates', 'icon' => 'fas fa-envelope-open'],
                ['label' => 'Security Settings', 'url' => '/admin/settings/security', 'icon' => 'fas fa-shield-halved'],
                ['label' => 'Admin Profile', 'url' => '/admin/profile', 'icon' => 'fas fa-user-shield'],
            ],
        ];

        $this->view('admin/quick-nav', [
            'title'      => 'Quick Navigation',
            'nav_groups' => $navGroups,
            'admin'      => Auth::user('admin'),
        ]);
    }
}
