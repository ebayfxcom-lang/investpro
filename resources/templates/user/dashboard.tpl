{extends file="layouts/user.tpl"}
{block name="content"}

{if isset($notices) && $notices}
<div class="mb-3" id="noticesContainer">
  {foreach $notices as $notice}
  <div class="alert alert-{$notice.notice_type} alert-dismissible fade show" id="notice-{$notice.id}">
    <strong>{$notice.title|escape}</strong>
    {if $notice.body} — {$notice.body|escape}{/if}
    <button type="button" class="btn-close" data-bs-dismiss="alert"
            onclick="markNoticeRead({$notice.id})"></button>
  </div>
  {/foreach}
</div>
<script>
function markNoticeRead(id) {
  fetch('/user/notices/read', {
    method: 'POST',
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: '_csrf_token=' + encodeURIComponent(document.querySelector('meta[name="csrf-token"]')?.content || '') + '&notice_id=' + id
  });
}
</script>
{/if}

<div class="row g-3 mb-4">
  {foreach $wallets as $wallet}
  <div class="col-sm-6 col-xl-3">
    <div class="card card-stat" style="border-left-color: {if $wallet.currency == 'USD'}#1e40af{elseif $wallet.currency == 'EUR'}#059669{elseif $wallet.currency == 'BTC'}#f59e0b{else}#7c3aed{/if}">
      <div class="card-body py-3">
        <div class="stat-label">{$wallet.currency} Balance</div>
        <div class="stat-value">{if $wallet.currency == 'BTC'}{$wallet.balance|string_format:"%.8f"}{else}${$wallet.balance|string_format:"%.2f"}{/if}</div>
      </div>
    </div>
  </div>
  {foreachelse}
  <div class="col-12">
    <div class="alert alert-info">
      <i class="fas fa-info-circle me-2"></i>No wallets yet. Make your first deposit to get started!
      <a href="/user/deposit" class="btn btn-primary btn-sm ms-3">Make Deposit</a>
    </div>
  </div>
  {/foreach}
</div>

<div class="row g-3 mb-4">
  <div class="col-md-4">
    <div class="card text-center py-3">
      <div class="card-body">
        <div class="text-muted small text-uppercase fw-semibold mb-2">Total Deposited</div>
        <div class="display-6 fw-bold text-primary">${$total_deposited|string_format:"%.2f"}</div>
      </div>
    </div>
  </div>
  <div class="col-md-4">
    <div class="card text-center py-3">
      <div class="card-body">
        <div class="text-muted small text-uppercase fw-semibold mb-2">Total Earnings</div>
        <div class="display-6 fw-bold text-success">${$total_earnings|string_format:"%.2f"}</div>
      </div>
    </div>
  </div>
  <div class="col-md-4">
    <div class="card text-center py-3">
      <div class="card-body">
        <div class="text-muted small text-uppercase fw-semibold mb-2">Referral Earnings</div>
        <div class="display-6 fw-bold text-warning">${$referral_stats.total_earnings|string_format:"%.2f"}</div>
      </div>
    </div>
  </div>
</div>

<div class="row g-3 mb-4">
  <div class="col-md-7">
    <div class="card h-100">
      <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
        <h6 class="mb-0 fw-bold"><i class="fas fa-chart-line me-2 text-primary"></i>Active Deposits</h6>
        <a href="/user/deposit" class="btn btn-primary btn-sm"><i class="fas fa-plus me-1"></i>New</a>
      </div>
      <div class="card-body p-0">
        <div class="table-responsive">
          <table class="table table-hover mb-0">
            <thead class="table-light">
              <tr><th>Amount</th><th>Plan</th><th>Currency</th><th>Expires</th><th>Status</th></tr>
            </thead>
            <tbody>
              {foreach $active_deposits as $d}
              <tr>
                <td><strong>${$d.amount|string_format:"%.2f"}</strong></td>
                <td>Plan #{$d.plan_id}</td>
                <td>{$d.currency}</td>
                <td class="small text-muted">{if $d.expires_at}{$d.expires_at|date_format:'%b %d, %Y'}{else}-{/if}</td>
                <td><span class="badge badge-active">Active</span></td>
              </tr>
              {foreachelse}
              <tr><td colspan="5" class="text-center text-muted py-4">
                No active deposits. <a href="/user/deposit">Make a deposit</a>
              </td></tr>
              {/foreach}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>

  <div class="col-md-5">
    <div class="card h-100">
      <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
        <h6 class="mb-0 fw-bold"><i class="fas fa-clock-rotate-left me-2 text-secondary"></i>Recent Transactions</h6>
        <a href="/user/earnings" class="btn btn-outline-secondary btn-sm">View All</a>
      </div>
      <div class="card-body p-0">
        {if $recent_trans}
        <div class="list-group list-group-flush">
          {foreach $recent_trans as $t}
          <div class="list-group-item py-2 px-3">
            <div class="d-flex justify-content-between align-items-center">
              <div>
                <div class="small fw-semibold">{$t.type|replace:'_':' '|ucfirst}</div>
                <div class="text-muted" style="font-size:.75rem;">{$t.created_at|date_format:'%b %d, %Y %H:%M'}</div>
              </div>
              <div class="text-end">
                <strong class="{if $t.type == 'withdrawal' || $t.type == 'deposit' && $t.amount < 0}text-danger{else}text-success{/if}">
                  {if $t.type == 'withdrawal'}-{else}+{/if}${$t.amount|string_format:"%.2f"}
                </strong>
                <div class="text-muted" style="font-size:.75rem;">{$t.currency}</div>
              </div>
            </div>
          </div>
          {/foreach}
        </div>
        {else}
        <div class="text-center text-muted py-4 small">No transactions yet</div>
        {/if}
      </div>
    </div>
  </div>
</div>

<div class="row g-3">
  <div class="col-12">
    <div class="card">
      <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
        <h6 class="mb-0 fw-bold"><i class="fas fa-share-nodes me-2 text-warning"></i>Referral Program</h6>
        <a href="/user/referrals" class="btn btn-outline-warning btn-sm">View Details</a>
      </div>
      <div class="card-body">
        <div class="row g-3 align-items-center">
          <div class="col-md-4">
            <div class="text-center">
              <div class="text-muted small">Total Referrals</div>
              <div class="h4 fw-bold text-warning">{$referral_stats.total_referrals}</div>
            </div>
          </div>
          <div class="col-md-4">
            <div class="text-center">
              <div class="text-muted small">Referral Earnings</div>
              <div class="h4 fw-bold text-success">${$referral_stats.total_earnings|string_format:"%.2f"}</div>
            </div>
          </div>
          <div class="col-md-4 text-center">
            <a href="/user/referrals" class="btn btn-warning">
              <i class="fas fa-share-alt me-2"></i>Get Referral Link
            </a>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

{/block}
