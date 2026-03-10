<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{$title|default:'Dashboard'} - {$app.name}</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
  <style>
    :root { --primary: #1e40af; --accent: #f59e0b; }
    body { background: #f0f2f5; font-family: 'Segoe UI', sans-serif; }
    .sidebar { position: fixed; top: 0; left: 0; width: 240px; height: 100vh; background: linear-gradient(180deg, #1e3a8a 0%, #1e40af 100%); overflow-y: auto; z-index: 1000; }
    .sidebar-brand { padding: 1.5rem; border-bottom: 1px solid rgba(255,255,255,.15); }
    .sidebar-brand a { color: #fff; text-decoration: none; font-size: 1.4rem; font-weight: 700; }
    .sidebar-brand a span { color: var(--accent); }
    .sidebar .nav-link { color: rgba(255,255,255,.8); padding: .65rem 1.5rem; display: flex; align-items: center; gap: .75rem; font-size: .9rem; border-radius: 0; }
    .sidebar .nav-link:hover, .sidebar .nav-link.active { color: #fff; background: rgba(255,255,255,.15); }
    .sidebar .nav-link i { width: 18px; text-align: center; }
    .nav-divider { border-top: 1px solid rgba(255,255,255,.1); margin: .5rem 0; }
    .main-content { margin-left: 240px; min-height: 100vh; }
    .top-bar { background: #fff; padding: .9rem 1.5rem; border-bottom: 1px solid #e5e7eb; display: flex; justify-content: space-between; align-items: center; }
    .page-content { padding: 1.5rem; }
    .card { border: none; box-shadow: 0 2px 8px rgba(0,0,0,.06); border-radius: 12px; }
    .card-stat { border-left: 4px solid; }
    .stat-value { font-size: 1.6rem; font-weight: 700; color: #1f2937; }
    .stat-label { font-size: .8rem; color: #6b7280; text-transform: uppercase; letter-spacing: .5px; }
    .table th { font-size: .8rem; text-transform: uppercase; color: #9ca3af; font-weight: 600; border-top: none; }
    .badge-active { background: #d1fae5; color: #065f46; }
    .badge-pending { background: #fef3c7; color: #92400e; }
    .badge-completed { background: #dbeafe; color: #1e40af; }
    .badge-rejected { background: #fee2e2; color: #991b1b; }
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
    <div class="nav-divider"></div>
    <a class="nav-link" href="/user/withdraw"><i class="fas fa-money-bill-wave"></i> Withdraw Funds</a>
    <a class="nav-link" href="/user/withdrawals"><i class="fas fa-clock-rotate-left"></i> Withdraw History</a>
    <div class="nav-divider"></div>
    <a class="nav-link" href="/user/security"><i class="fas fa-shield-halved"></i> Security</a>
    <a class="nav-link" href="/user/settings"><i class="fas fa-user-cog"></i> Settings</a>
    <a class="nav-link text-warning" href="/logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
  </nav>
</div>

<div class="main-content">
  <div class="top-bar">
    <div class="d-flex align-items-center gap-3">
      <button class="btn btn-link text-dark p-0 d-md-none" onclick="document.getElementById('sidebar').classList.toggle('open')">
        <i class="fas fa-bars"></i>
      </button>
      <span class="fw-semibold text-dark">{$title|default:'Dashboard'}</span>
    </div>
    <div class="d-flex align-items-center gap-3">
      <span class="text-muted small"><i class="fas fa-user-circle me-1"></i>{$user.username|default:$session->get('auth_user.username')}</span>
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
</body>
</html>
