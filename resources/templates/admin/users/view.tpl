{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="row g-3">
  <div class="col-md-4">
    <div class="card">
      <div class="card-body text-center py-4">
        <div class="bg-primary bg-opacity-10 text-primary rounded-circle d-inline-flex align-items-center justify-content-center fw-bold mb-3" style="width:70px;height:70px;font-size:1.5rem;">
          {$user.username|upper|truncate:2:''}
        </div>
        <h5 class="fw-bold">{$user.username|escape}</h5>
        <div class="text-muted small">{$user.email|escape}</div>
        <div class="mt-2">
          <span class="badge badge-status-{$user.status}">{$user.status|ucfirst}</span>
          <span class="badge bg-secondary bg-opacity-25 text-dark ms-1">{$user.role|ucfirst}</span>
        </div>
        <div class="text-muted small mt-2">Joined {$user.created_at|date_format:'%b %d, %Y'}</div>
      </div>
      <div class="card-footer bg-white border-top py-3">
        <div class="d-flex gap-2 justify-content-center">
          <a href="/admin/users/{$user.id}/add-funds" class="btn btn-sm btn-accent">
            <i class="fas fa-plus me-1"></i>Add Funds
          </a>
          <form method="POST" action="/admin/users/{$user.id}/toggle-status">
            <input type="hidden" name="_csrf_token" value="{$csrf_token}">
            <button type="submit" class="btn btn-sm btn-outline-{if $user.status == 'active'}danger{else}success{/if}" onclick="return confirm('Change status?')">
              {if $user.status == 'active'}Ban User{else}Activate{/if}
            </button>
          </form>
        </div>
      </div>
    </div>

    <div class="card mt-3">
      <div class="card-header bg-white py-2">
        <h6 class="mb-0 fw-bold small">Wallet Balances</h6>
      </div>
      <div class="list-group list-group-flush">
        {foreach $wallets as $w}
        <div class="list-group-item d-flex justify-content-between py-2">
          <span class="fw-semibold">{$w.currency}</span>
          <strong>{if $w.currency == 'BTC'}{$w.balance|string_format:"%.8f"}{else}${$w.balance|string_format:"%.2f"}{/if}</strong>
        </div>
        {foreachelse}
        <div class="list-group-item text-muted small text-center py-3">No wallets</div>
        {/foreach}
      </div>
    </div>
  </div>

  <div class="col-md-8">
    <div class="card">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-list-alt me-2 text-primary"></i>Recent Transactions</h6>
      </div>
      <div class="card-body p-0">
        <div class="table-responsive">
          <table class="table table-sm table-hover mb-0">
            <thead class="table-light">
              <tr><th>Type</th><th>Amount</th><th>Description</th><th>Status</th><th>Date</th></tr>
            </thead>
            <tbody>
              {foreach $transactions as $t}
              <tr>
                <td><span class="badge bg-secondary bg-opacity-25 text-dark small">{$t.type|replace:'_':' '|ucfirst}</span></td>
                <td><strong>${$t.amount|string_format:"%.2f"}</strong> <small class="text-muted">{$t.currency}</small></td>
                <td class="text-muted small">{$t.description|escape|truncate:40}</td>
                <td><span class="badge badge-status-{$t.status}">{$t.status|ucfirst}</span></td>
                <td class="text-muted small">{$t.created_at|date_format:'%b %d, %Y'}</td>
              </tr>
              {foreachelse}
              <tr><td colspan="5" class="text-center text-muted py-3">No transactions</td></tr>
              {/foreach}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>
{/block}
