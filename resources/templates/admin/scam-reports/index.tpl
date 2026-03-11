{extends file="layouts/admin.tpl"}
{block name="content"}

{* Stats row *}
<div class="row g-3 mb-4">
  <div class="col-sm-3">
    <div class="stat-card">
      <div class="d-flex justify-content-between align-items-start">
        <div>
          <div class="text-muted small mb-1">Total Reports</div>
          <div class="h4 fw-bold mb-0">{$stats.total}</div>
        </div>
        <div class="stat-icon bg-danger bg-opacity-10 text-danger"><i class="fas fa-flag"></i></div>
      </div>
    </div>
  </div>
  <div class="col-sm-3">
    <div class="stat-card">
      <div class="d-flex justify-content-between align-items-start">
        <div>
          <div class="text-muted small mb-1">Pending</div>
          <div class="h4 fw-bold mb-0">{$stats.pending}</div>
        </div>
        <div class="stat-icon bg-warning bg-opacity-10 text-warning"><i class="fas fa-clock"></i></div>
      </div>
    </div>
  </div>
  <div class="col-sm-3">
    <div class="stat-card">
      <div class="d-flex justify-content-between align-items-start">
        <div>
          <div class="text-muted small mb-1">Confirmed</div>
          <div class="h4 fw-bold mb-0">{$stats.confirmed}</div>
        </div>
        <div class="stat-icon bg-danger bg-opacity-10 text-danger"><i class="fas fa-exclamation-triangle"></i></div>
      </div>
    </div>
  </div>
  <div class="col-sm-3">
    <div class="stat-card">
      <div class="d-flex justify-content-between align-items-start">
        <div>
          <div class="text-muted small mb-1">Dismissed</div>
          <div class="h4 fw-bold mb-0">{$stats.dismissed}</div>
        </div>
        <div class="stat-icon bg-secondary bg-opacity-10 text-secondary"><i class="fas fa-times-circle"></i></div>
      </div>
    </div>
  </div>
</div>

<div class="card">
  <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
    <h6 class="mb-0 fw-bold"><i class="fas fa-flag me-2 text-danger"></i>Scam Reports</h6>
    <div class="d-flex gap-2 flex-wrap">
      <a href="/admin/scam-reports" class="btn btn-sm {if !$current_status}btn-primary{else}btn-outline-secondary{/if}">All</a>
      <a href="/admin/scam-reports?status=pending" class="btn btn-sm {if $current_status == 'pending'}btn-warning{else}btn-outline-secondary{/if}">Pending</a>
      <a href="/admin/scam-reports?status=confirmed" class="btn btn-sm {if $current_status == 'confirmed'}btn-danger{else}btn-outline-secondary{/if}">Confirmed</a>
      <a href="/admin/scam-reports?status=dismissed" class="btn btn-sm {if $current_status == 'dismissed'}btn-secondary{else}btn-outline-secondary{/if}">Dismissed</a>
    </div>
  </div>
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead class="table-light">
          <tr>
            <th>#</th>
            <th>Website</th>
            <th>Reporter</th>
            <th>Status</th>
            <th>Reported</th>
            <th class="text-end">Actions</th>
          </tr>
        </thead>
        <tbody>
          {if $data.items}
            {foreach $data.items as $r}
            <tr>
              <td class="text-muted small">{$r.id}</td>
              <td>
                <div class="fw-semibold text-danger">
                  <i class="fas fa-globe me-1 opacity-50"></i>
                  {$r.website_url|escape|truncate:50:'...'}
                </div>
                <div class="text-muted small mt-1">{$r.description|escape|truncate:80:'...'}</div>
              </td>
              <td>
                {if $r.reporter_name}
                  <div class="fw-semibold">{$r.reporter_name|escape}</div>
                {/if}
                {if $r.reporter_email}
                  <div class="text-muted small">{$r.reporter_email|escape}</div>
                {/if}
                {if !$r.reporter_name && !$r.reporter_email}
                  <span class="text-muted">Anonymous</span>
                {/if}
              </td>
              <td>
                <span class="badge
                  {if $r.status == 'pending'}bg-warning bg-opacity-25 text-warning
                  {elseif $r.status == 'confirmed'}bg-danger bg-opacity-25 text-danger
                  {elseif $r.status == 'reviewed'}bg-info bg-opacity-25 text-info
                  {else}bg-secondary bg-opacity-25 text-muted{/if}">
                  {$r.status|ucfirst}
                </span>
              </td>
              <td class="text-muted small">{$r.created_at|date_format:'%b %d, %Y'}</td>
              <td class="text-end">
                <a href="/admin/scam-reports/{$r.id}" class="btn btn-sm btn-outline-primary">
                  <i class="fas fa-eye"></i>
                </a>
                {if $r.status == 'pending'}
                <form method="POST" action="/admin/scam-reports" class="d-inline">
                  <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                  <input type="hidden" name="action" value="confirmed">
                  <input type="hidden" name="report_id" value="{$r.id}">
                  <button type="submit" class="btn btn-sm btn-outline-danger" title="Confirm as scam"
                          onclick="return confirm('Mark as confirmed scam?')">
                    <i class="fas fa-check"></i>
                  </button>
                </form>
                <form method="POST" action="/admin/scam-reports" class="d-inline">
                  <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                  <input type="hidden" name="action" value="dismissed">
                  <input type="hidden" name="report_id" value="{$r.id}">
                  <button type="submit" class="btn btn-sm btn-outline-secondary" title="Dismiss"
                          onclick="return confirm('Dismiss this report?')">
                    <i class="fas fa-times"></i>
                  </button>
                </form>
                {/if}
              </td>
            </tr>
            {/foreach}
          {else}
            <tr><td colspan="6" class="text-center text-muted py-5">No scam reports found.</td></tr>
          {/if}
        </tbody>
      </table>
    </div>
  </div>
  {if $data.total_pages > 1}
  <div class="card-footer bg-white d-flex justify-content-between align-items-center py-3">
    <div class="text-muted small">Showing {$data.items|@count} of {$data.total} reports</div>
    <nav><ul class="pagination pagination-sm mb-0">
      {for $p = 1 to $data.total_pages}
      <li class="page-item {if $p == $data.page}active{/if}">
        <a class="page-link" href="?page={$p}{if $current_status}&status={$current_status}{/if}">{$p}</a>
      </li>
      {/for}
    </ul></nav>
  </div>
  {/if}
</div>
{/block}
