{extends file="layouts/admin.tpl"}
{block name="content"}

{* Stats row *}
<div class="row g-3 mb-4">
  <div class="col-sm-6 col-xl-3">
    <div class="stat-card">
      <div class="d-flex align-items-center justify-content-between">
        <div>
          <div class="text-muted small text-uppercase fw-semibold">Total Currencies</div>
          <div class="h3 fw-bold mt-1 mb-0">{$currencies|count}</div>
        </div>
        <div class="stat-icon bg-primary bg-opacity-10 text-primary"><i class="fas fa-coins"></i></div>
      </div>
    </div>
  </div>
  <div class="col-sm-6 col-xl-3">
    <div class="stat-card">
      <div class="d-flex align-items-center justify-content-between">
        <div>
          <div class="text-muted small text-uppercase fw-semibold">Active</div>
          <div class="h3 fw-bold mt-1 mb-0">
            {$currency_stats.active|default:0}
          </div>
        </div>
        <div class="stat-icon bg-success bg-opacity-10 text-success"><i class="fas fa-check-circle"></i></div>
      </div>
    </div>
  </div>
  <div class="col-sm-6 col-xl-3">
    <div class="stat-card">
      <div class="d-flex align-items-center justify-content-between">
        <div>
          <div class="text-muted small text-uppercase fw-semibold">Fiat</div>
          <div class="h3 fw-bold mt-1 mb-0" id="statFiat">{$currency_stats.fiat|default:0}</div>
        </div>
        <div class="stat-icon bg-info bg-opacity-10 text-info"><i class="fas fa-money-bill"></i></div>
      </div>
    </div>
  </div>
  <div class="col-sm-6 col-xl-3">
    <div class="stat-card">
      <div class="d-flex align-items-center justify-content-between">
        <div>
          <div class="text-muted small text-uppercase fw-semibold">Crypto</div>
          <div class="h3 fw-bold mt-1 mb-0" id="statCrypto">{$currency_stats.crypto|default:0}</div>
        </div>
        <div class="stat-icon bg-warning bg-opacity-10 text-warning"><i class="fab fa-bitcoin"></i></div>
      </div>
    </div>
  </div>
</div>

