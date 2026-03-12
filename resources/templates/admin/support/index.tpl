{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="d-flex gap-2 mb-3 flex-wrap">
  <a href="/admin/support" class="btn btn-sm {if !$filter_status}btn-accent{else}btn-outline-secondary{/if}">All</a>
  <a href="/admin/support?status=open" class="btn btn-sm {if $filter_status === 'open'}btn-accent{else}btn-outline-secondary{/if}">Open</a>
  <a href="/admin/support?status=in_progress" class="btn btn-sm {if $filter_status === 'in_progress'}btn-accent{else}btn-outline-secondary{/if}">In Progress</a>
  <a href="/admin/support?status=waiting" class="btn btn-sm {if $filter_status === 'waiting'}btn-accent{else}btn-outline-secondary{/if}">Waiting</a>
  <a href="/admin/support?status=resolved" class="btn btn-sm {if $filter_status === 'resolved'}btn-accent{else}btn-outline-secondary{/if}">Resolved</a>
  <a href="/admin/support?status=closed" class="btn btn-sm {if $filter_status === 'closed'}btn-accent{else}btn-outline-secondary{/if}">Closed</a>
  <span class="ms-auto text-muted small align-self-center">Total: {$data.total}</span>
</div>
<div class="card">
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table mb-0">
        <thead>
          <tr><th>Ref</th><th>Subject</th><th>User</th><th>Department</th><th>Priority</th><th>Status</th><th>Created</th><th></th></tr>
        </thead>
        <tbody>
          {foreach $data.items as $t}
          <tr>
            <td class="small fw-bold text-warning">{$t.reference}</td>
            <td class="small">{$t.subject|escape|truncate:50}</td>
            <td class="small">{$t.user_name|default:'Guest'|escape}</td>
            <td class="small">{$t.department_name|escape}</td>
            <td>
              {if $t.priority === 'urgent'}<span class="badge bg-danger">Urgent</span>
              {elseif $t.priority === 'high'}<span class="badge bg-warning text-dark">High</span>
              {else}<span class="badge bg-secondary">{$t.priority|ucfirst}</span>{/if}
            </td>
            <td>
              {if $t.status === 'open'}<span class="badge badge-status-active">Open</span>
              {elseif $t.status === 'in_progress'}<span class="badge badge-status-completed">In Progress</span>
              {elseif $t.status === 'resolved'}<span class="badge badge-status-completed">Resolved</span>
              {elseif $t.status === 'closed'}<span class="badge bg-secondary">Closed</span>
              {else}<span class="badge badge-status-pending">{$t.status|ucfirst}</span>{/if}
            </td>
            <td class="small text-muted">{$t.created_at|date_format:'%b %d, %Y'}</td>
            <td><a href="/admin/support/{$t.id}" class="btn btn-sm btn-outline-secondary">View</a></td>
          </tr>
          {foreachelse}
          <tr><td colspan="8" class="text-center text-muted py-4">No tickets.</td></tr>
          {/foreach}
        </tbody>
      </table>
    </div>
  </div>
</div>
{/block}
