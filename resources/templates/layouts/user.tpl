<!DOCTYPE html>
<html lang="en" data-bs-theme="dark" id="htmlRoot">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{$title|default:'Dashboard'} - {$app.name}</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
  <style>
    /* ── Binance-inspired dark theme (default) ── */
    :root {
      --ip-sidebar-bg: #161a1e;
      --ip-sidebar-hover: #1e2328;
      --ip-accent: #f0b90b;
      --ip-primary: #1e40af;
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
      --ip-sidebar-bg: #1e3a8a;
      --ip-sidebar-hover: rgba(255,255,255,.15);
      --ip-accent: #f59e0b;
      --ip-primary: #1e40af;
      --ip-body-bg: #f0f2f5;
      --ip-card-bg: #fff;
      --ip-card-border: rgba(0,0,0,.06);
      --ip-text: #1f2937;
      --ip-text-muted: #6b7280;
      --ip-topbar-bg: #fff;
      --ip-topbar-border: #e5e7eb;
      --ip-table-head: #9ca3af;
      --ip-input-bg: #fff;
      --ip-input-border: #d1d5db;
    }
    body { background: var(--ip-body-bg); font-family: 'Segoe UI', sans-serif; color: var(--ip-text); transition: background .2s; }
    .sidebar { position: fixed; top: 0; left: 0; width: 240px; height: 100vh; background: var(--ip-sidebar-bg); overflow-y: auto; z-index: 1000; border-right: 1px solid var(--ip-card-border); }
    .sidebar-brand { padding: 1.5rem; border-bottom: 1px solid rgba(255,255,255,.1); }
    .sidebar-brand a { color: #fff; text-decoration: none; font-size: 1.4rem; font-weight: 700; }
    .sidebar-brand a span { color: var(--ip-accent); }
    .sidebar .nav-link { color: rgba(255,255,255,.75); padding: .65rem 1.5rem; display: flex; align-items: center; gap: .75rem; font-size: .9rem; border-radius: 0; transition: background .15s; }
    .sidebar .nav-link:hover, .sidebar .nav-link.active { color: #fff; background: var(--ip-sidebar-hover); border-left: 3px solid var(--ip-accent); padding-left: calc(1.5rem - 3px); }
    .sidebar .nav-link i { width: 18px; text-align: center; opacity: .8; }
    .nav-divider { border-top: 1px solid rgba(255,255,255,.1); margin: .5rem 0; }
    .main-content { margin-left: 240px; min-height: 100vh; }
    .top-bar { background: var(--ip-topbar-bg); padding: .9rem 1.5rem; border-bottom: 1px solid var(--ip-topbar-border); display: flex; justify-content: space-between; align-items: center; }
    .page-content { padding: 1.5rem; }
    .card { background: var(--ip-card-bg); border: 1px solid var(--ip-card-border); box-shadow: 0 2px 8px rgba(0,0,0,.15); border-radius: 12px; color: var(--ip-text); }
    .card-header { background: transparent !important; border-bottom: 1px solid var(--ip-card-border); }
    .card-stat { border-left: 4px solid; }
    .stat-value { font-size: 1.6rem; font-weight: 700; color: var(--ip-text); }
    .stat-label { font-size: .8rem; color: var(--ip-text-muted); text-transform: uppercase; letter-spacing: .5px; }
    .table { color: var(--ip-text); }
    .table th { font-size: .8rem; text-transform: uppercase; color: var(--ip-table-head); font-weight: 600; border-top: none; }
    .table-striped tbody tr:nth-of-type(odd) { background: rgba(255,255,255,.03); }
    .table-hover tbody tr:hover { background: rgba(255,255,255,.05); }
    .form-control, .form-select { background: var(--ip-input-bg); border-color: var(--ip-input-border); color: var(--ip-text); }
    .form-control:focus, .form-select:focus { background: var(--ip-input-bg); color: var(--ip-text); border-color: var(--ip-accent); box-shadow: 0 0 0 .2rem rgba(240,185,11,.15); }
    .form-text { color: var(--ip-text-muted); }
    .badge-active { background: rgba(16,185,129,.15); color: #34d399; }
    .badge-pending { background: rgba(245,158,11,.15); color: #fbbf24; }
    .badge-completed { background: rgba(59,130,246,.15); color: #60a5fa; }
    .badge-rejected { background: rgba(239,68,68,.15); color: #f87171; }
    .btn-accent { background: var(--ip-accent); border-color: var(--ip-accent); color: #000; font-weight: 600; }
    .btn-accent:hover { background: #d97706; border-color: #d97706; color: #000; }
    .text-muted { color: var(--ip-text-muted) !important; }
    /* Theme toggle button */
    #themeToggle { cursor: pointer; background: none; border: 1px solid var(--ip-card-border); border-radius: 20px; padding: .3rem .7rem; color: var(--ip-text-muted); font-size: .85rem; }
    #themeToggle:hover { border-color: var(--ip-accent); color: var(--ip-accent); }
    @media (max-width: 768px) { .sidebar { transform: translateX(-100%); } .main-content { margin-left: 0; } .sidebar.open { transform: none; } }
  </style>
</head>
<body>

<div class="sidebar" id="sidebar">
  <div class="sidebar-brand">
    <a href="/user/dashboard">Invest<span>Pro</span></a>
    <div class="text-white-50 small mt-1">Member Dashboard</div>
  </div>
  <nav class="py-2">
    <a class="nav-link" href="/user/dashboard"><i class="fas fa-th-large"></i> Dashboard</a>
    <div class="nav-divider"></div>
    <a class="nav-link" href="/user/deposit"><i class="fas fa-plus-circle"></i> Make Deposit</a>
    <a class="nav-link" href="/user/deposits/active"><i class="fas fa-chart-line"></i> Active Deposits</a>
    <a class="nav-link" href="/user/deposits/history"><i class="fas fa-history"></i> Deposit History</a>
    <div class="nav-divider"></div>
    <a class="nav-link" href="/user/earnings"><i class="fas fa-coins"></i> Earnings</a>
    <a class="nav-link" href="/user/referrals"><i class="fas fa-share-nodes"></i> Referrals</a>
    <a class="nav-link" href="/user/spin"><i class="fas fa-gamepad"></i> Spin &amp; Earn</a>
    <div class="nav-divider"></div>
    <a class="nav-link" href="/user/withdraw"><i class="fas fa-money-bill-wave"></i> Withdraw Funds</a>
    <a class="nav-link" href="/user/withdrawals"><i class="fas fa-clock-rotate-left"></i> Withdraw History</a>
    <div class="nav-divider"></div>
    {if $settings_kyc_enabled}
    <a class="nav-link" href="/user/kyc"><i class="fas fa-id-card"></i> KYC Verification</a>
    {/if}
    {if $settings_community_enabled}
    <a class="nav-link" href="/user/community"><i class="fas fa-comments"></i> Community</a>
    {/if}
    {if $settings_rewards_enabled}
    <a class="nav-link" href="/user/rewards"><i class="fas fa-gift"></i> Rewards Hub</a>
    {/if}
    <div class="nav-divider"></div>
    <a class="nav-link" href="/user/security"><i class="fas fa-shield-halved"></i> Security</a>
    <a class="nav-link" href="/user/settings"><i class="fas fa-user-cog"></i> Settings</a>
    <a class="nav-link" style="color:rgba(255,80,80,.8)" href="/logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
  </nav>
</div>

<div class="main-content">
  <div class="top-bar">
    <div class="d-flex align-items-center gap-3">
      <button class="btn btn-link p-0 d-md-none" style="color:var(--ip-text)" onclick="document.getElementById('sidebar').classList.toggle('open')">
        <i class="fas fa-bars"></i>
      </button>
      <span class="fw-semibold" style="color:var(--ip-text)">{$title|default:'Dashboard'}</span>
    </div>
    <div class="d-flex align-items-center gap-3">
      <button id="themeToggle" title="Toggle theme" onclick="toggleTheme()">
        <i class="fas fa-sun" id="themeIcon"></i>
      </button>
      <span class="small" style="color:var(--ip-text-muted)"><i class="fas fa-user-circle me-1"></i>{$user.username|default:$session->get('auth_user.username')}</span>
      <a href="/logout" class="btn btn-sm btn-outline-secondary">Logout</a>
    </div>
  </div>

  <div class="page-content">
    {if $flash.success}
      <div class="alert alert-success alert-dismissible fade show">
        <i class="fas fa-check-circle me-2"></i>{$flash.success}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
      </div>
    {/if}
    {if $flash.error}
      <div class="alert alert-danger alert-dismissible fade show">
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
  var stored = localStorage.getItem('ip_theme') || 'dark';
  applyTheme(stored, false);
})();
function applyTheme(theme, save) {
  var html  = document.getElementById('htmlRoot');
  var icon  = document.getElementById('themeIcon');
  if (theme === 'light') {
    html.setAttribute('data-bs-theme', 'light');
    html.setAttribute('data-theme', 'light');
    if (icon) { icon.className = 'fas fa-moon'; }
  } else {
    html.setAttribute('data-bs-theme', 'dark');
    html.removeAttribute('data-theme');
    if (icon) { icon.className = 'fas fa-sun'; }
  }
  if (save) localStorage.setItem('ip_theme', theme);
}
function toggleTheme() {
  var current = localStorage.getItem('ip_theme') || 'dark';
  applyTheme(current === 'dark' ? 'light' : 'dark', true);
}
</script>
</body>
</html>
