{extends file="layouts/user.tpl"}
{block name="content"}

<div class="row g-4 mb-4">
  {foreach $plans as $plan}
  <div class="col-md-6 col-lg-3">
    <div class="card h-100 border-0 shadow-sm plan-card" style="cursor:pointer;transition:transform .2s;" onclick="selectPlan({$plan.id}, {$plan.min_amount}, {$plan.max_amount}, '{$plan.currency}')">
      <div class="card-body text-center">
        <div class="fw-bold fs-5 mb-2">{$plan.name|escape}</div>
        <div class="display-6 text-primary fw-bold">{$plan.roi_percent}%</div>
        <div class="text-muted small mb-3">{$plan.roi_period|ucfirst}</div>
        <hr>
        <div class="row text-center small g-2">
          <div class="col-6">
            <div class="text-muted">Min</div>
            <strong>${$plan.min_amount|string_format:"%.2f"}</strong>
          </div>
          <div class="col-6">
            <div class="text-muted">Max</div>
            <strong>{if $plan.max_amount > 0}${$plan.max_amount|string_format:"%.2f"}{else}No limit{/if}</strong>
          </div>
          <div class="col-6">
            <div class="text-muted">Duration</div>
            <strong>{$plan.duration_days} days</strong>
          </div>
          <div class="col-6">
            <div class="text-muted">Principal</div>
            <strong>{if $plan.principal_return}Returned{else}Kept{/if}</strong>
          </div>
        </div>
        {if $plan.description}
        <div class="text-muted small mt-3">{$plan.description|escape}</div>
        {/if}
      </div>
    </div>
  </div>
  {/foreach}
</div>

<div class="row justify-content-center">
  <div class="col-lg-6">
    <div class="card">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-plus-circle me-2 text-primary"></i>Make a Deposit</h6>
      </div>
      <div class="card-body">
        <form method="POST" action="/user/deposit" id="depositForm">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">

          <div class="mb-3">
            <label class="form-label fw-semibold">Select Plan <span class="text-danger">*</span></label>
            <select name="plan_id" id="plan_id" class="form-select" required>
              <option value="">-- Choose a plan --</option>
              {foreach $plans as $plan}
              <option value="{$plan.id}" data-min="{$plan.min_amount}" data-max="{$plan.max_amount}" data-currency="{$plan.currency}">
                {$plan.name|escape} - {$plan.roi_percent}% {$plan.roi_period}
              </option>
              {/foreach}
            </select>
          </div>

          <div class="mb-3">
            <label class="form-label fw-semibold">Currency <span class="text-danger">*</span></label>
            <select name="currency" id="currency" class="form-select" required>
              <option value="USD">USD - US Dollar</option>
              <option value="EUR">EUR - Euro</option>
              <option value="BTC">BTC - Bitcoin</option>
              <option value="ETH">ETH - Ethereum</option>
              <option value="USDT">USDT - Tether</option>
            </select>
          </div>

          <div class="mb-3">
            <label class="form-label fw-semibold">Amount <span class="text-danger">*</span></label>
            <div class="input-group">
              <span class="input-group-text">$</span>
              <input type="number" name="amount" id="amount" class="form-control" step="0.01" min="10" placeholder="0.00" required>
            </div>
            <div class="form-text" id="amountHint">Select a plan to see limits</div>
          </div>

          <button type="submit" class="btn btn-primary w-100">
            <i class="fas fa-check-circle me-2"></i>Confirm Deposit
          </button>
        </form>
      </div>
    </div>
  </div>
</div>

<script>
function selectPlan(id, min, max, currency) {
  document.getElementById('plan_id').value = id;
  document.getElementById('amount').min = min;
  let hint = 'Min: $' + parseFloat(min).toFixed(2);
  if (max > 0) hint += ' | Max: $' + parseFloat(max).toFixed(2);
  document.getElementById('amountHint').textContent = hint;
  document.querySelectorAll('.plan-card').forEach(c => { c.style.transform = ''; c.classList.remove('border-primary'); });
  event.currentTarget.style.transform = 'translateY(-4px)';
  event.currentTarget.classList.add('border-primary');
}
document.getElementById('plan_id').addEventListener('change', function() {
  const sel = this.options[this.selectedIndex];
  if (sel.value) {
    const min = sel.dataset.min, max = sel.dataset.max;
    document.getElementById('amount').min = min;
    let hint = 'Min: $' + parseFloat(min).toFixed(2);
    if (max > 0) hint += ' | Max: $' + parseFloat(max).toFixed(2);
    document.getElementById('amountHint').textContent = hint;
  }
});
</script>
{/block}
