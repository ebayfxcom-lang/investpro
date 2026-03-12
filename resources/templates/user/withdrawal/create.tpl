{extends file="layouts/user.tpl"}
{block name="content"}
<div class="row g-3 mb-4">
  {foreach $wallets as $w}
  <div class="col-sm-6 col-md-4">
    <div class="card text-center py-2">
      <div class="card-body">
        <div class="text-muted small text-uppercase">{$w.currency} Balance</div>
        <div class="h5 fw-bold text-primary mt-1">{if $w.currency == 'BTC'}{$w.balance|string_format:"%.8f"}{else}{$w.balance|string_format:"%.2f"}{/if}</div>
      </div>
    </div>
  </div>
  {/foreach}
</div>

<div class="row justify-content-center">
  <div class="col-lg-6">

    {if !$methods}
    <div class="alert alert-warning text-center">
      <i class="fas fa-exclamation-triangle me-2"></i>
      No withdrawal methods are currently available. Please contact support.
    </div>
    {else}
    <div class="card">
      <div class="card-header py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-money-bill-wave me-2 text-warning"></i>Withdraw Funds</h6>
      </div>
      <div class="card-body">
        <form method="POST" action="/user/withdraw" id="withdrawForm">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">

          <div class="mb-3">
            <label class="form-label fw-semibold">Withdrawal Method <span class="text-danger">*</span></label>
            <select name="method_id" id="methodSelect" class="form-select" required>
              <option value="">— Select method —</option>
              {foreach $methods as $m}
              <option value="{$m.id}"
                      data-currency="{$m.currency}"
                      data-network="{$m.network}"
                      data-min="{$m.min_amount}"
                      data-fee="{$m.fee}"
                      data-fee-pct="{$m.fee_percent}"
                      data-requires-memo="{$m.requires_memo}">
                {$m.name|escape}
                {if $m.network} ({$m.network|escape}){/if}
                — Min: {$m.min_amount|string_format:'%.2f'} {$m.currency|escape}
                {if $m.fee > 0}, Fee: {$m.fee|string_format:'%.4f'}{/if}
                {if $m.fee_percent > 0}+{$m.fee_percent}%{/if}
              </option>
              {/foreach}
            </select>
          </div>

          <!-- Method details (shown dynamically) -->
          <div id="methodDetails" class="alert alert-info py-2 small d-none">
            <span id="methodCurrency"></span>
            <span id="methodNetwork" class="badge bg-primary ms-1"></span>
            <span id="methodMinMsg" class="ms-2"></span>
            <span id="methodFeeMsg" class="ms-2"></span>
          </div>

          <div class="mb-3">
            <label class="form-label fw-semibold">Amount <span class="text-danger">*</span></label>
            <div class="input-group">
              <input type="number" name="amount" id="amountInput" class="form-control"
                     step="0.00000001" min="0" placeholder="0.00" required>
              <span class="input-group-text" id="currencyLabel">–</span>
            </div>
            <div id="netAmountMsg" class="form-text text-muted"></div>
          </div>

          <div class="mb-3">
            <label class="form-label fw-semibold">Wallet Address <span class="text-danger">*</span></label>
            <input type="text" name="address" id="addressInput" class="form-control font-monospace"
                   placeholder="Enter your wallet address" required>
            <div class="form-text text-danger fw-semibold">Double-check the address – transactions cannot be reversed.</div>
          </div>

          <div id="memoGroup" class="mb-3 d-none">
            <label class="form-label fw-semibold text-danger">Memo / Tag <span class="text-danger">*</span></label>
            <input type="text" name="memo" id="memoInput" class="form-control font-monospace"
                   placeholder="Required for this network">
            <div class="form-text text-danger">⚠️ Memo/tag is required for this withdrawal method.</div>
          </div>

          <button type="submit" class="btn btn-warning w-100 text-dark fw-bold">
            <i class="fas fa-paper-plane me-2"></i>Submit Withdrawal Request
          </button>
        </form>
      </div>
    </div>
    {/if}

  </div>
</div>

<script>
const methodSelect = document.getElementById('methodSelect');
const methodDetails = document.getElementById('methodDetails');
const methodCurrency = document.getElementById('methodCurrency');
const methodNetwork = document.getElementById('methodNetwork');
const methodMinMsg = document.getElementById('methodMinMsg');
const methodFeeMsg = document.getElementById('methodFeeMsg');
const currencyLabel = document.getElementById('currencyLabel');
const amountInput = document.getElementById('amountInput');
const netAmountMsg = document.getElementById('netAmountMsg');
const memoGroup = document.getElementById('memoGroup');

methodSelect?.addEventListener('change', function() {
  const opt = this.options[this.selectedIndex];
  if (!opt.value) {
    methodDetails.classList.add('d-none');
    memoGroup.classList.add('d-none');
    currencyLabel.textContent = '–';
    return;
  }
  const currency = opt.dataset.currency;
  const network = opt.dataset.network;
  const min = parseFloat(opt.dataset.min || 0);
  const fee = parseFloat(opt.dataset.fee || 0);
  const feePct = parseFloat(opt.dataset.feePct || 0);
  const requiresMemo = opt.dataset.requiresMemo === '1';

  currencyLabel.textContent = currency;
  methodCurrency.textContent = currency;
  methodNetwork.textContent = network || '';
  methodNetwork.style.display = network ? 'inline' : 'none';
  methodMinMsg.textContent = 'Min: ' + min.toFixed(2) + ' ' + currency;
  methodFeeMsg.textContent = fee > 0 ? ('Fee: ' + fee + (feePct > 0 ? ' + ' + feePct + '%' : '')) : '';
  amountInput.min = min;
  methodDetails.classList.remove('d-none');
  memoGroup.classList.toggle('d-none', !requiresMemo);
  document.getElementById('memoInput').required = requiresMemo;
  updateNetAmount();
});

amountInput?.addEventListener('input', updateNetAmount);

function updateNetAmount() {
  const opt = methodSelect?.options[methodSelect.selectedIndex];
  if (!opt?.value) return;
  const amount = parseFloat(amountInput.value || 0);
  const fee = parseFloat(opt.dataset.fee || 0);
  const feePct = parseFloat(opt.dataset.feePct || 0);
  const feeTotal = fee + (amount * feePct / 100);
  const net = Math.max(0, amount - feeTotal).toFixed(8);
  const currency = opt.dataset.currency;
  if (amount > 0) {
    netAmountMsg.textContent = 'You receive: ~' + net + ' ' + currency + ' (fee: ' + feeTotal.toFixed(8) + ')';
  } else {
    netAmountMsg.textContent = '';
  }
}
</script>
{/block}
