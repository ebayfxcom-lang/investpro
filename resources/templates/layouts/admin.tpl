<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{$title|default:'Dashboard'} - {$app.name} Admin</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
  <style>
    :root { --sidebar-width: 260px; --sidebar-bg: #1a1d23; --sidebar-hover: #2d3139; --accent: #f59e0b; }
    body { background: #f0f2f5; font-family: 'Segoe UI', sans-serif; }
    .sidebar { position: fixed; top: 0; left: 0; width: var(--sidebar-width); height: 100vh; background: var(--sidebar-bg); overflow-y: auto; z-index: 1000; transition: transform .3s; }
    .sidebar-brand { padding: 1.5rem; border-bottom: 1px solid rgba(255,255,255,.1); }
    .sidebar-brand a { color: var(--accent); text-decoration: none; font-size: 1.4rem; font-weight: 700; }
    .sidebar-brand span { color: #fff; }
    .nav-section { padding: .5rem 1rem; color: rgba(255,255,255,.4); font-size: .7rem; text-transform: uppercase; letter-spacing: 1px; margin-top: .5rem; }
    .sidebar .nav-link { color: rgba(255,255,255,.75); padding: .6rem 1.5rem; border-radius: 0; display: flex; align-items: center; gap: .75rem; font-size: .9rem; }
    .sidebar .nav-link:hover, .sidebar .nav-link.active { color: #fff; background: var(--sidebar-hover); border-left: 3px solid var(--accent); padding-left: calc(1.5rem - 3px); }
    .sidebar .nav-link i { width: 18px; text-align: center; opacity: .8; }
    .main-content { margin-left: var(--sidebar-width); min-height: 100vh; }
    .top-nav { background: #fff; border-bottom: 1px solid #e0e0e0; padding: 1rem 1.5rem; display: flex; align-items: center; justify-content: space-between; }
    .page-content { padding: 1.5rem; }
    .stat-card { background: #fff; border-radius: 12px; padding: 1.5rem; border: none; box-shadow: 0 2px 8px rgba(0,0,0,.05); }
    .stat-icon { width: 50px; height: 50px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 1.3rem; }
    .badge-status-active { background: #d1fae5; color: #065f46; }
    .badge-status-pending { background: #fef3c7; color: #92400e; }
    .badge-status-banned, .badge-status-rejected { background: #fee2e2; color: #991b1b; }
    .badge-status-completed { background: #dbeafe; color: #1e40af; }
    .table th { font-weight: 600; font-size: .85rem; text-transform: uppercase; letter-spacing: .5px; color: #6b7280; border-top: none; }
    .btn-accent { background: var(--accent); border-color: var(--accent); color: #000; font-weight: 600; }
    .btn-accent:hover { background: #d97706; border-color: #d97706; color: #000; }
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
    <a class="nav-link" href="/admin/deposits/expiring"><i class="fas fa-clock"></i> Expiring Deposits</a>
    <a class="nav-link" href="/admin/withdrawals"><i class="fas fa-money-bill-transfer"></i> Withdrawals</a>
    <a class="nav-link" href="/admin/transactions"><i class="fas fa-list-alt"></i> Transactions</a>
    <a class="nav-link" href="/admin/earnings"><i class="fas fa-coins"></i> Earnings</a>

    <div class="nav-section">Users</div>
    <a class="nav-link" href="/admin/users"><i class="fas fa-users"></i> Users</a>
    <a class="nav-link" href="/admin/blacklist"><i class="fas fa-ban"></i> Blacklist</a>
    <a class="nav-link" href="/admin/referrals"><i class="fas fa-share-nodes"></i> Referral Earnings</a>
    <a class="nav-link" href="/admin/users/add-funds"><i class="fas fa-wallet"></i> Add Funds</a>

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
      <button class="btn btn-link text-dark p-0 d-md-none" id="sidebarToggle">
        <i class="fas fa-bars fa-lg"></i>
      </button>
      <h5 class="mb-0 text-dark fw-semibold">{$title|default:'Dashboard'}</h5>
    </div>
    <div class="d-flex align-items-center gap-3">
      <span class="text-muted small"><i class="fas fa-user me-1"></i>{$admin.username|default:'Admin'}</span>
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
document.getElementById('sidebarToggle')?.addEventListener('click', () => {
  document.querySelector('.sidebar').classList.toggle('show');
});
</script>
</body>
</html>
