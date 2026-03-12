{extends file="layouts/auth.tpl"}
{block name="content"}
<div class="text-center mb-4">
  <div class="mb-3">
    <span class="d-inline-flex align-items-center justify-content-center bg-primary bg-opacity-10 rounded-circle" style="width:64px;height:64px">
      <i class="fas fa-shield-halved fa-2x text-primary"></i>
    </span>
  </div>
  <h4 class="fw-bold mb-1">Two-Factor Verification</h4>
  <p class="text-muted small">Enter the 6-digit code from your authenticator app</p>
</div>

<form method="POST" action="/login/2fa">
  <input type="hidden" name="_csrf_token" value="{$csrf_token}">

  <div class="mb-4">
    <label class="form-label fw-semibold">Authentication Code</label>
    <input type="text" name="totp_code" class="form-control form-control-lg text-center font-monospace fs-4"
           maxlength="8" placeholder="000000" autocomplete="one-time-code" autofocus required>
    <div class="form-text text-center">Enter the code from Google Authenticator, Authy, or use a backup code.</div>
  </div>

  <button type="submit" class="btn btn-primary w-100 mb-3">
    <i class="fas fa-check me-2"></i>Verify
  </button>

  <div class="text-center text-muted small">
    <a href="/login" class="text-secondary">← Back to login</a>
  </div>
</form>
{/block}
