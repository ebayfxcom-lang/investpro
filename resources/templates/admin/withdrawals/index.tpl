{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="mb-3 d-flex gap-2">
  <a href="/admin/withdrawals" class="btn btn-sm {if !$status}btn-primary{else}btn-outline-primary{/if}">All</a>
  <a href="/admin/withdrawals?status=pending" class="btn btn-sm {if $status=='pending'}btn-warning{else}btn-outline-warning{/if}">Pending</a>
  <a href="/admin/withdrawals?status=approved" class="btn btn-sm {if $status=='approved'}btn-success{else}btn-outline-success{/if}">Approved</a>
</div>

<div class="card">
  <div class="card-header bg-white py-3">
    <h6 class="mb-0 fw-bold"><i class="fas fa-money-bill-transfer me-2 text-warning"></i>Withdrawals</h6>
  </div>
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead class="table-light">
          <tr><th>#</th><th>User</th><th>Amount</th><th>Currency</th><th>Method</th><th>Status</th><th>Date</th><th>Actions</th></tr>
        </thead>
        <tbody>
          {foreach $data.items as $w}
          <tr>
            <td class="text-muted small">{$w.id}</td>
            <td><a href="/admin/users/{$w.user_id}" class="text-primary">#U{$w.user_id}</a></td>
            <td><strong>${$w.amount|string_format:"%.2f"}</strong></td>
            <td>{$w.currency}</td>
            <td class="text-capitalize">{$w.method}</td>
            <td><span class="badge badge-status-{$w.status}">{$w.status|ucfirst}</span></td>
            <td class="small text-muted">{$w.created_at|date_format:'%b %d, %Y'}</td>
            <td>
              {if $w.status == 'pending'}
              <div class="d-flex gap-1">
                <form method="POST" action="/admin/withdrawals/{$w.id}/approve" class="d-inline">
                  <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                  <button type="submit" class="btn btn-sm btn-success py-0 px-2">Approve</button>
                </form>
                <form method="POST" action="/admin/withdrawals/{$w.id}/reject" class="d-inline">
                  <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                  <button type="submit" class="btn btn-sm btn-danger py-0 px-2" onclick="return confirm('Reject and refund?')">Reject</button>
                </form>
              </div>
              {else}-{/if}
            </td>
          </tr>
          {foreachelse}
          <tr><td colspan="8" class="text-center text-muted py-4">No withdrawals found.</td></tr>
          {/foreach}
        </tbody>
      </table>
    </div>
  </div>
</div>
{/block}
