{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="card">
  <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
    <h6 class="mb-0 fw-bold"><i class="fas fa-clock me-2 text-danger"></i>Expiring Deposits (Next 7 Days)</h6>
    <a href="/admin/deposits" class="btn btn-sm btn-outline-secondary">All Deposits</a>
  </div>
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead class="table-light">
          <tr><th>#</th><th>User</th><th>Plan</th><th>Amount</th><th>Expires</th><th>Days Left</th></tr>
        </thead>
        <tbody>
          {foreach $deposits as $d}
          <tr>
            <td class="text-muted small">{$d.id}</td>
            <td>
              <a href="/admin/users/{$d.user_id}">{$d.username|escape}</a><br>
              <small class="text-muted">{$d.email|escape}</small>
            </td>
            <td>{$d.plan_name|escape}</td>
            <td><strong>${$d.amount|string_format:"%.2f"}</strong></td>
            <td>{$d.expires_at|date_format:'%b %d, %Y'}</td>
            <td>
              {assign var="daysLeft" value=($d.expires_at|strtotime - $smarty.now) / 86400}
              <span class="badge {if $daysLeft < 1}bg-danger{elseif $daysLeft < 3}bg-warning text-dark{else}bg-info{/if}">
                {if $daysLeft < 1}Today{else}{$daysLeft|ceil} days{/if}
              </span>
            </td>
          </tr>
          {foreachelse}
          <tr><td colspan="6" class="text-center text-muted py-4">No deposits expiring in the next 7 days</td></tr>
          {/foreach}
        </tbody>
      </table>
    </div>
  </div>
</div>
{/block}
