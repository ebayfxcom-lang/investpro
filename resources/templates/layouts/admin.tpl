<!DOCTYPE html>
<html lang="en" data-bs-theme="dark" id="adminHtmlRoot">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{$title|default:'Dashboard'} - {$app.name} Admin</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
  <style>
    /* ── Binance-inspired admin dark theme ── */
    :root {
      --sidebar-width: 260px;
      --ip-sidebar-bg: #161a1e;
      --ip-sidebar-hover: #1e2328;
      --ip-accent: #f0b90b;
      --ip-body-bg: #0d1117;
      --ip-card-bg: #161b22;
      --ip-card-border: rgba(255,255,255,.07);
      --ip-text: #e6edf3;
      --ip-text-muted: #8b949e;
      --ip-topbar-bg: #161b22;
      --ip-topbar-border: rgba(255,255,255,.07);
      --ip-table-head: #8b949e;
      --ip-input-bg: #0d1117;
      --ip-input-border: rgba(255,255,255,.15);
    }
    [data-theme="light"] {
      --ip-sidebar-bg: #1a1d23;
      --ip-sidebar-hover: #2d3139;
      --ip-accent: #f59e0b;
      --ip-body-bg: #f0f2f5;
      --ip-card-bg: #fff;
      --ip-card-border: rgba(0,0,0,.06);
      --ip-text: #1f2937;
      --ip-text-muted: #6b7280;
      --ip-topbar-bg: #fff;
      --ip-topbar-border: #e0e0e0;
      --ip-table-head: #6b7280;
      --ip-input-bg: #fff;
      --ip-input-border: #d1d5db;
    }
    body { background: var(--ip-body-bg); font-family: 'Segoe UI', sans-serif; color: var(--ip-text); transition: background .2s; }
    .sidebar { position: fixed; top: 0; left: 0; width: var(--sidebar-width); height: 100vh; background: var(--ip-sidebar-bg); overflow-y: auto; z-index: 1000; transition: transform .3s; border-right: 1px solid var(--ip-card-border); }
    .sidebar-brand { padding: 1.5rem; border-bottom: 1px solid rgba(255,255,255,.1); }
    .sidebar-brand a { color: var(--ip-accent); text-decoration: none; font-size: 1.4rem; font-weight: 700; }
    .sidebar-brand span { color: #fff; }
    .nav-section { padding: .5rem 1rem; color: rgba(255,255,255,.4); font-size: .7rem; text-transform: uppercase; letter-spacing: 1px; margin-top: .5rem; }
    .sidebar .nav-link { color: rgba(255,255,255,.75); padding: .6rem 1.5rem; border-radius: 0; display: flex; align-items: center; gap: .75rem; font-size: .9rem; transition: background .15s; }
    .sidebar .nav-link:hover, .sidebar .nav-link.active { color: #fff; background: var(--ip-sidebar-hover); border-left: 3px solid var(--ip-accent); padding-left: calc(1.5rem - 3px); }
    .sidebar .nav-link i { width: 18px; text-align: center; opacity: .8; }
    .main-content { margin-left: var(--sidebar-width); min-height: 100vh; }
    .top-nav { background: var(--ip-topbar-bg); border-bottom: 1px solid var(--ip-topbar-border); padding: 1rem 1.5rem; display: flex; align-items: center; justify-content: space-between; }
    .page-content { padding: 1.5rem; }
    .stat-card { background: var(--ip-card-bg); border-radius: 12px; padding: 1.5rem; border: 1px solid var(--ip-card-border); box-shadow: 0 2px 8px rgba(0,0,0,.15); }
    .stat-icon { width: 50px; height: 50px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 1.3rem; }
    .card { background: var(--ip-card-bg); border: 1px solid var(--ip-card-border); border-radius: 12px; color: var(--ip-text); }
    .card-header { background: transparent !important; border-bottom: 1px solid var(--ip-card-border); }
    .badge-status-active { background: rgba(16,185,129,.15); color: #34d399; }
    .badge-status-pending { background: rgba(245,158,11,.15); color: #fbbf24; }
    .badge-status-banned, .badge-status-rejected { background: rgba(239,68,68,.15); color: #f87171; }
    .badge-status-completed { background: rgba(59,130,246,.15); color: #60a5fa; }
    .table { color: var(--ip-text); }
    .table th { font-weight: 600; font-size: .85rem; text-transform: uppercase; letter-spacing: .5px; color: var(--ip-table-head); border-top: none; }
    .table-striped tbody tr:nth-of-type(odd) { background: rgba(255,255,255,.03); }
    .table-hover tbody tr:hover { background: rgba(255,255,255,.05); }
    .form-control, .form-select { background: var(--ip-input-bg); border-color: var(--ip-input-border); color: var(--ip-text); }
    .form-control:focus, .form-select:focus { background: var(--ip-input-bg); color: var(--ip-text); border-color: var(--ip-accent); box-shadow: 0 0 0 .2rem rgba(240,185,11,.15); }
    .btn-accent { background: var(--ip-accent); border-color: var(--ip-accent); color: #000; font-weight: 600; }
    .btn-accent:hover { background: #d97706; border-color: #d97706; color: #000; }
    .text-muted { color: var(--ip-text-muted) !important; }
    #adminThemeToggle { cursor: pointer; background: none; border: 1px solid var(--ip-card-border); border-radius: 20px; padding: .3rem .7rem; color: var(--ip-text-muted); font-size: .85rem; }
    #adminThemeToggle:hover { border-color: var(--ip-accent); color: var(--ip-accent); }
    @media (max-width: 768px) { .sidebar { transform: translateX(-100%); } .sidebar.show { transform: none; } .main-content { margin-left: 0; } }
  </style>
</head>
<body>

<div class="sidebar">
  <div class="sidebar-brand">
    <a href="/admin/dashboard"><i class="fas fa-chart-line me-2"></i><span>{$app.name}</span></a>
    <div class="text-muted small mt-1">Admin Panel</div>
  </div>
  <nav class="py-2">
    <div class="nav-section">Overview</div>
    <a class="nav-link" href="/admin/dashboard"><i class="fas fa-tachometer-alt"></i> Dashboard</a>

    <div class="nav-section">Investments</div>
    <a class="nav-link" href="/admin/plans"><i class="fas fa-layer-group"></i> Plans</a>
    <a class="nav-link" href="/admin/deposits"><i class="fas fa-arrow-down-to-bracket"></i> Deposits</a>
    <a class="nav-link" href="/admin/deposit-wallets"><i class="fas fa-wallet"></i> System Wallets</a>
    <a class="nav-link" href="/admin/deposits/expiring"><i class="fas fa-clock"></i> Expiring Deposits</a>
    <a class="nav-link" href="/admin/withdrawals"><i class="fas fa-money-bill-transfer"></i> Withdrawals</a>
    <a class="nav-link" href="/admin/withdrawal-methods"><i class="fas fa-sliders"></i> Withdrawal Methods</a>
    <a class="nav-link" href="/admin/transactions"><i class="fas fa-list-alt"></i> Transactions</a>
    <a class="nav-link" href="/admin/earnings"><i class="fas fa-coins"></i> Earnings</a>

    <div class="nav-section">Users</div>
    <a class="nav-link" href="/admin/users"><i class="fas fa-users"></i> Users</a>
    <a class="nav-link" href="/admin/blacklist"><i class="fas fa-ban"></i> Blacklist</a>
    <a class="nav-link" href="/admin/referrals"><i class="fas fa-share-nodes"></i> Referral Earnings</a>
    <a class="nav-link" href="/admin/users/add-funds"><i class="fas fa-wallet"></i> Add Funds</a>
    {if $settings_kyc_enabled}
    <a class="nav-link" href="/admin/kyc"><i class="fas fa-id-card"></i> KYC Submissions</a>
    {/if}

    <div class="nav-section">Configuration</div>
    <a class="nav-link" href="/admin/settings"><i class="fas fa-cog"></i> Settings</a>
    <a class="nav-link" href="/admin/settings/referral"><i class="fas fa-percent"></i> Referral Settings</a>
    <a class="nav-link" href="/admin/settings/currencies"><i class="fas fa-dollar-sign"></i> Currencies</a>
    <a class="nav-link" href="/admin/currencies"><i class="fas fa-coins"></i> Currency Manager</a>
    <a class="nav-link" href="/admin/exchange-rates"><i class="fas fa-chart-bar"></i> Exchange Rates</a>
    <a class="nav-link" href="/admin/currencies/price-history"><i class="fas fa-clock-rotate-left"></i> Price History</a>
    <a class="nav-link" href="/admin/settings/email-templates"><i class="fas fa-envelope"></i> Email Templates</a>
    <a class="nav-link" href="/admin/settings/security"><i class="fas fa-shield-halved"></i> Security</a>
    <a class="nav-link" href="/admin/faq"><i class="fas fa-question-circle"></i> FAQ Manager</a>
    <a class="nav-link" href="/admin/news"><i class="fas fa-newspaper"></i> News</a>
    <a class="nav-link" href="/admin/pages"><i class="fas fa-file-alt"></i> Custom Pages</a>
    <a class="nav-link" href="/admin/spin"><i class="fas fa-gamepad"></i> Spin Rewards</a>
    <a class="nav-link" href="/admin/spin/history"><i class="fas fa-history"></i> Spin History</a>
    {if $settings_rewards_enabled}
    <a class="nav-link" href="/admin/rewards"><i class="fas fa-gift"></i> Rewards Hub</a>
    {/if}
    {if $settings_community_enabled}
    <a class="nav-link" href="/admin/community"><i class="fas fa-comments"></i> Community</a>
    <a class="nav-link" href="/admin/community/bots"><i class="fas fa-robot"></i> Bot Profiles</a>
    {/if}

    <div class="nav-section">System</div>
    <a class="nav-link" href="/admin/newsletter"><i class="fas fa-mail-bulk"></i> Newsletter</a>
    <a class="nav-link" href="/admin/performance"><i class="fas fa-chart-bar"></i> Performance</a>
    <a class="nav-link" href="/admin/ip-checks"><i class="fas fa-globe"></i> IP Checks</a>
    <a class="nav-link" href="/admin/profile"><i class="fas fa-user-circle"></i> Admin Profile</a>
    <a class="nav-link text-danger" href="/admin/logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
  </nav>
</div>

<div class="main-content">
  <div class="top-nav">
    <div class="d-flex align-items-center gap-3">
      <button class="btn btn-link p-0 d-md-none" style="color:var(--ip-text)" id="sidebarToggle">
        <i class="fas fa-bars fa-lg"></i>
      </button>
      <h5 class="mb-0 fw-semibold" style="color:var(--ip-text)">{$title|default:'Dashboard'}</h5>
    </div>
    <div class="d-flex align-items-center gap-3">
      <button id="adminThemeToggle" title="Toggle theme" onclick="adminToggleTheme()">
        <i class="fas fa-sun" id="adminThemeIcon"></i>
      </button>
      <span class="small" style="color:var(--ip-text-muted)"><i class="fas fa-user me-1"></i>{$admin.username|default:'Admin'}</span>
      <a href="/admin/logout" class="btn btn-sm btn-outline-danger">
        <i class="fas fa-sign-out-alt me-1"></i>Logout
      </a>
    </div>
  </div>

  <div class="page-content">
    {if $flash.success}
      <div class="alert alert-success alert-dismissible fade show" role="alert">
        <i class="fas fa-check-circle me-2"></i>{$flash.success}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      </div>
    {/if}
    {if $flash.error}
      <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <i class="fas fa-exclamation-circle me-2"></i>{$flash.error}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      </div>
    {/if}

    {block name="content"}{/block}
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
(function() {
  var stored = localStorage.getItem('ip_admin_theme') || 'dark';
  adminApplyTheme(stored, false);
})();
function adminApplyTheme(theme, save) {
  var html = document.getElementById('adminHtmlRoot');
  var icon = document.getElementById('adminThemeIcon');
  if (theme === 'light') {
    html.setAttribute('data-bs-theme', 'light');
    html.setAttribute('data-theme', 'light');
    if (icon) icon.className = 'fas fa-moon';
  } else {
    html.setAttribute('data-bs-theme', 'dark');
    html.removeAttribute('data-theme');
    if (icon) icon.className = 'fas fa-sun';
  }
  if (save) localStorage.setItem('ip_admin_theme', theme);
}
function adminToggleTheme() {
  var current = localStorage.getItem('ip_admin_theme') || 'dark';
  adminApplyTheme(current === 'dark' ? 'light' : 'dark', true);
}
document.getElementById('sidebarToggle')?.addEventListener('click', () => {
  document.querySelector('.sidebar').classList.toggle('show');
});
</script>
</body>
</html>

  <div class="page-content">
    {if $flash.success}
      <div class="alert alert-success alert-dismissible fade show" role="alert">
        <i class="fas fa-check-circle me-2"></i>{$flash.success}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      </div>
    {/if}
    {if $flash.error}
      <div class="alert alert-danger alert-dismissible fade show" role="alert">
        <i class="fas fa-exclamation-circle me-2"></i>{$flash.error}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      </div>
    {/if}

    {block name="content"}{/block}
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
document.getElementById('sidebarToggle')?.addEventListener('click', () => {
  document.querySelector('.sidebar').classList.toggle('show');
});
</script>
</body>
</html>
