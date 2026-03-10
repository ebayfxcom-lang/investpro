{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="card">
  <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
    <h6 class="mb-0 fw-bold"><i class="fas fa-list-alt me-2 text-info"></i>Transactions</h6>
    <div class="d-flex gap-2">
      {foreach ['','deposit','withdrawal','earning','referral','admin_credit'] as $t}
      <a href="/admin/transactions{if $t}?type={$t}{/if}" class="btn btn-sm {if $type == $t}btn-primary{else}btn-outline-secondary{/if}">
        {if $t}{$t|ucfirst}{else}All{/if}
      </a>
      {/foreach}
    </div>
  </div>
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead class="table-light">
          <tr><th>#</th><th>User</th><th>Type</th><th>Amount</th><th>Currency</th><th>Description</th><th>Status</th><th>Date</th></tr>
        </thead>
        <tbody>
          {foreach $data.items as $t}
          <tr>
            <td class="text-muted small">{$t.id}</td>
            <td><a href="/admin/users/{$t.user_id}" class="text-primary">#U{$t.user_id}</a></td>
            <td><span class="badge bg-secondary bg-opacity-25 text-dark small">{$t.type|replace:'_':' '|ucfirst}</span></td>
            <td><strong>{if $t.type == 'withdrawal'}-{/if}${$t.amount|string_format:"%.2f"}</strong></td>
            <td>{$t.currency}</td>
            <td class="text-muted small">{$t.description|escape|truncate:50}</td>
            <td><span class="badge badge-status-{$t.status}">{$t.status|ucfirst}</span></td>
            <td class="small text-muted">{$t.created_at|date_format:'%b %d, %Y %H:%M'}</td>
          </tr>
          {foreachelse}
          <tr><td colspan="8" class="text-center text-muted py-4">No transactions found.</td></tr>
          {/foreach}
        </tbody>
      </table>
    </div>
  </div>
</div>
{/block}