<div class="row g-3 mb-4">
  {* Add Currency *}
  <div class="col-lg-4">
    <div class="card h-100">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-plus-circle me-2 text-success"></i>Add Currency</h6>
      </div>
      <div class="card-body">
        <form method="POST" action="/admin/currencies">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">
          <input type="hidden" name="action" value="add">

          <div class="mb-3">
            <label for="currCode" class="form-label fw-semibold">Currency Code</label>
            <input type="text" class="form-control text-uppercase font-monospace"
                   id="currCode" name="code" required maxlength="10"
                   placeholder="e.g. BTC, EUR">
          </div>
          <div class="mb-3">
            <label for="currName" class="form-label fw-semibold">Name</label>
            <input type="text" class="form-control" id="currName" name="name"
                   required maxlength="100" placeholder="e.g. Bitcoin">
          </div>
          <div class="mb-3">
            <label for="currSymbol" class="form-label fw-semibold">Symbol</label>
            <input type="text" class="form-control" id="currSymbol" name="symbol"
                   required maxlength="10" placeholder="e.g. ₿, €">
          </div>
          <div class="mb-4">
            <label for="currType" class="form-label fw-semibold">Type</label>
            <select class="form-select" id="currType" name="type" required>
              <option value="">— Select type —</option>
              <option value="fiat">Fiat</option>
              <option value="crypto">Crypto</option>
            </select>
          </div>

          <button type="submit" class="btn btn-accent w-100">
            <i class="fas fa-plus me-2"></i>Add Currency
          </button>
        </form>
      </div>
    </div>
  </div>

  {* Currencies Table *}
  <div class="col-lg-8">
    <div class="card h-100">
      <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
        <h6 class="mb-0 fw-bold"><i class="fas fa-table me-2 text-primary"></i>Currencies</h6>
        <form method="POST" action="/admin/currencies" class="d-inline">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">
          <input type="hidden" name="action" value="sync">
          <button type="submit" class="btn btn-sm btn-outline-primary"
                  onclick="return confirm('Sync all exchange rates from external source?')">
            <i class="fas fa-sync-alt me-1"></i>Sync All Prices
          </button>
        </form>
      </div>
      <div class="card-body p-0">
        <div class="table-responsive">
          <table class="table table-hover mb-0" id="currenciesTable">
            <thead class="table-light">
              <tr>
                <th>Code</th>
                <th>Name</th>
                <th>Type</th>
                <th>Rate to USD</th>
                <th>Status</th>
                <th>Last Updated</th>
                <th class="text-end">Actions</th>
              </tr>
            </thead>
            <tbody>
              {if $currencies}
                {foreach $currencies as $c}
                <tr data-type="{$c.type}">
                  <td>
                    <span class="fw-semibold font-monospace">{$c.code|escape}</span>
                    {if $c.symbol}<small class="text-muted ms-1">{$c.symbol|escape}</small>{/if}
                  </td>
                  <td>{$c.name|escape}</td>
                  <td>
                    <span class="badge {if $c.type == 'crypto'}bg-warning bg-opacity-25 text-warning{else}bg-info bg-opacity-25 text-info{/if}">
                      {$c.type|ucfirst}
                    </span>
                  </td>
                  <td>
                    <form method="POST" action="/admin/currencies" class="d-flex gap-1 align-items-center">
                      <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                      <input type="hidden" name="action" value="update_rate">
                      <input type="hidden" name="code" value="{$c.code|escape}">
                      <input type="number" class="form-control form-control-sm font-monospace"
                             name="rate" value="{$c.rate_to_usd|string_format:'%.8f'}"
                             step="0.00000001" min="0" style="width:130px;">
                      <button type="submit" class="btn btn-sm btn-outline-success flex-shrink-0" title="Update Rate">
                        <i class="fas fa-check"></i>
                      </button>
                    </form>
                  </td>
                  <td>
                    <span class="badge badge-status-{$c.status}">{$c.status|ucfirst}</span>
                  </td>
                  <td class="text-muted small">
                    {if $c.updated_at}{$c.updated_at|date_format:'%b %d, %Y'}{else}—{/if}
                  </td>
                  <td class="text-end">
                    <form method="POST" action="/admin/currencies" class="d-inline">
                      <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                      <input type="hidden" name="action" value="delete">
                      <input type="hidden" name="code" value="{$c.code|escape}">
                      <button type="submit" class="btn btn-sm btn-outline-danger"
                              onclick="return confirm('Delete currency {$c.code|escape:'js'}?')"
                              title="Delete">
                        <i class="fas fa-trash"></i>
                      </button>
                    </form>
                  </td>
                </tr>
                {/foreach}
              {else}
                <tr><td colspan="7" class="text-center text-muted py-5">No currencies found.</td></tr>
              {/if}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>

{* Price History *}
<div class="card">
  <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
    <h6 class="mb-0 fw-bold"><i class="fas fa-chart-line me-2 text-info"></i>Latest Price History</h6>
    <a href="/admin/currencies/price-history" class="btn btn-sm btn-outline-info">View All</a>
  </div>
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead class="table-light">
          <tr>
            <th>Currency</th>
            <th>Price USD</th>
            <th>Price EUR</th>
            <th>Source</th>
            <th>Recorded At</th>
          </tr>
        </thead>
        <tbody>
          {if $price_history}
            {foreach $price_history as $ph}
            <tr>
              <td class="fw-semibold font-monospace">{$ph.currency_code|escape}</td>
              <td class="font-monospace">${$ph.price_usd|string_format:"%.8f"}</td>
              <td class="font-monospace">€{$ph.price_eur|string_format:"%.8f"}</td>
              <td><span class="badge bg-secondary bg-opacity-25 text-dark">{$ph.source|escape}</span></td>
              <td class="text-muted small">{$ph.recorded_at|date_format:'%b %d, %Y %H:%M'}</td>
            </tr>
            {/foreach}
          {else}
            <tr><td colspan="5" class="text-center text-muted py-4">No price history available.</td></tr>
          {/if}
        </tbody>
      </table>
    </div>
  </div>
</div>

<script>
(function () {
  const rows = document.querySelectorAll('#currenciesTable tbody tr[data-type]');
  let fiat = 0, crypto = 0;
  rows.forEach(r => {
    if (r.dataset.type === 'fiat')   fiat++;
    if (r.dataset.type === 'crypto') crypto++;
  });
  document.getElementById('statFiat').textContent   = fiat;
  document.getElementById('statCrypto').textContent = crypto;

  document.getElementById('currCode').addEventListener('input', function () {
    this.value = this.value.toUpperCase();
  });
}());
</script>

{/block}
