<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{$title|default:'Login'} - {$app.name}</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
  <style>
    :root {
      --auth-primary: #f0b90b;
      --auth-primary-hover: #d97706;
      --auth-dark: #0d1117;
      --auth-card: #161b22;
      --auth-card-inner: #1c2128;
      --auth-text: #e6edf3;
      --auth-muted: #8b949e;
      --auth-border: rgba(255,255,255,.07);
      --auth-input-bg: #0d1117;
      --auth-input-border: rgba(255,255,255,.12);
    }
    * { box-sizing: border-box; }
    body {
      background: var(--auth-dark);
      color: var(--auth-text);
      font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
      min-height: 100vh;
      margin: 0;
    }
    /* Top navigation bar */
    .auth-navbar {
      background: rgba(22,27,34,.95);
      backdrop-filter: blur(10px);
      border-bottom: 1px solid var(--auth-border);
      padding: .75rem 0;
    }
    .auth-navbar .brand {
      font-size: 1.4rem;
      font-weight: 700;
      color: var(--auth-primary);
      text-decoration: none;
      letter-spacing: -.5px;
    }
    .auth-navbar .nav-links a {
      color: rgba(255,255,255,.7);
      text-decoration: none;
      font-size: .875rem;
      transition: color .15s;
    }
    .auth-navbar .nav-links a:hover { color: var(--auth-primary); }
    /* Main content wrapper */
    .auth-wrapper {
      min-height: calc(100vh - 56px);
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 2rem 1rem;
    }
    .auth-container { width: 100%; max-width: 460px; }
    /* Card */
    .auth-card {
      background: var(--auth-card);
      border: 1px solid var(--auth-border);
      border-radius: 16px;
      padding: 2rem 2.25rem;
      box-shadow: 0 20px 60px rgba(0,0,0,.4);
    }
    .auth-card h4 { color: var(--auth-text); font-weight: 700; }
    .auth-card .subtitle { color: var(--auth-muted); font-size: .875rem; }
    /* Form controls */
    .form-label { color: var(--auth-muted); font-size: .8125rem; font-weight: 500; margin-bottom: .35rem; }
    .form-control, .form-select {
      background: var(--auth-input-bg);
      border: 1px solid var(--auth-input-border);
      color: var(--auth-text);
      border-radius: 8px;
      padding: .65rem 1rem;
      font-size: .9rem;
      transition: border-color .15s, box-shadow .15s;
    }
    .form-control:focus, .form-select:focus {
      background: var(--auth-input-bg);
      color: var(--auth-text);
      border-color: var(--auth-primary);
      box-shadow: 0 0 0 .2rem rgba(240,185,11,.18);
      outline: none;
    }
    .form-control::placeholder { color: var(--auth-muted); opacity: .7; }
    .form-select option { background: var(--auth-card); color: var(--auth-text); }
    .form-text { color: var(--auth-muted); font-size: .78rem; }
    /* Buttons */
    .btn-primary {
      background: var(--auth-primary);
      border-color: var(--auth-primary);
      color: #000;
      font-weight: 600;
      border-radius: 8px;
      padding: .7rem 1.5rem;
      transition: background .15s, border-color .15s, transform .1s;
    }
    .btn-primary:hover, .btn-primary:focus {
      background: var(--auth-primary-hover);
      border-color: var(--auth-primary-hover);
      color: #000;
      transform: translateY(-1px);
    }
    .btn-primary:active { transform: translateY(0); }
    /* Alerts */
    .alert-success {
      background: rgba(34,197,94,.12);
      border-color: rgba(34,197,94,.3);
      color: #4ade80;
      border-radius: 8px;
    }
    .alert-info {
      background: rgba(59,130,246,.12);
      border-color: rgba(59,130,246,.3);
      color: #60a5fa;
      border-radius: 8px;
    }
    .alert-danger {
      background: rgba(239,68,68,.12);
      border-color: rgba(239,68,68,.3);
      color: #f87171;
      border-radius: 8px;
    }
    /* Links */
    a { color: var(--auth-primary); }
    a:hover { color: var(--auth-primary-hover); }
    /* Divider */
    .auth-divider { border-color: var(--auth-border); margin: 1.5rem 0; }
    /* Features strip */
    .features-strip {
      display: flex;
      justify-content: center;
      gap: 2rem;
      margin-top: 1.75rem;
      flex-wrap: wrap;
    }
    .feature-item {
      text-align: center;
      color: var(--auth-muted);
    }
    .feature-item i {
      font-size: 1.25rem;
      display: block;
      margin-bottom: .4rem;
      color: var(--auth-primary);
    }
    .feature-item span { font-size: .72rem; }
  </style>
</head>
<body>
  <!-- Top navigation bar (matches public pages) -->
  <nav class="auth-navbar">
    <div class="container d-flex align-items-center justify-content-between">
      <a class="brand" href="/">{$app.name}</a>
      <div class="nav-links d-flex gap-3 align-items-center">
        <a href="/plans">Plans</a>
        <a href="/about">About</a>
        <a href="/faq">FAQ</a>
      </div>
    </div>
  </nav>

  <!-- Main auth content -->
  <div class="auth-wrapper">
    <div class="auth-container">

      {if $flash.success}
        <div class="alert alert-success mb-3 d-flex align-items-center gap-2">
          <i class="fas fa-check-circle"></i>
          <span>{$flash.success}</span>
        </div>
      {/if}
      {if $flash.error}
        <div class="alert alert-danger mb-3 d-flex align-items-center gap-2">
          <i class="fas fa-exclamation-circle"></i>
          <span>{$flash.error}</span>
        </div>
      {/if}

      <div class="auth-card">
        {block name="content"}{/block}
      </div>

      <!-- Feature strip -->
      <div class="features-strip">
        <div class="feature-item"><i class="fas fa-shield-halved"></i><span>Secure</span></div>
        <div class="feature-item"><i class="fas fa-chart-line"></i><span>High Returns</span></div>
        <div class="feature-item"><i class="fas fa-clock"></i><span>24/7 Support</span></div>
        <div class="feature-item"><i class="fas fa-globe"></i><span>Global Access</span></div>
      </div>

    </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
