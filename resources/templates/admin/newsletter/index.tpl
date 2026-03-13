{extends file="layouts/admin.tpl"}
{block name="content"}

{* Stats row *}
<div class="row g-3 mb-4">
  <div class="col-sm-3">
    <div class="stat-card">
      <div class="d-flex justify-content-between align-items-start">
        <div>
          <div class="text-muted small mb-1">Total Newsletters</div>
          <div class="h4 fw-bold mb-0">{$stats.total}</div>
        </div>
        <div class="stat-icon bg-success bg-opacity-10 text-success"><i class="fas fa-mail-bulk"></i></div>
      </div>
    </div>
  </div>
  <div class="col-sm-3">
    <div class="stat-card">
      <div class="d-flex justify-content-between align-items-start">
        <div>
          <div class="text-muted small mb-1">Sent</div>
          <div class="h4 fw-bold mb-0">{$stats.sent}</div>
        </div>
        <div class="stat-icon bg-primary bg-opacity-10 text-primary"><i class="fas fa-paper-plane"></i></div>
      </div>
    </div>
  </div>
  <div class="col-sm-3">
    <div class="stat-card">
      <div class="d-flex justify-content-between align-items-start">
        <div>
          <div class="text-muted small mb-1">Drafts</div>
          <div class="h4 fw-bold mb-0">{$stats.drafts}</div>
        </div>
        <div class="stat-icon bg-warning bg-opacity-10 text-warning"><i class="fas fa-edit"></i></div>
      </div>
    </div>
  </div>
  <div class="col-sm-3">
    <div class="stat-card">
      <div class="d-flex justify-content-between align-items-start">
        <div>
          <div class="text-muted small mb-1">Guest Subscribers</div>
          <div class="h4 fw-bold mb-0">{$stats.subscribers}</div>
        </div>
        <div class="stat-icon bg-info bg-opacity-10 text-info"><i class="fas fa-users"></i></div>
      </div>
    </div>
  </div>
</div>

<div class="d-flex justify-content-between align-items-center mb-3">
  <h6 class="fw-bold mb-0"><i class="fas fa-mail-bulk me-2 text-success"></i>Newsletter Manager</h6>
  <button class="btn btn-accent btn-sm" data-bs-toggle="modal" data-bs-target="#createNewsletterModal">
    <i class="fas fa-plus me-1"></i>Create Newsletter
  </button>
</div>

<div class="card">
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead class="table-light">
          <tr>
            <th>#</th>
            <th>Subject</th>
            <th>Sender</th>
            <th>Recipients</th>
            <th>Status</th>
            <th>Sent Count</th>
            <th>Date</th>
            <th class="text-end">Actions</th>
          </tr>
        </thead>
        <tbody>
          {if $data.items}
            {foreach $data.items as $nl}
            <tr>
              <td class="text-muted small">{$nl.id}</td>
              <td class="fw-semibold">{$nl.subject|escape|truncate:50:'...'}</td>
              <td class="text-muted small">{$nl.sender_name|default:'-'|escape}</td>
              <td><span class="badge bg-info bg-opacity-25 text-info">{$nl.recipients|ucfirst}</span></td>
              <td>
                <span class="badge {if $nl.status == 'sent'}bg-success bg-opacity-25 text-success{else}bg-warning bg-opacity-25 text-warning{/if}">
                  {$nl.status|ucfirst}
                </span>
              </td>
              <td>{$nl.sent_count}</td>
              <td class="text-muted small">
                {if $nl.sent_at}{$nl.sent_at|date_format:'%b %d, %Y'}{else}{$nl.created_at|date_format:'%b %d, %Y'}{/if}
              </td>
              <td class="text-end">
                {if $nl.status == 'draft'}
                <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#editNewsletterModal"
                  data-id="{$nl.id}" data-subject="{$nl.subject|escape:'html'}"
                  data-content="{$nl.content|escape:'html'}" data-recipients="{$nl.recipients}">
                  <i class="fas fa-pen"></i>
                </button>
                <form method="POST" action="/admin/newsletter" class="d-inline">
                  <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                  <input type="hidden" name="action" value="send">
                  <input type="hidden" name="newsletter_id" value="{$nl.id}">
                  <button type="submit" class="btn btn-sm btn-success"
                          onclick="return confirm('Send this newsletter now?')">
                    <i class="fas fa-paper-plane"></i>
                  </button>
                </form>
                {/if}
                <form method="POST" action="/admin/newsletter" class="d-inline">
                  <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                  <input type="hidden" name="action" value="delete">
                  <input type="hidden" name="newsletter_id" value="{$nl.id}">
                  <button type="submit" class="btn btn-sm btn-outline-danger"
                          onclick="return confirm('Delete this newsletter?')">
                    <i class="fas fa-trash"></i>
                  </button>
                </form>
              </td>
            </tr>
            {/foreach}
          {else}
            <tr><td colspan="7" class="text-center text-muted py-5">No newsletters yet. Click "Create Newsletter" to start.</td></tr>
          {/if}
        </tbody>
      </table>
    </div>
  </div>
  {if $data.total_pages > 1}
  <div class="card-footer bg-white d-flex justify-content-between align-items-center py-3">
    <div class="text-muted small">Showing {$data.items|@count} of {$data.total}</div>
    <nav><ul class="pagination pagination-sm mb-0">
      {for $p = 1 to $data.total_pages}
      <li class="page-item {if $p == $data.page}active{/if}">
        <a class="page-link" href="?page={$p}">{$p}</a>
      </li>
      {/for}
    </ul></nav>
  </div>
  {/if}
