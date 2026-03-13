{extends file="layouts/auth.tpl"}
{block name="content"}
<div class="text-center mb-4">
  <div style="width:56px;height:56px;background:rgba(240,185,11,.12);border:1px solid rgba(240,185,11,.25);border-radius:14px;display:inline-flex;align-items:center;justify-content:center;margin-bottom:1rem;">
    <i class="fas fa-shield-halved" style="color:#f0b90b;font-size:1.4rem;"></i>
  </div>
  <h4 class="fw-bold mb-1">Two-Factor Verification</h4>
  <p class="subtitle">Enter the 6-digit code from your authenticator app</p>
</div>

<form method="POST" action="/login/2fa" novalidate>
  <input type="hidden" name="_csrf_token" value="{$csrf_token}">

  <div class="mb-4">
    <label class="form-label">Authentication Code</label>
    <input type="text" name="totp_code" class="form-control text-center font-monospace"
           style="font-size:1.5rem;letter-spacing:.3rem;padding:.75rem 1rem;"
           maxlength="8" placeholder="000000" autocomplete="one-time-code" autofocus required>
    <div class="form-text text-center">Enter the code from Google Authenticator, Authy, or use a backup code.</div>
  </div>

  <button type="submit" class="btn btn-primary w-100 mb-3">
    <i class="fas fa-check me-2"></i>Verify
  </button>

  <hr class="auth-divider">

  <div class="text-center" style="color:#8b949e;font-size:.875rem;">
    <a href="/login" style="color:#8b949e;text-decoration:none;"><i class="fas fa-arrow-left me-1"></i>Back to login</a>
  </div>
</form>
{/block}
