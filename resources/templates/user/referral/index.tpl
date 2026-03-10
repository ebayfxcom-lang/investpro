{extends file="layouts/user.tpl"}
{block name="content"}
<div class="row g-3 mb-4">
  <div class="col-md-4">
    <div class="card text-center py-3 border-0 shadow-sm">
      <div class="card-body">
        <div class="text-muted small text-uppercase fw-semibold mb-2">Total Referrals</div>
        <div class="h3 fw-bold">{$stats.total_referrals}</div>
      </div>
    </div>
  </div>
  <div class="col-md-4">
    <div class="card text-center py-3 border-0 shadow-sm">
      <div class="card-body">
        <div class="text-muted small text-uppercase fw-semibold mb-2">Total Earned</div>
        <div class="h3 fw-bold text-success">${$stats.total_earnings|string_format:"%.2f"}</div>
      </div>
    </div>
  </div>
  <div class="col-md-4">
    <div class="card text-center py-3 border-0 shadow-sm">
      <div class="card-body">
        <div class="text-muted small text-uppercase fw-semibold mb-2">Pending</div>
        <div class="h3 fw-bold text-warning">${$stats.pending|string_format:"%.2f"}</div>
      </div>
    </div>
  </div>
</div>

<div class="card mb-4">
  <div class="card-header bg-white py-3">
    <h6 class="mb-0 fw-bold"><i class="fas fa-link me-2 text-warning"></i>Your Referral Link</h6>
  </div>
  <div class="card-body">
    <div class="input-group">
      <input type="text" class="form-control" id="refLink" value="{$ref_link|escape}" readonly>
      <button class="btn btn-primary" onclick="copyLink()"><i class="fas fa-copy me-1"></i>Copy</button>
    </div>
    <div class="mt-3 text-muted small">
      <i class="fas fa-info-circle me-1 text-info"></i>
      Share your link and earn a commission on every deposit made by your referrals!
    </div>
  </div>
</div>

<div class="row g-3">
  <div class="col-md-7">
    <div class="card">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-users me-2 text-primary"></i>Your Referrals</h6>
      </div>
      <div class="card-body p-0">
        <div class="table-responsive">
          <table class="table table-hover mb-0">
            <thead class="table-light">
              <tr><th>Username</th><th>Email</th><th>Status</th><th>Joined</th></tr>
            </thead>
            <tbody>
              {foreach $referrals as $r}
              <tr>
                <td><strong>{$r.username|escape}</strong></td>
                <td class="text-muted">{$r.email|escape}</td>
                <td><span class="badge badge-{$r.status}">{$r.status|ucfirst}</span></td>
                <td class="text-muted small">{$r.created_at|date_format:'%b %d, %Y'}</td>
              </tr>
              {foreachelse}
              <tr><td colspan="4" class="text-center text-muted py-4">No referrals yet. Share your link!</td></tr>
              {/foreach}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
  <div class="col-md-5">
    <div class="card">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-coins me-2 text-warning"></i>Referral Earnings</h6>
      </div>
      <div class="card-body p-0">
        <div class="table-responsive">
          <table class="table table-hover mb-0">
            <thead class="table-light">
              <tr><th>Amount</th><th>Level</th><th>Date</th></tr>
            </thead>
            <tbody>
              {foreach $earnings as $e}
              <tr>
                <td><strong class="text-success">+${$e.amount|string_format:"%.2f"}</strong></td>
                <td>Level {$e.level}</td>
                <td class="text-muted small">{$e.created_at|date_format:'%b %d'}</td>
              </tr>
              {foreachelse}
              <tr><td colspan="3" class="text-center text-muted py-4">No earnings yet</td></tr>
              {/foreach}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
function copyLink() {
  const el = document.getElementById('refLink');
  el.select();
  navigator.clipboard.writeText(el.value).then(() => {
    const btn = event.currentTarget;
    btn.innerHTML = '<i class="fas fa-check me-1"></i>Copied!';
    setTimeout(() => { btn.innerHTML = '<i class="fas fa-copy me-1"></i>Copy'; }, 2000);
  });
}
</script>
{/block}
