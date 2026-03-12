{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="row g-3">
  <div class="col-lg-5">
    <div class="card">
      <div class="card-header py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-bell me-2 text-warning"></i>Create Notice</h6>
      </div>
      <div class="card-body">
        <form method="POST" action="/admin/notices">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">
          <input type="hidden" name="action" value="create">
          <div class="mb-2">
            <label class="form-label fw-semibold small">Title</label>
            <input type="text" name="title" class="form-control form-control-sm" required maxlength="200">
          </div>
          <div class="mb-2">
            <label class="form-label fw-semibold small">Body</label>
            <textarea name="body" class="form-control form-control-sm" rows="3" required maxlength="2000"></textarea>
          </div>
          <div class="row g-2 mb-2">
            <div class="col">
              <label class="form-label fw-semibold small">Type</label>
              <select name="notice_type" class="form-select form-select-sm">
                <option value="info">Info</option>
                <option value="success">Success</option>
                <option value="warning">Warning</option>
                <option value="danger">Danger</option>
              </select>
            </div>
            <div class="col">
              <label class="form-label fw-semibold small">Display As</label>
              <select name="display_type" class="form-select form-select-sm">
                <option value="banner">Banner</option>
                <option value="popup">Popup</option>
                <option value="both">Both</option>
              </select>
            </div>
          </div>
          <div class="mb-2">
            <label class="form-label fw-semibold small">Target Audience</label>
            <select name="target" class="form-select form-select-sm">
              <option value="all">All Users</option>
              <option value="deposited">Active Deposit Users</option>
              <option value="free">Free Users (No Deposit)</option>
              <option value="team">Team Users</option>
              <option value="representatives">Representatives</option>
              <option value="leaders">Team Leaders</option>
            </select>
          </div>
          <div class="row g-2 mb-2">
            <div class="col">
              <label class="form-label fw-semibold small">Starts At</label>
              <input type="datetime-local" name="starts_at" class="form-control form-control-sm">
            </div>
            <div class="col">
              <label class="form-label fw-semibold small">Ends At</label>
              <input type="datetime-local" name="ends_at" class="form-control form-control-sm">
            </div>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold small">Status</label>
            <select name="status" class="form-select form-select-sm">
              <option value="draft">Draft</option>
              <option value="published">Published</option>
            </select>
          </div>
          <button type="submit" class="btn btn-accent w-100">Create Notice</button>
        </form>
      </div>
    </div>
  </div>

  <div class="col-lg-7">
    <div class="card">
      <div class="card-header py-3">
        <h6 class="mb-0 fw-bold">All Notices ({$data.total})</h6>
      </div>
      <div class="card-body p-0">
        <div class="table-responsive">
          <table class="table mb-0">
            <thead>
              <tr><th>Title</th><th>Target</th><th>Type</th><th>Status</th><th>Actions</th></tr>
            </thead>
            <tbody>
              {foreach $data.items as $n}
              <tr>
                <td class="small fw-semibold">{$n.title|escape|truncate:40}</td>
                <td class="small">{$n.target|replace:'_':' '|ucfirst}</td>
                <td><span class="badge bg-{$n.notice_type}">{$n.notice_type|ucfirst}</span></td>
                <td>
                  {if $n.status === 'published'}<span class="badge badge-status-active">Published</span>
                  {elseif $n.status === 'expired'}<span class="badge badge-status-rejected">Expired</span>
                  {else}<span class="badge badge-status-pending">Draft</span>{/if}
                </td>
                <td>
                  {if $n.status !== 'published'}
                  <form method="POST" action="/admin/notices" class="d-inline">
                    <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                    <input type="hidden" name="action" value="publish">
                    <input type="hidden" name="notice_id" value="{$n.id}">
                    <button type="submit" class="btn btn-sm btn-outline-success me-1">Publish</button>
                  </form>
                  {/if}
                  {if $n.status === 'published'}
                  <form method="POST" action="/admin/notices" class="d-inline">
                    <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                    <input type="hidden" name="action" value="expire">
                    <input type="hidden" name="notice_id" value="{$n.id}">
                    <button type="submit" class="btn btn-sm btn-outline-secondary me-1">Expire</button>
                  </form>
                  {/if}
                  <form method="POST" action="/admin/notices" class="d-inline">
                    <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="notice_id" value="{$n.id}">
                    <button type="submit" class="btn btn-sm btn-outline-danger" onclick="return confirm('Delete?')">
                      <i class="fas fa-trash"></i>
                    </button>
                  </form>
                </td>
              </tr>
              {foreachelse}
              <tr><td colspan="5" class="text-center text-muted py-4">No notices yet.</td></tr>
              {/foreach}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>
{/block}
