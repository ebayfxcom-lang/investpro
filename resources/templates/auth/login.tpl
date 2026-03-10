{extends file="layouts/auth.tpl"}
{block name="content"}
<h4 class="fw-bold mb-1">Welcome Back</h4>
<p class="text-muted small mb-4">Sign in to your account to continue</p>

<form method="POST" action="/login">
  <input type="hidden" name="_csrf_token" value="{$csrf_token}">

  <div class="mb-3">
    <label class="form-label fw-semibold">Email Address</label>
    <input type="email" name="email" class="form-control" placeholder="you@example.com" required autofocus>
  </div>

  <div class="mb-3">
    <label class="form-label fw-semibold">Password</label>
    <input type="password" name="password" class="form-control" placeholder="••••••••" required>
  </div>

  <button type="submit" class="btn btn-primary w-100 mb-3">
    <i class="fas fa-sign-in-alt me-2"></i>Sign In
  </button>

  <div class="text-center text-muted small">
    Don't have an account? <a href="/register" class="text-primary fw-semibold">Register here</a>
  </div>
</form>
{/block}
