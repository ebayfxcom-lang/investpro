{extends file="layouts/user.tpl"}
{block name="content"}
<div class="row justify-content-center">
  <div class="col-lg-6">

    <div class="card mb-3 border-0 shadow-sm">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-info-circle me-2 text-primary"></i>Deposit Summary</h6>
      </div>
      <div class="card-body">
        <div class="row g-2 small">
          <div class="col-6 text-muted">Plan</div>
          <div class="col-6 fw-semibold">{$plan.name|escape}</div>
          <div class="col-6 text-muted">Amount</div>
          <div class="col-6 fw-semibold">{$intent.amount|string_format:"%.8f"} {$intent.currency|escape}</div>
          <div class="col-6 text-muted">ROI</div>
          <div class="col-6 fw-semibold">{$plan.roi_percent}% {$plan.roi_period|ucfirst}</div>
          <div class="col-6 text-muted">Duration</div>
          <div class="col-6 fw-semibold">{$plan.duration_days} days</div>
        </div>
      </div>
    </div>

    {if $system_wallet}
    <div class="card mb-3 border-0 shadow-sm">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-wallet me-2 text-success"></i>Send {$intent.currency|escape} to This Address</h6>
      </div>
      <div class="card-body text-center">
        {if $system_wallet.network}
        <div class="badge bg-primary mb-2">{$system_wallet.network|escape} Network</div>
        {/if}
        <div class="bg-light border rounded p-3 mb-3">
          <code class="fs-6 text-break" id="walletAddress">{$system_wallet.wallet_address|escape}</code>
        </div>
        <button type="button" class="btn btn-outline-secondary btn-sm mb-3" onclick="copyAddress()">
          <i class="fas fa-copy me-1"></i>Copy Address
        </button>
        {if $system_wallet.memo}
        <div class="alert alert-warning py-2 text-start small">
          <strong>Memo / Tag Required:</strong> {$system_wallet.memo|escape}
        </div>
        {/if}
        {if $system_wallet.instructions}
        <div class="alert alert-info py-2 text-start small">
          {$system_wallet.instructions|escape}
        </div>
        {/if}
        {if $system_wallet.confirmations > 0}
        <p class="text-muted small mb-0">
          <i class="fas fa-clock me-1"></i>Requires {$system_wallet.confirmations} network confirmation(s).
        </p>
        {/if}
      </div>
    </div>
    {else}
    <div class="alert alert-warning">
      <i class="fas fa-exclamation-triangle me-2"></i>No deposit wallet is currently configured for <strong>{$intent.currency|escape}</strong>.
      Please contact support or <a href="/user/deposit">choose a different coin</a>.
    </div>
    {/if}

    <div class="card border-0 shadow-sm">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-check-circle me-2 text-primary"></i>Confirm Your Payment</h6>
      </div>
      <div class="card-body">
        <p class="text-muted small">After sending the crypto, enter your transaction hash below and click <strong>Submit</strong>. An admin will verify and activate your deposit.</p>
        <form method="POST" action="/user/deposit/pay">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">
          <div class="mb-3">
            <label class="form-label fw-semibold">Transaction Hash / ID <span class="text-danger">*</span></label>
            <input type="text" name="tx_hash" class="form-control font-monospace" maxlength="255" placeholder="Paste your transaction hash here" required>
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
function copyAddress() {
  const addr = document.getElementById('walletAddress').textContent.trim();
  if (navigator.clipboard) {
    navigator.clipboard.writeText(addr).then(() => alert('Address copied!')).catch(() => alert('Could not copy. Please copy manually.'));
  } else {
    alert('Auto-copy not supported. Please copy the address manually.');
  }
}
</script>
{/block}
