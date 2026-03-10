{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="row g-3">
  <div class="col-md-3">
    <div class="card">
      <div class="card-body p-0">
        <div class="list-group list-group-flush">
          <a href="/admin/settings" class="list-group-item list-group-item-action"><i class="fas fa-cog me-2"></i>General</a>
          <a href="/admin/settings/referral" class="list-group-item list-group-item-action"><i class="fas fa-percent me-2"></i>Referral</a>
          <a href="/admin/settings/currencies" class="list-group-item list-group-item-action active fw-semibold"><i class="fas fa-dollar-sign me-2"></i>Currencies</a>
          <a href="/admin/settings/email-templates" class="list-group-item list-group-item-action"><i class="fas fa-envelope me-2"></i>Email Templates</a>
          <a href="/admin/settings/security" class="list-group-item list-group-item-action"><i class="fas fa-shield me-2"></i>Security</a>
        </div>
      </div>
    </div>
  </div>
  <div class="col-md-9">
    <div class="card">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-dollar-sign me-2 text-success"></i>Currencies</h6>
      </div>
      <div class="card-body">
        <div class="table-responsive">
          <table class="table table-hover mb-0">
            <thead class="table-light">
              <tr>
                <th>Code</th>
                <th>Name</th>
                <th>Symbol</th>
                <th>Type</th>
                <th>Rate (USD)</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              {foreach $currencies as $c}
              <tr>
                <td class="fw-semibold font-monospace">{$c.code|escape}</td>
                <td>{$c.name|escape}</td>
                <td>{$c.symbol|escape}</td>
                <td><span class="badge bg-secondary bg-opacity-25 text-dark">{$c.type|ucfirst}</span></td>
                <td class="font-monospace">{$c.rate_to_usd|string_format:"%.8f"}</td>
                <td><span class="badge badge-status-{$c.status}">{$c.status|ucfirst}</span></td>
              </tr>
              {foreachelse}
              <tr><td colspan="6" class="text-center text-muted py-4">No currencies configured.</td></tr>
              {/foreach}
            </tbody>
          </table>
        </div>
        <div class="mt-3 p-3 bg-light rounded small text-muted">
          <i class="fas fa-info-circle me-1"></i>
          Currency exchange rates are managed in the database. Use the migration scripts to add or update currencies.
        </div>
      </div>
    </div>
  </div>
</div>
{/block}
