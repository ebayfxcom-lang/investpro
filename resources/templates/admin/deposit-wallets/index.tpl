{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="d-flex justify-content-between align-items-center mb-3">
  <h6 class="mb-0 fw-bold"><i class="fas fa-wallet me-2 text-primary"></i>System Deposit Wallets</h6>
  <a href="/admin/deposit-wallets/create" class="btn btn-accent btn-sm">
    <i class="fas fa-plus me-1"></i>Add Wallet
  </a>
</div>

<div class="card">
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead class="table-light">
          <tr>
            <th>#</th>
            <th>Coin</th>
            <th>Network</th>
            <th>Wallet Address</th>
            <th>Min Deposit</th>
            <th>Confirmations</th>
            <th>Status</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {foreach $wallets as $w}
          <tr>
            <td class="text-muted small">{$w.id}</td>
            <td><strong>{$w.currency_code|escape}</strong></td>
            <td>{if $w.network}{$w.network|escape}{else}<span class="text-muted">—</span>{/if}</td>
            <td class="font-monospace small text-truncate" style="max-width:220px;">{$w.wallet_address|escape}</td>
            <td>{if $w.min_deposit > 0}{$w.min_deposit|string_format:"%.8f"}{else}<span class="text-muted">—</span>{/if}</td>
            <td>{$w.confirmations}</td>
            <td>
              {if $w.status == 'active'}
                <span class="badge bg-success">Active</span>
              {else}
                <span class="badge bg-secondary">Inactive</span>
              {/if}
            </td>
            <td>
              <div class="d-flex gap-1">
                <a href="/admin/deposit-wallets/{$w.id}/edit" class="btn btn-sm btn-outline-primary py-0 px-2">Edit</a>
                <form method="POST" action="/admin/deposit-wallets/{$w.id}/delete" class="d-inline">
                  <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                  <button type="submit" class="btn btn-sm btn-outline-danger py-0 px-2" onclick="return confirm('Delete this wallet?')">Delete</button>
                </form>
              </div>
            </td>
          </tr>
          {foreachelse}
          <tr><td colspan="8" class="text-center text-muted py-4">No deposit wallets configured yet.</td></tr>
          {/foreach}
        </tbody>
      </table>
    </div>
  </div>
</div>
{/block}
