{extends file="layouts/admin.tpl"}
{block name="content"}

<div class="d-flex justify-content-between align-items-center mb-3">
  <h6 class="fw-bold mb-0"><i class="fab fa-bitcoin me-2 text-warning"></i>Crypto Currencies</h6>
  <button class="btn btn-accent btn-sm" data-bs-toggle="modal" data-bs-target="#addCryptoModal">
    <i class="fas fa-plus me-1"></i>Add Crypto
  </button>
</div>

<div class="alert alert-info small mb-3">
  <i class="fas fa-info-circle me-1"></i>
  <strong>Crypto currencies</strong> are used for user deposits and withdrawals.
  Enable or disable each currency to control which ones are available to users.
  Rates are fetched from CoinGecko. Use <strong>Sync Prices</strong> to update rates.
</div>

<div class="card mb-3">
  <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
    <h6 class="mb-0 fw-bold">Active Crypto Currencies</h6>
    <form method="POST" action="/admin/crypto-currencies">
      <input type="hidden" name="_csrf_token" value="{$csrf_token}">
      <input type="hidden" name="action" value="sync">
      <button type="submit" class="btn btn-sm btn-outline-primary"
              onclick="return confirm('Sync prices from CoinGecko?')">
        <i class="fas fa-sync-alt me-1"></i>Sync Prices
      </button>
    </form>
  </div>
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead class="table-light">
          <tr>
            <th>Code</th>
            <th>Name</th>
            <th>Symbol</th>
            <th>Rate (to USD)</th>
            <th>Price (USD)</th>
            <th>Status</th>
            <th class="text-end">Actions</th>
          </tr>
        </thead>
        <tbody>
          {if $cryptos}
            {foreach $cryptos as $c}
            <tr>
              <td class="fw-semibold font-monospace">{$c.code|escape}</td>
              <td>{$c.name|escape}</td>
              <td class="text-muted">{$c.symbol|escape}</td>
              <td class="font-monospace small">{$c.rate_to_usd|string_format:'%.8f'}</td>
              <td class="font-monospace small">
                {if $c.rate_to_usd > 0}
                  ${(1 / $c.rate_to_usd)|string_format:'%.2f'}
                {else}—{/if}
              </td>
              <td>
                <span class="badge badge-status-{$c.status}">{$c.status|ucfirst}</span>
              </td>
              <td class="text-end">
                <form method="POST" action="/admin/crypto-currencies" class="d-inline">
                  <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                  <input type="hidden" name="action" value="toggle">
                  <input type="hidden" name="code" value="{$c.code|escape}">
                  <button type="submit" class="btn btn-sm {if $c.status == 'active'}btn-outline-warning{else}btn-outline-success{/if}">
                    {if $c.status == 'active'}<i class="fas fa-toggle-on"></i>{else}<i class="fas fa-toggle-off"></i>{/if}
                  </button>
                </form>
                <form method="POST" action="/admin/crypto-currencies" class="d-inline">
                  <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                  <input type="hidden" name="action" value="delete">
                  <input type="hidden" name="code" value="{$c.code|escape}">
                  <button type="submit" class="btn btn-sm btn-outline-danger"
                          onclick="return confirm('Delete {$c.code|escape:'js'}?')">
                    <i class="fas fa-trash"></i>
                  </button>
                </form>
              </td>
            </tr>
            {/foreach}
          {else}
            <tr><td colspan="7" class="text-center text-muted py-5">No crypto currencies found.</td></tr>
          {/if}
        </tbody>
      </table>
    </div>
  </div>
</div>

{* Add Crypto Modal *}
<div class="modal fade" id="addCryptoModal" tabindex="-1">
  <div class="modal-dialog">
    <form method="POST" action="/admin/crypto-currencies">
      <input type="hidden" name="_csrf_token" value="{$csrf_token}">
      <input type="hidden" name="action" value="add">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title fw-bold">Add Crypto Currency</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label class="form-label fw-semibold">Code <span class="text-danger">*</span></label>
            <input type="text" name="code" class="form-control text-uppercase" required
                   placeholder="e.g. BTC, ETH, SOL" maxlength="10">
            <div class="form-text">Ticker symbol (uppercase)</div>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Name <span class="text-danger">*</span></label>
            <input type="text" name="name" class="form-control" required placeholder="e.g. Bitcoin">
          </div>
          <div>
            <label class="form-label fw-semibold">Symbol</label>
            <input type="text" name="symbol" class="form-control" placeholder="e.g. ₿, Ξ" maxlength="10">
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
          <button type="submit" class="btn btn-accent"><i class="fas fa-plus me-1"></i>Add Currency</button>
        </div>
      </div>
    </form>
  </div>
</div>
{/block}
