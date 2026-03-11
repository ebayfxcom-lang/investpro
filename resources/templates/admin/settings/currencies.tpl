{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="row g-3">
  <div class="col-md-3">
    <div class="card">
      <div class="card-body p-0">
        <div class="list-group list-group-flush">
          <a href="/admin/settings" class="list-group-item list-group-item-action"><i class="fas fa-cog me-2"></i>General</a>
          <a href="/admin/settings/referral" class="list-group-item list-group-item-action"><i class="fas fa-percent me-2"></i>Referral</a>
          <a href="/admin/settings/currencies" class="list-group-item list-group-item-action active fw-semibold"><i class="fas fa-dollar-sign me-2"></i>Fiat Currencies</a>
          <a href="/admin/settings/email-templates" class="list-group-item list-group-item-action"><i class="fas fa-envelope me-2"></i>Email Templates</a>
          <a href="/admin/settings/security" class="list-group-item list-group-item-action"><i class="fas fa-shield me-2"></i>Security</a>
        </div>
      </div>
    </div>
  </div>
  <div class="col-md-9">
    <div class="card">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-dollar-sign me-2 text-success"></i>Fiat / System Currencies</h6>
      </div>
      <div class="card-body pb-2">
        <div class="alert alert-info small mb-3">
          <i class="fas fa-info-circle me-1"></i>
          <strong>Fiat currencies</strong> are used for internal rate conversion, reports, and display only.
          The system accepts deposits and withdrawals exclusively in <strong>crypto currencies</strong>
          (managed separately at <a href="/admin/crypto-currencies">Crypto Currencies</a>).
          Enable or disable fiat currencies to include them in exchange rate calculations and reports.
        </div>
        <div class="table-responsive">
          <table class="table table-hover mb-0">
            <thead class="table-light">
              <tr>
                <th>Code</th>
                <th>Name</th>
                <th>Symbol</th>
                <th>Rate to USD</th>
                <th>Status</th>
                <th class="text-end">Toggle</th>
              </tr>
            </thead>
            <tbody>
              {foreach $currencies as $c}
              <tr>
                <td class="fw-semibold font-monospace">{$c.code|escape}</td>
                <td>{$c.name|escape}</td>
                <td class="text-muted">{$c.symbol|escape}</td>
                <td class="font-monospace small">{$c.rate_to_usd|string_format:"%.6f"}</td>
                <td>
                  <span class="badge badge-status-{$c.status}">{$c.status|ucfirst}</span>
                </td>
                <td class="text-end">
                  <form method="POST" action="/admin/settings/currencies">
                    <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                    <input type="hidden" name="action" value="toggle">
                    <input type="hidden" name="code" value="{$c.code|escape}">
                    <button type="submit"
                            class="btn btn-sm {if $c.status == 'active'}btn-outline-warning{else}btn-outline-success{/if}">
                      {if $c.status == 'active'}Disable{else}Enable{/if}
                    </button>
                  </form>
                </td>
              </tr>
              {foreachelse}
              <tr><td colspan="6" class="text-center text-muted py-4">No fiat currencies configured. Run migrations to seed them.</td></tr>
              {/foreach}
            </tbody>
          </table>
        </div>
        <div class="mt-3 text-muted small">
          <i class="fas fa-info-circle me-1"></i>
          Rates are updated via the
          <a href="/admin/exchange-rates">Exchange Rates</a> page. Sync rates regularly to keep them current.
        </div>
      </div>
    </div>
  </div>
</div>
{/block}

