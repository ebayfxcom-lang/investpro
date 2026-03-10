{extends file="layouts/user.tpl"}
{block name="content"}
<div class="row g-3 mb-4">
  <div class="col-md-4">
    <div class="card text-center py-3 border-0 shadow-sm">
      <div class="card-body">
        <div class="text-muted small text-uppercase fw-semibold mb-2">Total ROI Earnings</div>
        <div class="h3 fw-bold text-success">${$total_earnings|string_format:"%.2f"}</div>
      </div>
    </div>
  </div>
  <div class="col-md-4">
    <div class="card text-center py-3 border-0 shadow-sm">
      <div class="card-body">
        <div class="text-muted small text-uppercase fw-semibold mb-2">Referral Earnings</div>
        <div class="h3 fw-bold text-warning">${$referral_total|string_format:"%.2f"}</div>
      </div>
    </div>
  </div>
  <div class="col-md-4">
    <div class="card text-center py-3 border-0 shadow-sm">
      <div class="card-body">
        <div class="text-muted small text-uppercase fw-semibold mb-2">Combined Total</div>
        <div class="h3 fw-bold text-primary">${($total_earnings+$referral_total)|string_format:"%.2f"}</div>
      </div>
    </div>
  </div>
</div>

<div class="row g-3">
  <div class="col-md-7">
    <div class="card">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-coins me-2 text-success"></i>Investment Earnings</h6>
      </div>
      <div class="card-body p-0">
        <div class="table-responsive">
          <table class="table table-hover mb-0">
            <thead class="table-light">
              <tr><th>#</th><th>Amount</th><th>Type</th><th>Status</th><th>Date</th></tr>
            </thead>
            <tbody>
              {foreach $earnings as $e}
              <tr>
                <td class="text-muted small">{$e.id}</td>
                <td><strong class="text-success">+${$e.amount|string_format:"%.2f"}</strong></td>
                <td>{$e.type|ucfirst}</td>
                <td><span class="badge badge-{$e.status}">{$e.status|ucfirst}</span></td>
                <td class="text-muted small">{$e.created_at|date_format:'%b %d, %Y %H:%M'}</td>
              </tr>
              {foreachelse}
              <tr><td colspan="5" class="text-center text-muted py-4">No earnings yet</td></tr>
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
        <h6 class="mb-0 fw-bold"><i class="fas fa-share-nodes me-2 text-warning"></i>Referral Earnings</h6>
      </div>
      <div class="card-body p-0">
        <div class="table-responsive">
          <table class="table table-hover mb-0">
            <thead class="table-light">
              <tr><th>Amount</th><th>Level</th><th>Date</th></tr>
            </thead>
            <tbody>
              {foreach $referral_earnings as $r}
              <tr>
                <td><strong class="text-warning">+${$r.amount|string_format:"%.2f"}</strong></td>
                <td>Level {$r.level}</td>
                <td class="text-muted small">{$r.created_at|date_format:'%b %d'}</td>
              </tr>
              {foreachelse}
              <tr><td colspan="3" class="text-center text-muted py-4">No referral earnings yet</td></tr>
              {/foreach}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>
{/block}
