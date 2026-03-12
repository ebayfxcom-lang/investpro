{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="row g-3">
  <div class="col-lg-8">
    <div class="card mb-3">
      <div class="card-header py-3 d-flex justify-content-between align-items-center">
        <h6 class="mb-0 fw-bold">{$ticket.subject|escape}</h6>
        <span class="badge badge-status-pending">{$ticket.reference}</span>
      </div>
      <div class="card-body">
        {foreach $replies as $r}
        <div class="mb-3 p-3 rounded {if $r.is_internal_note}bg-warning bg-opacity-10 border border-warning{elseif $r.is_staff}bg-primary bg-opacity-10{else}border{/if}">
          <div class="d-flex justify-content-between mb-1">
            <span class="fw-semibold small">
              {if $r.is_staff}<i class="fas fa-headset me-1 text-primary"></i>{$r.staff_name|default:'Staff'|escape}
              {else}<i class="fas fa-user me-1"></i>{$ticket.user_name|default:'User'|escape}{/if}
              {if $r.is_internal_note}<span class="badge bg-warning text-dark ms-2">Internal Note</span>{/if}
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
        <form method="POST" action="/admin/support/{$ticket.id}">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">
          <input type="hidden" name="action" value="reply">
          <div class="mb-2">
            <textarea name="body" class="form-control form-control-sm" rows="4" placeholder="Your reply..." required></textarea>
          </div>
          <div class="form-check mb-2">
            <input class="form-check-input" type="checkbox" name="is_internal" value="1" id="internalNote">
            <label class="form-check-label small" for="internalNote">Internal note (not visible to user)</label>
          </div>
          <button type="submit" class="btn btn-accent btn-sm">Send Reply</button>
        </form>
        {/if}
      </div>
    </div>
  </div>

  <div class="col-lg-4">
    <div class="card mb-3">
      <div class="card-header py-3">
        <h6 class="mb-0 fw-bold">Ticket Info</h6>
      </div>
      <div class="card-body small">
        <dl class="row mb-0">
          <dt class="col-5">Reference</dt><dd class="col-7 text-warning fw-bold">{$ticket.reference}</dd>
          <dt class="col-5">User</dt><dd class="col-7">{$ticket.user_name|default:'Guest'|escape}</dd>
          <dt class="col-5">Department</dt><dd class="col-7">{$ticket.department_name|escape}</dd>
          <dt class="col-5">Priority</dt><dd class="col-7">{$ticket.priority|ucfirst}</dd>
          <dt class="col-5">Status</dt><dd class="col-7">{$ticket.status|replace:'_':' '|ucfirst}</dd>
          <dt class="col-5">Created</dt><dd class="col-7 text-muted">{$ticket.created_at|date_format:'%b %d, %Y'}</dd>
        </dl>
      </div>
    </div>

    <div class="card">
      <div class="card-header py-3">
        <h6 class="mb-0 fw-bold">Actions</h6>
      </div>
      <div class="card-body">
        <form method="POST" action="/admin/support/{$ticket.id}" class="mb-2">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">
          <input type="hidden" name="action" value="update_status">
          <select name="status" class="form-select form-select-sm mb-2">
            <option value="open" {if $ticket.status === 'open'}selected{/if}>Open</option>
            <option value="in_progress" {if $ticket.status === 'in_progress'}selected{/if}>In Progress</option>
            <option value="waiting" {if $ticket.status === 'waiting'}selected{/if}>Waiting</option>
            <option value="resolved" {if $ticket.status === 'resolved'}selected{/if}>Resolved</option>
            <option value="closed" {if $ticket.status === 'closed'}selected{/if}>Closed</option>
          </select>
          <button type="submit" class="btn btn-sm btn-outline-secondary w-100">Update Status</button>
        </form>
        <a href="/admin/support" class="btn btn-sm btn-outline-secondary w-100">← Back to Tickets</a>
      </div>
    </div>
  </div>
</div>
{/block}
