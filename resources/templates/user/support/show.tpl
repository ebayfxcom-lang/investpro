{extends file="layouts/user.tpl"}
{block name="content"}
<div class="d-flex align-items-center gap-2 mb-4">
  <a href="/user/support" class="btn btn-sm btn-outline-secondary">← Tickets</a>
  <h5 class="fw-bold mb-0">{$ticket.reference}</h5>
  {if $ticket.status === 'open'}<span class="badge badge-active">Open</span>
  {elseif $ticket.status === 'in_progress'}<span class="badge badge-completed">In Progress</span>
  {elseif $ticket.status === 'resolved'}<span class="badge badge-completed">Resolved</span>
  {elseif $ticket.status === 'closed'}<span class="badge bg-secondary">Closed</span>
  {else}<span class="badge badge-pending">{$ticket.status|ucfirst}</span>{/if}
</div>

<div class="row g-3">
  <div class="col-lg-8">
    <div class="card">
      <div class="card-header py-3">
        <h6 class="mb-0">{$ticket.subject|escape}</h6>
      </div>
      <div class="card-body">
        {foreach $replies as $r}
        <div class="mb-3 p-3 rounded {if $r.is_staff}bg-primary bg-opacity-10{else}border{/if}">
          <div class="d-flex justify-content-between mb-1">
            <span class="fw-semibold small">
              {if $r.is_staff}<i class="fas fa-headset me-1 text-primary"></i>Support Team
              {else}<i class="fas fa-user me-1"></i>You{/if}
            </span>
            <span class="text-muted small">{$r.created_at|date_format:'%b %d, %Y %H:%M'}</span>
          </div>
          <p class="mb-0 small" style="white-space:pre-wrap">{$r.body|escape}</p>
        </div>
        {foreachelse}
        <p class="text-muted text-center py-3">No replies yet.</p>
        {/foreach}

        {if $ticket.status !== 'closed'}
        <hr>
        <form method="POST" action="/user/support/{$ticket.id}">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">
          <div class="mb-2">
            <textarea name="body" class="form-control" rows="3" placeholder="Add a reply..." required></textarea>
          </div>
          <button type="submit" class="btn btn-accent btn-sm">Send Reply</button>
        </form>
        {else}
        <div class="alert alert-secondary text-center small mt-3">This ticket is closed.</div>
        {/if}
      </div>
    </div>
  </div>
  <div class="col-lg-4">
    <div class="card">
      <div class="card-header py-3">
        <h6 class="mb-0 fw-bold">Details</h6>
      </div>
      <div class="card-body small">
        <dl class="row mb-0">
          <dt class="col-5">Reference</dt><dd class="col-7 text-warning fw-bold">{$ticket.reference}</dd>
          <dt class="col-5">Department</dt><dd class="col-7">{$ticket.department_name|escape}</dd>
          <dt class="col-5">Priority</dt><dd class="col-7">{$ticket.priority|ucfirst}</dd>
          <dt class="col-5">Created</dt><dd class="col-7 text-muted">{$ticket.created_at|date_format:'%b %d, %Y'}</dd>
        </dl>
      </div>
    </div>
  </div>
</div>
{/block}
