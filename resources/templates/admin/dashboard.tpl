{extends file="layouts/admin.tpl"}
{block name="content"}

<div class="row g-3 mb-4">
  <div class="col-sm-6 col-xl-3">
    <div class="stat-card">
      <div class="d-flex align-items-center justify-content-between">
        <div>
          <div class="text-muted small text-uppercase fw-semibold">Total Users</div>
          <div class="h3 fw-bold mt-1 mb-0">{$stats.users.total|default:0}</div>
          <div class="small text-success mt-1"><i class="fas fa-user-plus me-1"></i>{$stats.users.new_today|default:0} today</div>
        </div>
        <div class="stat-icon bg-primary bg-opacity-10 text-primary"><i class="fas fa-users"></i></div>
      </div>
    </div>
  </div>
  <div class="col-sm-6 col-xl-3">
    <div class="stat-card">
      <div class="d-flex align-items-center justify-content-between">
        <div>
          <div class="text-muted small text-uppercase fw-semibold">Active Deposits</div>
          <div class="h3 fw-bold mt-1 mb-0">{$stats.deposits.active|default:0}</div>
          <div class="small text-info mt-1"><i class="fas fa-dollar-sign me-1"></i>${$stats.deposits.active_amount|string_format:"%.2f"|default:'0.00'}</div>
        </div>
        <div class="stat-icon bg-success bg-opacity-10 text-success"><i class="fas fa-arrow-trend-up"></i></div>
      </div>
    </div>
  </div>
  <div class="col-sm-6 col-xl-3">
    <div class="stat-card">
      <div class="d-flex align-items-center justify-content-between">
        <div>
          <div class="text-muted small text-uppercase fw-semibold">Pending Withdrawals</div>
          <div class="h3 fw-bold mt-1 mb-0">{$stats.withdrawals.pending|default:0}</div>
          <div class="small text-warning mt-1"><i class="fas fa-clock me-1"></i>${$stats.withdrawals.pending_amount|string_format:"%.2f"|default:'0.00'}</div>
        </div>
        <div class="stat-icon bg-warning bg-opacity-10 text-warning"><i class="fas fa-money-bill-transfer"></i></div>
      </div>
    </div>
  </div>
  <div class="col-sm-6 col-xl-3">
    <div class="stat-card">
      <div class="d-flex align-items-center justify-content-between">
        <div>
          <div class="text-muted small text-uppercase fw-semibold">Total Transactions</div>
          <div class="h3 fw-bold mt-1 mb-0">{$stats.transactions.total|default:0}</div>
          <div class="small text-primary mt-1"><i class="fas fa-chart-bar me-1"></i>{$stats.transactions.today|default:0} today</div>
        </div>
        <div class="stat-icon bg-info bg-opacity-10 text-info"><i class="fas fa-list-alt"></i></div>
      </div>
    </div>
  </div>
</div>

