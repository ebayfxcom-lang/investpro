{extends file="layouts/auth.tpl"}
{block name="content"}
<h4 class="fw-bold mb-1">Create Account</h4>
<p class="text-muted small mb-4">Join thousands of investors worldwide</p>

<form method="POST" action="/register">
  <input type="hidden" name="_csrf_token" value="{$csrf_token}">

  <div class="mb-3">
    <label class="form-label fw-semibold">Username</label>
    <input type="text" name="username" class="form-control" placeholder="Choose a username" required>
  </div>

  <div class="mb-3">
    <label class="form-label fw-semibold">Email Address</label>
    <input type="email" name="email" class="form-control" placeholder="you@example.com" required>
  </div>

  <div class="mb-3">
    <label class="form-label fw-semibold">Password</label>
    <input type="password" name="password" class="form-control" placeholder="Min. 8 characters" required minlength="8">
  </div>

  <div class="mb-3">
    <label class="form-label fw-semibold">Confirm Password</label>
    <input type="password" name="password_confirm" class="form-control" placeholder="Repeat password" required>
  </div>

  <div class="mb-3">
    <label class="form-label fw-semibold">WhatsApp Number <span class="text-danger">*</span></label>
    <input type="tel" name="whatsapp_number" class="form-control" placeholder="+1 234 567 8900" required>
    <div class="form-text text-muted">We'll use this for account notifications.</div>
  </div>

  <div class="mb-3">
    <label class="form-label fw-semibold">Country</label>
    <select name="country" class="form-select">
      <option value="">Select your country...</option>
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

  <div class="mb-3">
    <label class="form-label fw-semibold">Preferred Currency</label>
    <select name="preferred_currency" class="form-select">
      <option value="USD">USD - US Dollar</option>
      <option value="EUR">EUR - Euro</option>
      <option value="BTC">BTC - Bitcoin</option>
      <option value="ETH">ETH - Ethereum</option>
      <option value="USDT">USDT - Tether</option>
    </select>
  </div>

  <div class="mb-3">
    <label class="form-label fw-semibold">Facebook Profile <span class="text-muted small">(optional)</span></label>
    <input type="url" name="facebook_url" class="form-control" placeholder="https://facebook.com/yourprofile">
  </div>

  {if $ref}
  <input type="hidden" name="ref" value="{$ref|escape}">
  <div class="alert alert-info small py-2">
    <i class="fas fa-user-plus me-1"></i> You were referred by a member (code: {$ref|escape})
  </div>
  {/if}

  <button type="submit" class="btn btn-primary w-100 mb-3">
    <i class="fas fa-user-plus me-2"></i>Create Account
  </button>

  <div class="text-center text-muted small">
    Already have an account? <a href="/login" class="text-primary fw-semibold">Sign in</a>
  </div>
</form>
{/block}
