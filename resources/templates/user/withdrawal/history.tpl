{extends file="layouts/user.tpl"}
{block name="content"}
<div class="card">
  <div class="card-header py-3 d-flex justify-content-between align-items-center">
    <h6 class="mb-0 fw-bold"><i class="fas fa-clock-rotate-left me-2 text-secondary"></i>Withdrawal History</h6>
    <a href="/user/withdraw" class="btn btn-warning btn-sm text-dark"><i class="fas fa-plus me-1"></i>New Withdrawal</a>
  </div>
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead>
          <tr><th>#</th><th>Amount</th><th>Method / Network</th><th>Address</th><th>TX Hash</th><th>Status</th><th>Date</th></tr>
        </thead>
        <tbody>
          {foreach $withdrawals as $w}
          <tr>
            <td class="text-muted small">{$w.id}</td>
            <td>
              <strong>{$w.amount|string_format:"%.8f"}</strong> {$w.currency}
              {if $w.fee > 0}<div class="text-muted" style="font-size:.75rem">Fee: {$w.fee|string_format:"%.8f"}</div>{/if}
            </td>
            <td class="small">
              {$w.method|escape}
              {if $w.network}<br><span class="badge bg-primary">{$w.network|escape}</span>{/if}
            </td>
            <td class="text-muted small font-monospace">{$w.address|escape|truncate:20:'...'}</td>
            <td class="small">
              {if $w.sent_tx_hash}
                <span class="font-monospace text-success" title="{$w.sent_tx_hash|escape}">
                  {$w.sent_tx_hash|escape|truncate:16:'...'}
                </span>
              {else}
                <span class="text-muted">-</span>
              {/if}
            </td>
            <td><span class="badge badge-{$w.status}">{$w.status|ucfirst}</span></td>
            <td class="text-muted small">{$w.created_at|date_format:'%b %d, %Y'}</td>
          </tr>
          {foreachelse}
          <tr><td colspan="7" class="text-center text-muted py-4">No withdrawal history yet</td></tr>
          {/foreach}
        </tbody>
      </table>
    </div>
  </div>
</div>
{/block}