<div class="row g-3 mb-4">
  <div class="col-md-8">
    <div class="card h-100">
      <div class="card-header bg-white border-bottom py-3 d-flex justify-content-between align-items-center">
        <h6 class="mb-0 fw-bold"><i class="fas fa-users me-2 text-primary"></i>Recent Users</h6>
        <a href="/admin/users" class="btn btn-sm btn-outline-primary">View All</a>
      </div>
      <div class="card-body p-0">
        <div class="table-responsive">
          <table class="table table-hover mb-0">
            <thead class="table-light">
              <tr>
                <th>User</th>
                <th>Email</th>
                <th>Status</th>
                <th>Joined</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {if $recent_users}
                {foreach $recent_users as $u}
                <tr>
                  <td>
                    <div class="d-flex align-items-center gap-2">
                      <div class="bg-primary bg-opacity-10 text-primary rounded-circle d-flex align-items-center justify-content-center" style="width:32px;height:32px;font-size:.8rem;font-weight:700;">
                        {$u.username|upper|truncate:1:''}
                      </div>
                      <strong>{$u.username|escape}</strong>
                    </div>
                  </td>
                  <td class="text-muted">{$u.email|escape}</td>
                  <td><span class="badge badge-status-{$u.status}">{$u.status|ucfirst}</span></td>
                  <td class="text-muted small">{$u.created_at|date_format:'%b %d, %Y'}</td>
                  <td><a href="/admin/users/{$u.id}" class="btn btn-xs btn-outline-secondary btn-sm py-0">View</a></td>
                </tr>
                {/foreach}
              {else}
                <tr><td colspan="5" class="text-center text-muted py-4">No users yet</td></tr>
              {/if}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>

  <div class="col-md-4">
    <div class="card h-100">
      <div class="card-header bg-white border-bottom py-3 d-flex justify-content-between align-items-center">
        <h6 class="mb-0 fw-bold"><i class="fas fa-exclamation-circle me-2 text-warning"></i>Pending Withdrawals</h6>
        <a href="/admin/withdrawals?status=pending" class="btn btn-sm btn-outline-warning">View All</a>
      </div>
      <div class="card-body p-0">
        {if $pending_withdrawals}
          <div class="list-group list-group-flush">
            {foreach $pending_withdrawals as $w}
            <div class="list-group-item">
              <div class="d-flex justify-content-between">
                <div>
                  <strong class="small">{$w.username|escape}</strong>
                  <div class="text-muted" style="font-size:.75rem;">{$w.currency} - {$w.method}</div>
                </div>
                <div class="text-end">
                  <strong class="text-warning">${$w.amount|string_format:"%.2f"}</strong>
                  <div class="text-muted" style="font-size:.75rem;">{$w.created_at|date_format:'%b %d'}</div>
                </div>
              </div>
            </div>
            {/foreach}
          </div>
        {else}
          <div class="text-center text-muted py-4 small">No pending withdrawals</div>
        {/if}
      </div>
    </div>
  </div>
</div>

<div class="row g-3">
  <div class="col-md-6">
    <div class="card">
      <div class="card-header bg-white border-bottom py-3 d-flex justify-content-between align-items-center">
        <h6 class="mb-0 fw-bold"><i class="fas fa-arrow-down-to-bracket me-2 text-success"></i>Recent Deposits</h6>
        <a href="/admin/deposits" class="btn btn-sm btn-outline-success">View All</a>
      </div>
      <div class="card-body p-0">
        <div class="table-responsive">
          <table class="table table-sm table-hover mb-0">
            <thead class="table-light">
              <tr><th>Amount</th><th>Currency</th><th>Status</th><th>Date</th></tr>
            </thead>
            <tbody>
              {if $recent_deposits}
                {foreach $recent_deposits as $d}
                <tr>
                  <td><strong>${$d.amount|string_format:"%.2f"}</strong></td>
                  <td>{$d.currency}</td>
                  <td><span class="badge badge-status-{$d.status}">{$d.status|ucfirst}</span></td>
                  <td class="text-muted small">{$d.created_at|date_format:'%b %d'}</td>
                </tr>
                {/foreach}
              {else}
                <tr><td colspan="4" class="text-center text-muted py-3">No deposits yet</td></tr>
              {/if}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>

  <div class="col-md-6">
    <div class="card">
      <div class="card-header bg-white border-bottom py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-shield-halved me-2 text-danger"></i>Recent Activity Log</h6>
      </div>
      <div class="card-body p-0">
        {if $recent_logs}
          <div class="list-group list-group-flush" style="max-height:300px;overflow-y:auto;">
            {foreach $recent_logs as $log}
            <div class="list-group-item py-2">
              <div class="d-flex justify-content-between align-items-start">
                <div>
                  <span class="badge bg-secondary bg-opacity-25 text-dark small">{$log.action|replace:'_':' '|ucfirst}</span>
                  <div class="text-muted" style="font-size:.75rem;">{$log.description|escape|truncate:60}</div>
                </div>
                <div class="text-muted" style="font-size:.7rem;white-space:nowrap;">{$log.created_at|date_format:'%H:%i'}</div>
              </div>
            </div>
            {/foreach}
          </div>
        {else}
          <div class="text-center text-muted py-4 small">No activity logs yet</div>
        {/if}
      </div>
    </div>
  </div>
</div>

{/block}
