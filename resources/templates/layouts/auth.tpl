<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{$title|default:'Login'} - {$app.name}</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
  <style>
    body { background: linear-gradient(135deg, #1e3a8a 0%, #1e40af 50%, #1d4ed8 100%); min-height: 100vh; font-family: 'Segoe UI', sans-serif; }
    .auth-card { max-width: 420px; margin: 0 auto; padding: 2rem; background: #fff; border-radius: 16px; box-shadow: 0 20px 60px rgba(0,0,0,.3); }
    .auth-logo { text-align: center; margin-bottom: 2rem; }
    .auth-logo a { font-size: 2rem; font-weight: 800; color: #1e40af; text-decoration: none; }
    .auth-logo a span { color: #f59e0b; }
    .auth-logo .tagline { color: #6b7280; font-size: .85rem; }
    .form-control { border-radius: 8px; border-color: #d1d5db; padding: .75rem 1rem; }
    .form-control:focus { border-color: #1e40af; box-shadow: 0 0 0 .2rem rgba(30,64,175,.15); }
    .btn-primary { background: #1e40af; border-color: #1e40af; border-radius: 8px; padding: .75rem; font-weight: 600; }
    .btn-primary:hover { background: #1d3a9e; border-color: #1d3a9e; }
    .features { display: flex; justify-content: center; gap: 2rem; margin-top: 2rem; flex-wrap: wrap; }
    .feature { text-align: center; color: rgba(255,255,255,.8); }
    .feature i { font-size: 1.5rem; display: block; margin-bottom: .5rem; color: #f59e0b; }
    .feature span { font-size: .75rem; }
  </style>
</head>
<body class="d-flex align-items-center justify-content-center py-5">
  <div class="w-100 px-3">
    <div class="auth-logo">
      <a href="/">Invest<span>Pro</span></a>
      <div class="tagline text-white-50 mt-2">Professional Investment Platform</div>
    </div>

    {if $flash.success}
      <div class="alert alert-success mb-3">
        <i class="fas fa-check-circle me-2"></i>{$flash.success}
      </div>
    {/if}
    {if $flash.error}
      <div class="alert alert-danger mb-3">
        <i class="fas fa-exclamation-circle me-2"></i>{$flash.error}
      </div>
    {/if}

    <div class="auth-card">
      {block name="content"}{/block}
    </div>

    <div class="features">
      <div class="feature"><i class="fas fa-shield-halved"></i><span>Secure</span></div>
      <div class="feature"><i class="fas fa-chart-line"></i><span>High Returns</span></div>
      <div class="feature"><i class="fas fa-clock"></i><span>24/7 Support</span></div>
      <div class="feature"><i class="fas fa-globe"></i><span>Global Access</span></div>
    </div>
  </div>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
