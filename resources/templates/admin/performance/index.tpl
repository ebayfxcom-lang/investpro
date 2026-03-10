{extends file="layouts/admin.tpl"}
{block name="content"}

<div class="row g-3 mb-4">
  <div class="col-sm-6 col-xl-3">
    <div class="stat-card">
      <div class="d-flex justify-content-between align-items-start">
        <div>
          <div class="text-muted small mb-1">PHP Version</div>
          <div class="h5 fw-bold mb-0">{$metrics.php_version}</div>
        </div>
        <div class="stat-icon bg-primary bg-opacity-10 text-primary"><i class="fab fa-php"></i></div>
      </div>
    </div>
  </div>
  <div class="col-sm-6 col-xl-3">
    <div class="stat-card">
      <div class="d-flex justify-content-between align-items-start">
        <div>
          <div class="text-muted small mb-1">Memory Usage</div>
          <div class="h5 fw-bold mb-0">{$metrics.memory_usage} MB</div>
          <div class="text-muted" style="font-size:.75rem;">Peak: {$metrics.memory_peak} MB / Limit: {$metrics.memory_limit}</div>
        </div>
        <div class="stat-icon bg-warning bg-opacity-10 text-warning"><i class="fas fa-memory"></i></div>
      </div>
    </div>
  </div>
  <div class="col-sm-6 col-xl-3">
    <div class="stat-card">
      <div class="d-flex justify-content-between align-items-start">
        <div>
          <div class="text-muted small mb-1">Upload Max</div>
          <div class="h5 fw-bold mb-0">{$metrics.upload_max}</div>
        </div>
        <div class="stat-icon bg-info bg-opacity-10 text-info"><i class="fas fa-upload"></i></div>
      </div>
    </div>
  </div>
  <div class="col-sm-6 col-xl-3">
    <div class="stat-card">
      <div class="d-flex justify-content-between align-items-start">
        <div>
          <div class="text-muted small mb-1">Max Exec Time</div>
          <div class="h5 fw-bold mb-0">{$metrics.max_exec_time}s</div>
        </div>
        <div class="stat-icon bg-danger bg-opacity-10 text-danger"><i class="fas fa-clock"></i></div>
      </div>
    </div>
  </div>
</div>

<div class="row g-3 mb-4">
  <div class="col-sm-6 col-xl-3">
    <div class="stat-card">
      <div class="text-muted small mb-1">Total Users</div>
      <div class="h4 fw-bold">{$counts.users}</div>
    </div>
  </div>
  <div class="col-sm-6 col-xl-3">
    <div class="stat-card">
      <div class="text-muted small mb-1">Total Deposits</div>
      <div class="h4 fw-bold">{$counts.deposits}</div>
    </div>
  </div>
  <div class="col-sm-6 col-xl-3">
    <div class="stat-card">
      <div class="text-muted small mb-1">Total Withdrawals</div>
      <div class="h4 fw-bold">{$counts.withdrawals}</div>
    </div>
  </div>
  <div class="col-sm-6 col-xl-3">
    <div class="stat-card">
      <div class="text-muted small mb-1">Total Transactions</div>
      <div class="h4 fw-bold">{$counts.transactions}</div>
    </div>
  </div>
</div>

<div class="card">
  <div class="card-header bg-white py-3">
    <h6 class="mb-0 fw-bold"><i class="fas fa-history me-2 text-secondary"></i>Recent Audit Log</h6>
  </div>
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead class="table-light">
          <tr>
            <th>Action</th>
            <th>Description</th>
            <th>User ID</th>
            <th>IP</th>
            <th>Time</th>
          </tr>
        </thead>
        <tbody>
          {foreach $recent_logs as $log}
          <tr>
            <td><span class="badge bg-secondary bg-opacity-25 text-dark font-monospace">{$log.action|escape}</span></td>
            <td class="text-muted small">{$log.description|escape}</td>
            <td class="text-muted small">{$log.user_id|default:'—'}</td>
            <td class="text-muted small font-monospace">{$log.ip|escape|default:'—'}</td>
            <td class="text-muted small">{$log.created_at|date_format:'%b %d %H:%M'}</td>
          </tr>
          {foreachelse}
          <tr><td colspan="5" class="text-center text-muted py-4">No log entries found.</td></tr>
          {/foreach}
        </tbody>
      </table>
    </div>
  </div>
</div>

{/block}
