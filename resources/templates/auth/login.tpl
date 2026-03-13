{extends file="layouts/auth.tpl"}
{block name="content"}
<div class="text-center mb-4">
  <div style="width:56px;height:56px;background:rgba(240,185,11,.12);border:1px solid rgba(240,185,11,.25);border-radius:14px;display:inline-flex;align-items:center;justify-content:center;margin-bottom:1rem;">
    <i class="fas fa-lock" style="color:#f0b90b;font-size:1.4rem;"></i>
  </div>
  <h4 class="fw-bold mb-1">Welcome Back</h4>
  <p class="subtitle">Sign in to your {$app.name} account</p>
</div>

<form method="POST" action="/login" novalidate>
  <input type="hidden" name="_csrf_token" value="{$csrf_token}">

  <div class="mb-3">
    <label class="form-label">Email Address</label>
    <input type="email" name="email" class="form-control" placeholder="you@example.com" required autofocus autocomplete="email">
  </div>

  <div class="mb-4">
    <label class="form-label">Password</label>
    <input type="password" name="password" class="form-control" placeholder="••••••••" required autocomplete="current-password">
  </div>

  <button type="submit" class="btn btn-primary w-100 mb-3">
    <i class="fas fa-sign-in-alt me-2"></i>Sign In
  </button>

  <hr class="auth-divider">

  <div class="text-center" style="color:#8b949e;font-size:.875rem;">
    Don't have an account?&nbsp;<a href="/register" class="fw-semibold">Create account</a>
  </div>
</form>
{/block}
