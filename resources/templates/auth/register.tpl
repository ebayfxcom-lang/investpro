{extends file="layouts/auth.tpl"}
{block name="content"}
<div class="text-center mb-4">
  <div style="width:56px;height:56px;background:rgba(240,185,11,.12);border:1px solid rgba(240,185,11,.25);border-radius:14px;display:inline-flex;align-items:center;justify-content:center;margin-bottom:1rem;">
    <i class="fas fa-user-plus" style="color:#f0b90b;font-size:1.4rem;"></i>
  </div>
  <h4 class="fw-bold mb-1">Create Account</h4>
  <p class="subtitle">Join thousands of investors worldwide</p>
</div>

<form method="POST" action="/register" novalidate>
  <input type="hidden" name="_csrf_token" value="{$csrf_token}">

  <div class="row g-3 mb-3">
    <div class="col-12">
      <label class="form-label">Username</label>
      <input type="text" name="username" class="form-control" placeholder="Choose a username" required autocomplete="username">
    </div>
    <div class="col-12">
      <label class="form-label">Email Address</label>
      <input type="email" name="email" class="form-control" placeholder="you@example.com" required autocomplete="email">
    </div>
    <div class="col-sm-6">
      <label class="form-label">Password</label>
      <input type="password" name="password" class="form-control" placeholder="Min. 8 characters" required minlength="8" autocomplete="new-password">
    </div>
    <div class="col-sm-6">
      <label class="form-label">Confirm Password</label>
      <input type="password" name="password_confirm" class="form-control" placeholder="Repeat password" required autocomplete="new-password">
    </div>
  </div>

  <div class="mb-3">
    <label class="form-label">WhatsApp Number <span style="color:#f87171;">*</span></label>
    <div class="input-group">
      <span class="input-group-text" style="background:var(--auth-input-bg);border-color:var(--auth-input-border);color:#25d366;">
        <i class="fab fa-whatsapp"></i>
      </span>
      <input type="tel" name="whatsapp_number" class="form-control" placeholder="+1 234 567 8900" required autocomplete="tel">
    </div>
    <div class="form-text">Used for account notifications and support.</div>
  </div>

  <div class="row g-3 mb-3">
    <div class="col-sm-6">
      <label class="form-label">Country</label>
      <select name="country" class="form-select">
        <option value="">Select country...</option>
        <option value="US">United States</option>
        <option value="GB">United Kingdom</option>
        <option value="CA">Canada</option>
        <option value="AU">Australia</option>
        <option value="DE">Germany</option>
        <option value="FR">France</option>
        <option value="NG">Nigeria</option>
        <option value="ZA">South Africa</option>
        <option value="GH">Ghana</option>
        <option value="KE">Kenya</option>
        <option value="IN">India</option>
        <option value="PK">Pakistan</option>
        <option value="BR">Brazil</option>
        <option value="MX">Mexico</option>
        <option value="Other">Other</option>
      </select>
    </div>
    <div class="col-sm-6">
      <label class="form-label">Preferred Currency</label>
      <select name="preferred_currency" class="form-select">
        <option value="USD">USD – US Dollar</option>
        <option value="EUR">EUR – Euro</option>
        <option value="BTC">BTC – Bitcoin</option>
        <option value="ETH">ETH – Ethereum</option>
        <option value="USDT">USDT – Tether</option>
      </select>
    </div>
  </div>

  <div class="mb-3">
    <label class="form-label">
      Facebook Profile
      <span style="color:#8b949e;font-size:.78rem;">(optional)</span>
    </label>
    <input type="url" name="facebook_url" class="form-control" placeholder="https://facebook.com/yourprofile" autocomplete="url">
  </div>

  {if $ref}
  <input type="hidden" name="ref" value="{$ref|escape}">
  <div class="alert alert-info d-flex align-items-center gap-2 mb-3" style="font-size:.875rem;padding:.65rem 1rem;">
    <i class="fas fa-user-plus"></i>
    <span>Referred by a member (code: <strong>{$ref|escape}</strong>)</span>
  </div>
  {/if}

  <button type="submit" class="btn btn-primary w-100 mb-3">
    <i class="fas fa-user-plus me-2"></i>Create My Account
  </button>

  <hr class="auth-divider">

  <div class="text-center" style="color:#8b949e;font-size:.875rem;">
    Already have an account?&nbsp;<a href="/login" class="fw-semibold">Sign in</a>
  </div>
</form>
{/block}
