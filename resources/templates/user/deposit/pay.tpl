{extends file="layouts/user.tpl"}
{block name="content"}
<div class="row justify-content-center">
  <div class="col-lg-7">

    <!-- Deposit Summary -->
    <div class="card mb-3 border-0 shadow-sm">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-info-circle me-2 text-primary"></i>Deposit Summary</h6>
      </div>
      <div class="card-body">
        <div class="row g-2 small">
          <div class="col-6 text-muted">Plan</div>
          <div class="col-6 fw-semibold">{$plan.name|escape}</div>
          <div class="col-6 text-muted">Deposit Amount</div>
          <div class="col-6 fw-semibold">{$intent.amount|string_format:"%.2f"} {$plan.currency|escape|default:'USD'}</div>
          {if $crypto_amount}
          <div class="col-6 text-muted">Exact Crypto to Send</div>
          <div class="col-6 fw-bold text-primary fs-6">{$crypto_amount|string_format:"%.8f"} {$intent.currency|escape}</div>
          {/if}
          {if $intent.network}
          <div class="col-6 text-muted">Network</div>
          <div class="col-6"><span class="badge bg-primary">{$intent.network|escape}</span></div>
          {/if}
          <div class="col-6 text-muted">ROI</div>
          <div class="col-6 fw-semibold">{$plan.roi_percent}% {$plan.roi_period|ucfirst}</div>
          <div class="col-6 text-muted">Duration</div>
          <div class="col-6 fw-semibold">{$plan.duration_days} days</div>
        </div>
      </div>
    </div>

    {if $wallet_address}
    <!-- Wallet address + QR -->
    <div class="card mb-3 border-0 shadow-sm">
      <div class="card-header bg-white py-3 d-flex align-items-center justify-content-between">
        <h6 class="mb-0 fw-bold"><i class="fas fa-wallet me-2 text-success"></i>Send {$intent.currency|escape} to This Address</h6>
        {if $intent.network}<span class="badge bg-primary">{$intent.network|escape}</span>{/if}
      </div>
      <div class="card-body">
        <div class="row g-3 align-items-center">
          <!-- QR Code -->
          {if $qr_code_url}
          <div class="col-md-4 text-center">
            <img src="{$qr_code_url}" alt="Wallet QR Code" class="img-fluid border rounded p-1" style="max-width:160px">
            <div class="text-muted small mt-1">Scan to send</div>
          </div>
          {/if}
          <!-- Address details -->
          <div class="col-md-{if $qr_code_url}8{else}12{/if}">
            <label class="form-label fw-semibold small text-muted text-uppercase">Wallet Address</label>
            <div class="input-group mb-2">
              <input type="text" class="form-control form-control-sm font-monospace"
                     id="walletAddressField" value="{$wallet_address|escape}" readonly>
              <button class="btn btn-outline-secondary btn-sm" type="button" onclick="copyField('walletAddressField','Address')">
                <i class="fas fa-copy"></i>
              </button>
            </div>

            {if $crypto_amount}
            <label class="form-label fw-semibold small text-muted text-uppercase">Amount to Send</label>
            <div class="input-group mb-2">
              <input type="text" class="form-control form-control-sm font-monospace fw-bold"
                     id="cryptoAmountField" value="{$crypto_amount|string_format:'%.8f'}" readonly>
              <span class="input-group-text fw-semibold">{$intent.currency|escape}</span>
              <button class="btn btn-outline-secondary btn-sm" type="button" onclick="copyField('cryptoAmountField','Amount')">
                <i class="fas fa-copy"></i>
              </button>
            </div>
            <div class="alert alert-warning py-1 px-2 small mb-2">
              <i class="fas fa-exclamation-triangle me-1"></i>
              Send <strong>exactly {$crypto_amount|string_format:'%.8f'} {$intent.currency|escape}</strong>.
              Sending less may delay or prevent activation.
            </div>
            {/if}

            {if $memo}
            <div class="alert alert-danger py-2 px-3">
              <div class="fw-bold mb-1"><i class="fas fa-tag me-1"></i>Memo / Tag Required</div>
              <div class="input-group">
                <input type="text" class="form-control form-control-sm font-monospace" id="memoField" value="{$memo|escape}" readonly>
                <button class="btn btn-outline-danger btn-sm" type="button" onclick="copyField('memoField','Memo')">
                  <i class="fas fa-copy"></i>
                </button>
              </div>
              <div class="small mt-1 text-danger">⚠️ You MUST include this memo/tag or your funds may be lost!</div>
            </div>
            {/if}

            {if $system_wallet.confirmations > 0}
            <p class="text-muted small mb-0 mt-2">
              <i class="fas fa-clock me-1"></i>Requires {$system_wallet.confirmations|default:$intent.confirmations} network confirmation(s).
            </p>
            {/if}
          </div>
        </div>

        {if $system_wallet.instructions}
        <div class="alert alert-info py-2 text-start small mt-3">
          <i class="fas fa-info-circle me-1"></i>{$system_wallet.instructions|escape}
        </div>
        {/if}
      </div>
    </div>
    {else}
    <div class="alert alert-warning">
      <i class="fas fa-exclamation-triangle me-2"></i>No deposit wallet is currently configured for <strong>{$intent.currency|escape}</strong>.
      Please contact support or <a href="/user/deposit">choose a different coin</a>.
    </div>
    {/if}

    <!-- Submit tx hash -->
    <div class="card border-0 shadow-sm">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-check-circle me-2 text-primary"></i>Confirm Your Payment</h6>
      </div>
      <div class="card-body">
        <p class="text-muted small">
          After sending the crypto, enter your transaction hash below and click <strong>Submit</strong>.
          Your deposit will be activated once confirmed.
        </p>
        <form method="POST" action="/user/deposit/pay">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">
          <div class="mb-3">
            <label class="form-label fw-semibold">Transaction Hash / ID <span class="text-danger">*</span></label>
            <input type="text" name="tx_hash" class="form-control font-monospace"
                   maxlength="255" placeholder="Paste your transaction hash here" required>
            <div class="form-text">You can find this in your wallet's transaction history.</div>
          </div>
          <div class="d-flex gap-2">
            <button type="submit" class="btn btn-primary flex-grow-1">
              <i class="fas fa-paper-plane me-2"></i>Submit Deposit
            </button>
            <a href="/user/deposit" class="btn btn-outline-secondary">Back</a>
          </div>
        </form>
      </div>
    </div>

  </div>
</div>

<script>
function copyField(fieldId, label) {
  const field = document.getElementById(fieldId);
  if (!field) return;
  const val = field.value;
  if (navigator.clipboard) {
    navigator.clipboard.writeText(val)
      .then(() => showToast(label + ' copied!'))
      .catch(() => fallbackCopy(val, label));
  } else {
    fallbackCopy(val, label);
  }
}
function fallbackCopy(text, label) {
  const ta = document.createElement('textarea');
  ta.value = text;
  ta.style.position = 'fixed';
  ta.style.opacity = '0';
  document.body.appendChild(ta);
  ta.focus(); ta.select();
  try { document.execCommand('copy'); showToast(label + ' copied!'); } catch(e) { alert('Please copy manually.'); }
  document.body.removeChild(ta);
}
function showToast(msg) {
  const t = document.createElement('div');
  t.className = 'position-fixed bottom-0 end-0 m-3 alert alert-success py-2 px-3 small shadow';
  t.style.zIndex = '9999';
  t.textContent = msg;
  document.body.appendChild(t);
  setTimeout(() => t.remove(), 2500);
}
</script>
{/block}
