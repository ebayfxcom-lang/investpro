{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="row g-3">
  <div class="col-md-3">
    <div class="card">
      <div class="card-body p-0">
        <div class="list-group list-group-flush">
          <a href="/admin/settings" class="list-group-item list-group-item-action"><i class="fas fa-cog me-2"></i>General</a>
          <a href="/admin/settings/referral" class="list-group-item list-group-item-action"><i class="fas fa-percent me-2"></i>Referral</a>
          <a href="/admin/settings/currencies" class="list-group-item list-group-item-action"><i class="fas fa-dollar-sign me-2"></i>Currencies</a>
          <a href="/admin/settings/email-templates" class="list-group-item list-group-item-action active fw-semibold"><i class="fas fa-envelope me-2"></i>Email Templates</a>
          <a href="/admin/settings/security" class="list-group-item list-group-item-action"><i class="fas fa-shield me-2"></i>Security</a>
        </div>
      </div>
    </div>
  </div>
  <div class="col-md-9">
    <div class="card">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-envelope me-2 text-primary"></i>Email Templates</h6>
      </div>
      <div class="card-body">
        <div class="table-responsive">
          <table class="table table-hover mb-0">
            <thead class="table-light">
              <tr>
                <th>Slug</th>
                <th>Name</th>
                <th>Subject</th>
                <th>Status</th>
                <th>Updated</th>
              </tr>
            </thead>
            <tbody>
              {foreach $templates as $t}
              <tr>
                <td class="font-monospace small">{$t.slug|escape}</td>
                <td class="fw-semibold">{$t.name|escape}</td>
                <td class="text-muted small">{$t.subject|escape|truncate:60}</td>
                <td><span class="badge badge-status-{$t.status}">{$t.status|ucfirst}</span></td>
                <td class="text-muted small">{if $t.updated_at}{$t.updated_at|date_format:'%b %d, %Y'}{else}Never{/if}</td>
              </tr>
              {foreachelse}
              <tr><td colspan="5" class="text-center text-muted py-4">No email templates found.</td></tr>
              {/foreach}
            </tbody>
          </table>
        </div>
        <div class="mt-3 p-3 bg-light rounded small text-muted">
          <i class="fas fa-info-circle me-1"></i>
          Email templates can be seeded via the database migration scripts. Available variables are listed per template.
        </div>
      </div>
    </div>
  </div>
</div>
{/block}
