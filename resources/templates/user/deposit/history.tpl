{extends file="layouts/user.tpl"}
{block name="content"}
<div class="card">
  <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
    <h6 class="mb-0 fw-bold"><i class="fas fa-history me-2 text-secondary"></i>Deposit History</h6>
    <a href="/user/deposit" class="btn btn-primary btn-sm"><i class="fas fa-plus me-1"></i>New Deposit</a>
  </div>
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead class="table-light">
          <tr><th>#</th><th>Amount</th><th>Currency</th><th>Status</th><th>Created</th><th>Expires</th></tr>
        </thead>
        <tbody>
          {foreach $deposits as $d}
          <tr>
            <td class="text-muted small">{$d.id}</td>
            <td><strong>${$d.amount|string_format:"%.2f"}</strong></td>
            <td>{$d.currency}</td>
            <td><span class="badge badge-{$d.status}">{$d.status|ucfirst}</span></td>
            <td class="text-muted small">{$d.created_at|date_format:'%b %d, %Y'}</td>
            <td class="text-muted small">{if $d.expires_at}{$d.expires_at|date_format:'%b %d, %Y'}{else}-{/if}</td>
          </tr>
          {foreachelse}
          <tr><td colspan="6" class="text-center text-muted py-4">No deposit history yet</td></tr>
          {/foreach}
        </tbody>
      </table>
    </div>
  </div>
</div>
{/block}
