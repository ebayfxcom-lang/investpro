{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="mb-3 d-flex gap-2">
  <a href="/admin/deposits" class="btn btn-sm {if !$status}btn-primary{else}btn-outline-primary{/if}">All</a>
  <a href="/admin/deposits?status=pending" class="btn btn-sm {if $status=='pending'}btn-warning{else}btn-outline-warning{/if}">Pending</a>
  <a href="/admin/deposits?status=active" class="btn btn-sm {if $status=='active'}btn-success{else}btn-outline-success{/if}">Active</a>
  <a href="/admin/deposits?status=completed" class="btn btn-sm {if $status=='completed'}btn-info{else}btn-outline-info{/if}">Completed</a>
  <a href="/admin/deposits/expiring" class="btn btn-sm btn-outline-danger"><i class="fas fa-clock me-1"></i>Expiring</a>
</div>

<div class="card">
  <div class="card-header bg-white py-3">
    <h6 class="mb-0 fw-bold"><i class="fas fa-arrow-down-to-bracket me-2 text-success"></i>Deposits {if $status}- {$status|ucfirst}{/if}</h6>
  </div>
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead class="table-light">
          <tr><th>#</th><th>User</th><th>Plan</th><th>Amount</th><th>Currency</th><th>Status</th><th>Expires</th><th>Created</th><th>Actions</th></tr>
        </thead>
        <tbody>
          {foreach $data.items as $d}
          <tr>
            <td class="text-muted small">{$d.id}</td>
            <td><a href="/admin/users/{$d.user_id}" class="text-primary">{if $d.username}{$d.username|escape}{else}#{$d.user_id}{/if}</a></td>
            <td>{if $d.plan_name}{$d.plan_name|escape}{else}Plan #{$d.plan_id}{/if}</td>
            <td><strong>${$d.amount|string_format:"%.2f"}</strong></td>
            <td>{$d.currency}</td>
            <td><span class="badge badge-status-{$d.status}">{$d.status|ucfirst}</span></td>
            <td class="small text-muted">{if $d.expires_at}{$d.expires_at|date_format:'%b %d, %Y'}{else}-{/if}</td>
            <td class="small text-muted">{$d.created_at|date_format:'%b %d, %Y'}</td>
            <td>
              {if $d.status == 'pending'}
              <div class="d-flex gap-1">
                <form method="POST" action="/admin/deposits/{$d.id}/approve" class="d-inline">
                  <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                  <button type="submit" class="btn btn-xs btn-success btn-sm py-0 px-2">Approve</button>
                </form>
                <form method="POST" action="/admin/deposits/{$d.id}/reject" class="d-inline">
                  <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                  <button type="submit" class="btn btn-xs btn-danger btn-sm py-0 px-2" onclick="return confirm('Reject?')">Reject</button>
                </form>
              </div>
              {else}-{/if}
            </td>
          </tr>
          {foreachelse}
          <tr><td colspan="9" class="text-center text-muted py-4">No deposits found.</td></tr>
          {/foreach}
        </tbody>
      </table>
    </div>
  </div>
</div>
{/block}
