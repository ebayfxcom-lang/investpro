{extends file="layouts/user.tpl"}
{block name="content"}
<div class="card">
  <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
    <h6 class="mb-0 fw-bold"><i class="fas fa-chart-line me-2 text-success"></i>Active Deposits</h6>
    <a href="/user/deposit" class="btn btn-primary btn-sm"><i class="fas fa-plus me-1"></i>New Deposit</a>
  </div>
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead class="table-light">
          <tr><th>#</th><th>Amount</th><th>Currency</th><th>Plan</th><th>Invested</th><th>Expires</th><th>Status</th></tr>
        </thead>
        <tbody>
          {foreach $deposits as $d}
          <tr>
            <td class="text-muted small">{$d.id}</td>
            <td><strong>${$d.amount|string_format:"%.2f"}</strong></td>
            <td>{$d.currency}</td>
            <td>Plan #{$d.plan_id}</td>
            <td class="text-muted small">{$d.created_at|date_format:'%b %d, %Y'}</td>
            <td class="small">
              {if $d.expires_at}
                {assign var="now" value=$smarty.now}
                {assign var="exp" value=$d.expires_at|strtotime}
                {assign var="daysLeft" value=($exp-$now)/86400}
                <span class="{if $daysLeft < 3}text-danger{elseif $daysLeft < 7}text-warning{else}text-muted{/if}">
                  {$d.expires_at|date_format:'%b %d, %Y'}
                </span>
              {else}-{/if}
            </td>
            <td><span class="badge badge-active">Active</span></td>
          </tr>
          {foreachelse}
          <tr>
            <td colspan="7" class="text-center py-5">
              <div class="text-muted mb-3"><i class="fas fa-chart-line fa-3x opacity-25"></i></div>
              <div class="text-muted mb-3">No active deposits yet</div>
              <a href="/user/deposit" class="btn btn-primary"><i class="fas fa-plus me-2"></i>Make Your First Deposit</a>
            </td>
          </tr>
          {/foreach}
        </tbody>
      </table>
    </div>
  </div>
</div>
{/block}
