{extends file="layouts/user.tpl"}
{block name="content"}
<div class="card">
  <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
    <h6 class="mb-0 fw-bold"><i class="fas fa-clock-rotate-left me-2 text-secondary"></i>Withdrawal History</h6>
    <a href="/user/withdraw" class="btn btn-warning btn-sm text-dark"><i class="fas fa-plus me-1"></i>New Withdrawal</a>
  </div>
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead class="table-light">
          <tr><th>#</th><th>Amount</th><th>Currency</th><th>Method</th><th>Address</th><th>Status</th><th>Date</th></tr>
        </thead>
        <tbody>
          {foreach $withdrawals as $w}
          <tr>
            <td class="text-muted small">{$w.id}</td>
            <td><strong>${$w.amount|string_format:"%.2f"}</strong></td>
            <td>{$w.currency}</td>
            <td class="text-capitalize">{$w.method}</td>
            <td class="text-muted small">{$w.address|escape|truncate:30}</td>
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
