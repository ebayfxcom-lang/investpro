{extends file="layouts/admin.tpl"}
{block name="content"}

<div class="row g-3">
  {* Current Rates Table *}
  <div class="col-lg-8">
    <div class="card">
      <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
        <h6 class="mb-0 fw-bold"><i class="fas fa-exchange-alt me-2 text-primary"></i>Current Exchange Rates (vs USD)</h6>
        <form method="POST" action="/admin/exchange-rates" class="d-inline">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">
          <input type="hidden" name="action" value="sync">
          <button type="submit" class="btn btn-sm btn-outline-primary"
                  onclick="return confirm('Fetch latest rates from exchange rate service?')">
            <i class="fas fa-sync-alt me-1"></i>Sync Rates
          </button>
        </form>
      </div>
      <div class="card-body p-0">
        <div class="table-responsive">
          <table class="table table-hover mb-0">
            <thead class="table-light">
              <tr>
                <th>Currency</th>
                <th>Name</th>
                <th>Type</th>
                <th>Rate (1 USD =)</th>
                <th class="text-end">Inverse (1 unit in USD)</th>
              </tr>
            </thead>
            <tbody>
              {if $rates}
                {foreach $rates as $code => $rate}
                  {* Look up currency details *}
                  {assign var="currencyDetails" value=null}
                  {foreach $currencies as $c}
                    {if $c.code == $code}{assign var="currencyDetails" value=$c}{/if}
                  {/foreach}
                  <tr>
                    <td>
                      <span class="fw-semibold font-monospace">{$code|escape}</span>
                      {if $currencyDetails && $currencyDetails.symbol}
                        <small class="text-muted ms-1">{$currencyDetails.symbol|escape}</small>
                      {/if}
                    </td>
                    <td class="text-muted">
                      {if $currencyDetails}{$currencyDetails.name|escape}{else}—{/if}
                    </td>
                    <td>
                      {if $currencyDetails}
                        <span class="badge {if $currencyDetails.type == 'crypto'}bg-warning bg-opacity-25 text-warning{else}bg-info bg-opacity-25 text-info{/if}">
                          {$currencyDetails.type|ucfirst}
                        </span>
                      {else}
                        <span class="badge bg-secondary bg-opacity-25 text-dark">—</span>
                      {/if}
                    </td>
                    <td class="font-monospace">
                      {if $code == 'USD'}
                        <span class="text-muted">1.00000000</span>
                      {else}
                        {$rate|string_format:"%.8f"}
                      {/if}
                    </td>
                    <td class="text-end font-monospace text-muted">
                      {if $rate > 0}
                        ${(1 / $rate)|string_format:"%.8f"}
                      {else}
                        —
                      {/if}
                    </td>
                  </tr>
                {/foreach}
              {else}
                <tr>
                  <td colspan="5" class="text-center text-muted py-5">
                    <i class="fas fa-exchange-alt fa-2x mb-2 d-block opacity-25"></i>
                    No exchange rates available. Add currencies or sync rates.
                  </td>
                </tr>
              {/if}
            </tbody>
          </table>
        </div>
      </div>
      {if $rates}
      <div class="card-footer bg-white py-2 text-muted small">
        <i class="fas fa-info-circle me-1"></i>
        {$rates|count} rate{if $rates|count != 1}s{/if} loaded.
        Rates represent how many units of each currency equal 1 USD.
      </div>
      {/if}
    </div>
  </div>

  {* Manual Rate Update *}
  <div class="col-lg-4">
    <div class="card">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-pen-to-square me-2 text-warning"></i>Manually Update Rate</h6>
      </div>
      <div class="card-body">
        <form method="POST" action="/admin/exchange-rates">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">
          <input type="hidden" name="action" value="update">

          <div class="mb-3">
            <label for="rateCurrency" class="form-label fw-semibold">Currency</label>
            <select class="form-select" id="rateCurrency" name="code" required>
              <option value="">— Select currency —</option>
              {foreach $currencies as $c}
                <option value="{$c.code|escape}">{$c.code|escape} — {$c.name|escape}</option>
              {/foreach}
            </select>
          </div>

          <div class="mb-4">
            <label for="rateValue" class="form-label fw-semibold">Rate (1 USD =)</label>
            <div class="input-group">
              <span class="input-group-text font-monospace">1 USD =</span>
              <input type="number" class="form-control font-monospace"
                     id="rateValue" name="rate"
                     step="0.00000001" min="0" required
                     placeholder="e.g. 0.92000000">
              <span class="input-group-text" id="rateUnitLabel">units</span>
            </div>
            <div class="form-text">
              Enter how many units of the selected currency equal 1 USD.
            </div>
          </div>

          <button type="submit" class="btn btn-accent w-100">
            <i class="fas fa-save me-2"></i>Update Rate
          </button>
        </form>
      </div>
    </div>

    <div class="card mt-3">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-circle-info me-2 text-info"></i>About Exchange Rates</h6>
      </div>
      <div class="card-body small text-muted">
        <p class="mb-2">
          Exchange rates determine how deposits and withdrawals in non-USD currencies are converted.
        </p>
        <p class="mb-2">
          <strong>Rate format:</strong> How many units of a currency equal 1 USD.<br>
          <em>Example: EUR rate of <code>0.92</code> means 1 USD = 0.92 EUR.</em>
        </p>
        <p class="mb-0">
          Use <strong>Sync Rates</strong> to automatically fetch the latest rates from the configured exchange rate provider.
        </p>
      </div>
    </div>
  </div>
</div>

<script>
(function () {
  const sel   = document.getElementById('rateCurrency');
  const label = document.getElementById('rateUnitLabel');
  sel.addEventListener('change', function () {
    label.textContent = this.value || 'units';
  });
}());
</script>

{/block}
