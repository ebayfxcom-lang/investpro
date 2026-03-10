{extends file="layouts/user.tpl"}
{block name="content"}
<div class="row g-3 mb-4">
  {foreach $wallets as $w}
  <div class="col-sm-6 col-md-4">
    <div class="card border-0 shadow-sm text-center py-2">
      <div class="card-body">
        <div class="text-muted small text-uppercase">{$w.currency} Balance</div>
        <div class="h5 fw-bold text-primary mt-1">{if $w.currency == 'BTC'}{$w.balance|string_format:"%.8f"}{else}${$w.balance|string_format:"%.2f"}{/if}</div>
      </div>
    </div>
  </div>
  {/foreach}
</div>

<div class="row justify-content-center">
  <div class="col-lg-6">
    <div class="card">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-money-bill-wave me-2 text-warning"></i>Withdraw Funds</h6>
      </div>
      <div class="card-body">
        <form method="POST" action="/user/withdraw">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">

          <div class="mb-3">
            <label class="form-label fw-semibold">Currency <span class="text-danger">*</span></label>
            <select name="currency" class="form-select" required>
              {foreach $wallets as $w}
              <option value="{$w.currency}">{$w.currency} (Balance: {if $w.currency == 'BTC'}{$w.balance|string_format:"%.8f"}{else}${$w.balance|string_format:"%.2f"}{/if})</option>
              {/foreach}
            </select>
          </div>

          <div class="mb-3">
            <label class="form-label fw-semibold">Withdrawal Method <span class="text-danger">*</span></label>
            <select name="method" class="form-select" required>
              <option value="bank">Bank Transfer</option>
              <option value="paypal">PayPal</option>
              <option value="bitcoin">Bitcoin</option>
              <option value="ethereum">Ethereum</option>
              <option value="usdt">USDT (TRC20)</option>
            </select>
          </div>

          <div class="mb-3">
            <label class="form-label fw-semibold">Amount <span class="text-danger">*</span></label>
            <div class="input-group">
              <span class="input-group-text">$</span>
              <input type="number" name="amount" class="form-control" step="0.01" min="10" placeholder="0.00" required>
            </div>
          </div>

          <div class="mb-4">
            <label class="form-label fw-semibold">Wallet Address / Account Number <span class="text-danger">*</span></label>
            <input type="text" name="address" class="form-control" placeholder="Enter your wallet address or account number" required>
            <div class="form-text">Double-check the address. Transactions cannot be reversed.</div>
          </div>

          <button type="submit" class="btn btn-warning w-100 text-dark fw-bold">
            <i class="fas fa-paper-plane me-2"></i>Submit Withdrawal Request
          </button>
        </form>
      </div>
    </div>
  </div>
</div>
{/block}
