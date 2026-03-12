{extends file="layouts/user.tpl"}
{block name="content"}
<div class="row g-3 justify-content-center">
  <div class="col-lg-6">

    <!-- Change Password -->
    <div class="card">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-key me-2 text-danger"></i>Change Password</h6>
      </div>
      <div class="card-body">
        <form method="POST" action="/user/security">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">
          <input type="hidden" name="action" value="change_password">
          <div class="mb-3">
            <label class="form-label fw-semibold">Current Password <span class="text-danger">*</span></label>
            <input type="password" name="current_password" class="form-control" required>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">New Password <span class="text-danger">*</span></label>
            <input type="password" name="new_password" class="form-control" minlength="8" required>
            <div class="form-text">Minimum 8 characters.</div>
          </div>
          <div class="mb-4">
            <label class="form-label fw-semibold">Confirm New Password <span class="text-danger">*</span></label>
            <input type="password" name="confirm_password" class="form-control" required>
          </div>
          <button type="submit" class="btn btn-danger w-100">
            <i class="fas fa-key me-2"></i>Change Password
          </button>
        </form>
      </div>
    </div>

    <!-- Two-Factor Authentication -->
    <div class="card mt-3">
      <div class="card-header bg-white py-3 d-flex align-items-center justify-content-between">
        <h6 class="mb-0 fw-bold"><i class="fas fa-shield-halved me-2 text-primary"></i>Two-Factor Authentication (2FA)</h6>
        {if $user_2fa_enabled}
          <span class="badge bg-success">Enabled</span>
        {else}
          <span class="badge bg-secondary">Disabled</span>
        {/if}
      </div>
      <div class="card-body">

        {if $user_2fa_enabled}
          <!-- 2FA is ON: show disable form -->
          <div class="alert alert-success d-flex align-items-center mb-3">
            <i class="fas fa-check-circle me-2"></i>
            Two-factor authentication is active on your account.
          </div>
          <form method="POST" action="/user/security">
            <input type="hidden" name="_csrf_token" value="{$csrf_token}">
            <input type="hidden" name="action" value="disable_2fa">
            <div class="mb-3">
              <label class="form-label fw-semibold">Current Password</label>
              <input type="password" name="password" class="form-control" required>
            </div>
            <div class="mb-4">
              <label class="form-label fw-semibold">Authenticator Code</label>
              <input type="text" name="totp_code" class="form-control font-monospace" maxlength="8"
                     placeholder="6-digit code" autocomplete="one-time-code" required>
            </div>
            <button type="submit" class="btn btn-outline-danger w-100">
              <i class="fas fa-lock-open me-2"></i>Disable 2FA
            </button>
          </form>

        {elseif $totp_setup}
          <!-- 2FA setup in progress: show QR + confirm -->
          <p class="text-muted small mb-3">
            Scan the QR code with your authenticator app (e.g. Google Authenticator, Authy),
            then enter the 6-digit code below to confirm.
          </p>
          <div class="text-center mb-3">
            <img src="{$totp_qr_url}" alt="QR Code" class="img-fluid border rounded" style="max-width:200px">
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold small">Manual entry key</label>
            <div class="input-group">
              <input type="text" class="form-control form-control-sm font-monospace"
                     value="{$totp_secret}" readonly id="totpSecretField">
              <button class="btn btn-outline-secondary btn-sm" type="button"
                      onclick="navigator.clipboard.writeText(document.getElementById('totpSecretField').value)">
                <i class="fas fa-copy"></i>
              </button>
            </div>
          </div>
          <form method="POST" action="/user/security">
            <input type="hidden" name="_csrf_token" value="{$csrf_token}">
            <input type="hidden" name="action" value="confirm_2fa">
            <div class="mb-3">
              <label class="form-label fw-semibold">Authenticator Code <span class="text-danger">*</span></label>
              <input type="text" name="totp_code" class="form-control font-monospace text-center fs-5"
                     maxlength="8" placeholder="000000" autocomplete="one-time-code" required>
            </div>
            <button type="submit" class="btn btn-primary w-100">
              <i class="fas fa-check me-2"></i>Confirm &amp; Enable 2FA
            </button>
          </form>
          <form method="POST" action="/user/security" class="mt-2">
            <input type="hidden" name="_csrf_token" value="{$csrf_token}">
            <input type="hidden" name="action" value="cancel_2fa">
            <button type="submit" class="btn btn-link text-muted w-100 btn-sm">Cancel setup</button>
          </form>

          {if $backup_codes}
            <hr>
            <div class="alert alert-warning small">
              <strong><i class="fas fa-exclamation-triangle me-1"></i>Save your backup codes!</strong>
              These codes can be used if you lose access to your authenticator. Each code can only be used once.
            </div>
            <div class="row g-2 mb-2">
              {foreach $backup_codes as $code}
                <div class="col-6">
                  <code class="d-block text-center bg-light rounded px-2 py-1 font-monospace">{$code}</code>
                </div>
              {/foreach}
            </div>
          {/if}

        {else}
          <!-- 2FA not set up yet: start flow -->
          <p class="text-muted small mb-3">
            Add an extra layer of security with an authenticator app.
          </p>
          <form method="POST" action="/user/security">
            <input type="hidden" name="_csrf_token" value="{$csrf_token}">
            <input type="hidden" name="action" value="setup_2fa">
            <button type="submit" class="btn btn-primary w-100">
              <i class="fas fa-qrcode me-2"></i>Set Up Two-Factor Auth
            </button>
          </form>
        {/if}

      </div>
    </div>

    <!-- Security Tips -->
    <div class="card mt-3">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-info-circle me-2 text-info"></i>Security Tips</h6>
      </div>
      <div class="card-body">
        <ul class="list-unstyled mb-0">
          <li class="mb-2"><i class="fas fa-check-circle text-success me-2"></i>Use a unique, strong password (12+ characters)</li>
          <li class="mb-2"><i class="fas fa-check-circle text-success me-2"></i>Include uppercase, lowercase, numbers and symbols</li>
          <li class="mb-2"><i class="fas fa-check-circle text-success me-2"></i>Enable 2FA for maximum security</li>
          <li><i class="fas fa-check-circle text-success me-2"></i>Never share your password or 2FA codes</li>
        </ul>
      </div>
    </div>

  </div>
</div>
{/block}
