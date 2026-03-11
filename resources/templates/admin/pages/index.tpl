{extends file="layouts/admin.tpl"}
{block name="content"}

<div class="d-flex justify-content-between align-items-center mb-3">
  <h6 class="fw-bold mb-0"><i class="fas fa-file-alt me-2 text-secondary"></i>Custom Pages</h6>
  <button class="btn btn-accent btn-sm" data-bs-toggle="modal" data-bs-target="#createPageModal">
    <i class="fas fa-plus me-1"></i>New Page
  </button>
</div>

<div class="card">
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead class="table-light">
          <tr>
            <th>#</th>
            <th>Title</th>
            <th>Slug</th>
            <th>Status</th>
            <th>Updated</th>
            <th class="text-end">Actions</th>
          </tr>
        </thead>
        <tbody>
          {if $pages}
            {foreach $pages as $pg}
            <tr>
              <td class="text-muted small">{$pg.id}</td>
              <td class="fw-semibold">{$pg.title|escape}</td>
              <td><code class="text-muted small">/{$pg.slug|escape}</code></td>
              <td>
                <span class="badge {if $pg.status == 'published'}bg-success bg-opacity-25 text-success{else}bg-secondary bg-opacity-25 text-muted{/if}">
                  {$pg.status|ucfirst}
                </span>
              </td>
              <td class="text-muted small">
                {if $pg.updated_at}{$pg.updated_at|date_format:'%b %d, %Y'}{else}{$pg.created_at|date_format:'%b %d, %Y'}{/if}
              </td>
              <td class="text-end">
                <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#editPageModal"
                  data-id="{$pg.id}" data-title="{$pg.title|escape:'html'}"
                  data-slug="{$pg.slug|escape:'html'}" data-content="{$pg.content|escape:'html'}"
                  data-meta="{$pg.meta_description|escape:'html'}" data-status="{$pg.status}">
                  <i class="fas fa-pen"></i>
                </button>
                <form method="POST" action="/admin/pages" class="d-inline">
                  <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                  <input type="hidden" name="action" value="delete">
                  <input type="hidden" name="page_id" value="{$pg.id}">
                  <button type="submit" class="btn btn-sm btn-outline-danger"
                          onclick="return confirm('Delete this page?')">
                    <i class="fas fa-trash"></i>
                  </button>
                </form>
              </td>
            </tr>
            {/foreach}
          {else}
            <tr><td colspan="6" class="text-center text-muted py-5">No pages yet. Click "New Page" to create one.</td></tr>
          {/if}
        </tbody>
      </table>
    </div>
  </div>
</div>

{* Create Page Modal *}
<div class="modal fade" id="createPageModal" tabindex="-1">
  <div class="modal-dialog modal-lg">
    <form method="POST" action="/admin/pages">
      <input type="hidden" name="_csrf_token" value="{$csrf_token}">
      <input type="hidden" name="action" value="create">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title fw-bold">Create Page</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <div class="row g-3">
            <div class="col-md-8">
              <label class="form-label fw-semibold">Title <span class="text-danger">*</span></label>
              <input type="text" name="title" class="form-control" required>
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Slug <span class="text-muted small">(auto)</span></label>
              <input type="text" name="slug" class="form-control" placeholder="leave empty for auto">
            </div>
            <div class="col-12">
              <label class="form-label fw-semibold">Content</label>
              <textarea name="content" class="form-control" rows="8"></textarea>
            </div>
            <div class="col-md-8">
              <label class="form-label fw-semibold">Meta Description</label>
              <input type="text" name="meta_description" class="form-control" maxlength="255">
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Status</label>
              <select name="status" class="form-select">
                <option value="draft">Draft</option>
                <option value="published">Published</option>
              </select>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
          <button type="submit" class="btn btn-accent"><i class="fas fa-save me-1"></i>Save Page</button>
        </div>
      </div>
    </form>
  </div>
</div>

{* Edit Page Modal *}
<div class="modal fade" id="editPageModal" tabindex="-1">
  <div class="modal-dialog modal-lg">
    <form method="POST" action="/admin/pages">
      <input type="hidden" name="_csrf_token" value="{$csrf_token}">
      <input type="hidden" name="action" value="update">
      <input type="hidden" name="page_id" id="editPageId">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title fw-bold">Edit Page</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <div class="row g-3">
            <div class="col-md-8">
              <label class="form-label fw-semibold">Title</label>
              <input type="text" name="title" id="editPageTitle" class="form-control" required>
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Slug</label>
              <input type="text" name="slug" id="editPageSlug" class="form-control">
            </div>
            <div class="col-12">
              <label class="form-label fw-semibold">Content</label>
              <textarea name="content" id="editPageContent" class="form-control" rows="8"></textarea>
            </div>
            <div class="col-md-8">
              <label class="form-label fw-semibold">Meta Description</label>
              <input type="text" name="meta_description" id="editPageMeta" class="form-control" maxlength="255">
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Status</label>
              <select name="status" id="editPageStatus" class="form-select">
                <option value="draft">Draft</option>
                <option value="published">Published</option>
              </select>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
          <button type="submit" class="btn btn-accent"><i class="fas fa-save me-1"></i>Update Page</button>
        </div>
      </div>
    </form>
  </div>
</div>

<script>
(function () {
  document.getElementById('editPageModal').addEventListener('show.bs.modal', function (e) {
    const btn = e.relatedTarget;
    document.getElementById('editPageId').value      = btn.dataset.id;
    document.getElementById('editPageTitle').value   = btn.dataset.title;
    document.getElementById('editPageSlug').value    = btn.dataset.slug;
    document.getElementById('editPageContent').value = btn.dataset.content;
    document.getElementById('editPageMeta').value    = btn.dataset.meta;
    document.getElementById('editPageStatus').value  = btn.dataset.status;
  });
}());
</script>
{/block}

