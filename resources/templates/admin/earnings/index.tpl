{extends file="layouts/admin.tpl"}
{block name="content"}

<div class="row g-3 mb-4">
  <div class="col-sm-6 col-xl-3">
    <div class="stat-card">
      <div class="d-flex justify-content-between align-items-start">
        <div>
          <div class="text-muted small mb-1">Total Paid Earnings</div>
          <div class="h4 fw-bold mb-0">${$stats.total|string_format:"%.2f"}</div>
        </div>
        <div class="stat-icon bg-success bg-opacity-10 text-success"><i class="fas fa-coins"></i></div>
      </div>
    </div>
  </div>
  <div class="col-sm-6 col-xl-3">
    <div class="stat-card">
      <div class="d-flex justify-content-between align-items-start">
        <div>
          <div class="text-muted small mb-1">Today's Earnings</div>
          <div class="h4 fw-bold mb-0">${$stats.today|string_format:"%.2f"}</div>
        </div>
        <div class="stat-icon bg-primary bg-opacity-10 text-primary"><i class="fas fa-calendar-day"></i></div>
      </div>
    </div>
  </div>
</div>

<div class="card">
  <div class="card-header bg-white py-3">
    <h6 class="mb-0 fw-bold"><i class="fas fa-coins me-2 text-success"></i>Earnings Ledger</h6>
  </div>
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead class="table-light">
          <tr>
            <th>#</th>
            <th>User</th>
            <th>Amount</th>
            <th>Currency</th>
            <th>Type</th>
            <th>Status</th>
            <th>Date</th>
          </tr>
        </thead>
        <tbody>
          {foreach $data.items as $e}
          <tr>
            <td class="text-muted small">{$e.id}</td>
            <td>
              {if $e.username}
                <a href="/admin/users/{$e.user_id}" class="fw-semibold text-decoration-none">{$e.username|escape}</a>
              {else}
                <span class="text-muted">#{$e.user_id}</span>
              {/if}
            </td>
            <td class="fw-semibold">${$e.amount|string_format:"%.2f"}</td>
            <td>
              <span class="badge bg-info bg-opacity-25 text-info font-monospace">
                {$e.deposit_currency|default:'USD'}
              </span>
            </td>
            <td><span class="badge bg-secondary bg-opacity-25 text-dark">{$e.type|default:'roi'|ucfirst}</span></td>
            <td><span class="badge badge-status-{$e.status}">{$e.status|ucfirst}</span></td>
            <td class="text-muted small">{$e.created_at|date_format:'%b %d, %Y %H:%M'}</td>
          </tr>
          {foreachelse}
          <tr><td colspan="7" class="text-center text-muted py-4">No earnings records found.</td></tr>
          {/foreach}
        </tbody>
      </table>
    </div>
  </div>
  {if $data.total_pages > 1}
  <div class="card-footer bg-white py-3 d-flex justify-content-between align-items-center">
    <div class="text-muted small">Showing {$data.items|@count} of {$data.total} records</div>
    <nav>
      <ul class="pagination pagination-sm mb-0">
        {section name=p loop=$data.total_pages start=1}
        <li class="page-item {if $smarty.section.p.index+1 == $data.page}active{/if}">
          <a class="page-link" href="?page={$smarty.section.p.index+1}">{$smarty.section.p.index+1}</a>
        </li>
        {/section}
      </ul>
    </nav>
  </div>
  {/if}
</div>

{/block}