</div>

{* Create Modal *}
<div class="modal fade" id="createNewsletterModal" tabindex="-1">
  <div class="modal-dialog modal-lg">
    <form method="POST" action="/admin/newsletter">
      <input type="hidden" name="_csrf_token" value="{$csrf_token}">
      <input type="hidden" name="action" value="create">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title fw-bold">Create Newsletter</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label class="form-label fw-semibold">Subject <span class="text-danger">*</span></label>
            <input type="text" name="subject" class="form-control" required>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Sender Name</label>
            <input type="text" name="sender_name" class="form-control" placeholder="e.g. Support Team">
            <div class="form-text">Optional. Displayed in the newsletter list as who sent this.</div>
          </div>
        <div class="mb-3">
            <label class="form-label fw-semibold">Content <span class="text-danger">*</span></label>
            <textarea name="content" class="form-control" rows="8" required
                      placeholder="Write your newsletter content here. HTML is supported."></textarea>
            <div class="form-text">
              Available placeholders: <code>{literal}{{name}}{/literal}</code> (username), <code>{literal}{{email}}{/literal}</code>, <code>{literal}{{site_name}}{/literal}</code>, <code>{literal}{{site_url}}{/literal}</code>, <code>{literal}{{unsubscribe_url}}{/literal}</code>
            </div>
          </div>
          <div>
            <label class="form-label fw-semibold">Recipients</label>
            <select name="recipients" class="form-select">
              <option value="all">All Users</option>
              <option value="active">Active Users Only</option>
              <option value="subscribers">Guest Subscribers Only</option>
              <option value="non_user_subscribers">Subscribers Not in User System</option>
              <option value="non_deposited">Users Without Deposits</option>
            </select>
          </div>
          <div class="mt-2">
            <label class="form-label fw-semibold small">Filter by Active Plan Name <span class="text-muted">(optional)</span></label>
            <input type="text" name="plan_filter" class="form-control form-control-sm"
                   placeholder="e.g. Gold Plan – leave blank to skip">
            <div class="form-text">Applies only when Recipients is set to All Users or Active Users.</div>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
          <button type="submit" class="btn btn-accent"><i class="fas fa-save me-1"></i>Save Draft</button>
        </div>
      </div>
    </form>
  </div>
</div>

{* Edit Modal *}
<div class="modal fade" id="editNewsletterModal" tabindex="-1">
  <div class="modal-dialog modal-lg">
    <form method="POST" action="/admin/newsletter">
      <input type="hidden" name="_csrf_token" value="{$csrf_token}">
      <input type="hidden" name="action" value="update">
      <input type="hidden" name="newsletter_id" id="editNlId">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title fw-bold">Edit Newsletter</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label class="form-label fw-semibold">Subject</label>
            <input type="text" name="subject" id="editNlSubject" class="form-control" required>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Content</label>
            <textarea name="content" id="editNlContent" class="form-control" rows="8" required></textarea>
            <div class="form-text">
              Available placeholders: <code>{literal}{{name}}{/literal}</code>, <code>{literal}{{email}}{/literal}</code>, <code>{literal}{{site_name}}{/literal}</code>, <code>{literal}{{site_url}}{/literal}</code>, <code>{literal}{{unsubscribe_url}}{/literal}</code>
            </div>
          </div>
          <div>
            <label class="form-label fw-semibold">Recipients</label>
            <select name="recipients" id="editNlRecipients" class="form-select">
              <option value="all">All Users</option>
              <option value="active">Active Users Only</option>
              <option value="subscribers">Guest Subscribers Only</option>
              <option value="non_user_subscribers">Subscribers Not in User System</option>
              <option value="non_deposited">Users Without Deposits</option>
            </select>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
          <button type="submit" class="btn btn-accent"><i class="fas fa-save me-1"></i>Update Draft</button>
        </div>
      </div>
    </form>
  </div>
</div>

<script>
(function () {
  document.getElementById('editNewsletterModal').addEventListener('show.bs.modal', function (e) {
    const btn = e.relatedTarget;
    document.getElementById('editNlId').value         = btn.dataset.id;
    document.getElementById('editNlSubject').value    = btn.dataset.subject;
    document.getElementById('editNlContent').value    = btn.dataset.content;
    document.getElementById('editNlRecipients').value = btn.dataset.recipients;
  });
}());
</script>
{/block}

