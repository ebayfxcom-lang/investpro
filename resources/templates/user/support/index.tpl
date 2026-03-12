{extends file="layouts/user.tpl"}
{block name="content"}
<div class="d-flex justify-content-between align-items-center mb-4">
  <div>
    <h5 class="fw-bold mb-1">Support Tickets</h5>
    <p class="text-muted small mb-0">Get help from our support team.</p>
  </div>
  <a href="/user/support/create" class="btn btn-accent btn-sm"><i class="fas fa-plus me-1"></i>New Ticket</a>
</div>

<div class="card">
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table mb-0">
        <thead>
          <tr><th>Reference</th><th>Subject</th><th>Department</th><th>Status</th><th>Last Updated</th><th></th></tr>
        </thead>
        <tbody>
          {foreach $tickets as $t}
          <tr>
            <td class="small fw-bold text-warning">{$t.reference}</td>
            <td class="small">{$t.subject|escape|truncate:50}</td>
            <td class="small text-muted">{$t.department_name|escape}</td>
            <td>
              {if $t.status === 'open'}<span class="badge badge-active">Open</span>
              {elseif $t.status === 'in_progress'}<span class="badge badge-completed">In Progress</span>
              {elseif $t.status === 'resolved'}<span class="badge badge-completed">Resolved</span>
              {elseif $t.status === 'closed'}<span class="badge bg-secondary">Closed</span>
              {else}<span class="badge badge-pending">{$t.status|ucfirst}</span>{/if}
            </td>
            <td class="small text-muted">{$t.updated_at|default:$t.created_at|date_format:'%b %d, %Y'}</td>
            <td><a href="/user/support/{$t.id}" class="btn btn-sm btn-outline-secondary">View</a></td>
          </tr>
          {foreachelse}
          <tr>
            <td colspan="6" class="text-center py-5">
              <i class="fas fa-headset fa-3x opacity-25 mb-3 d-block"></i>
              <p class="text-muted">No tickets yet. <a href="/user/support/create">Open a ticket</a> to get help.</p>
            </td>
          </tr>
          {/foreach}
        </tbody>
      </table>
    </div>
  </div>
</div>
{/block}
