<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Admin Login - {$app.name}</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
  <style>
    body { background: linear-gradient(135deg,#1a1d23,#2d3139); min-height:100vh; font-family:'Segoe UI',sans-serif; display:flex; align-items:center; justify-content:center; }
    .login-card { background:#fff; border-radius:16px; padding:2.5rem; width:100%; max-width:400px; box-shadow:0 25px 80px rgba(0,0,0,.5); }
    .login-logo { text-align:center; margin-bottom:2rem; }
    .login-logo h2 { font-weight:800; color:#1a1d23; } .login-logo h2 span { color:#f59e0b; }
    .login-logo p { color:#6b7280; font-size:.85rem; }
    .form-control { border-radius:8px; padding:.75rem 1rem; }
    .btn-dark { background:#1a1d23; border-color:#1a1d23; border-radius:8px; padding:.75rem; font-weight:600; }
    .btn-dark:hover { background:#111318; }
    .admin-badge { background:#1a1d23; color:#f59e0b; padding:.35rem .75rem; border-radius:20px; font-size:.75rem; font-weight:600; display:inline-block; margin-bottom:1rem; }
  </style>
</head>
<body>
<div class="login-card">
  <div class="login-logo">
    <div class="admin-badge"><i class="fas fa-shield-halved me-1"></i>Admin Access</div>
    <h2>Invest<span>Pro</span></h2>
    <p>Administration Panel</p>
  </div>

  {if $flash.error}
    <div class="alert alert-danger small"><i class="fas fa-exclamation-circle me-1"></i>{$flash.error}</div>
  {/if}

  <form method="POST" action="/admin/login">
    <input type="hidden" name="_csrf_token" value="{$csrf_token}">
    <div class="mb-3">
      <label class="form-label fw-semibold small">Admin Email</label>
      <input type="email" name="email" class="form-control" placeholder="admin@example.com" required autofocus>
    </div>
    <div class="mb-4">
      <label class="form-label fw-semibold small">Password</label>
      <input type="password" name="password" class="form-control" placeholder="••••••••" required>
    </div>
    <button type="submit" class="btn btn-dark w-100">
      <i class="fas fa-lock me-2"></i>Sign In to Admin
    </button>
  </form>

  <div class="text-center mt-3">
    <a href="/" class="text-muted small"><i class="fas fa-arrow-left me-1"></i>Back to site</a>
  </div>
</div>
</body>
</html>
