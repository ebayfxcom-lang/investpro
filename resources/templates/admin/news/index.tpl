{extends file="layouts/admin.tpl"}
{block name="content"}

<div class="d-flex justify-content-between align-items-center mb-3">
  <h6 class="fw-bold mb-0"><i class="fas fa-newspaper me-2 text-primary"></i>News Manager</h6>
  <button class="btn btn-accent btn-sm" data-bs-toggle="modal" data-bs-target="#createNewsModal">
    <i class="fas fa-plus me-1"></i>Create Post
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
            <th>Publisher</th>
            <th>Status</th>
            <th>Published At</th>
            <th>Created</th>
            <th class="text-end">Actions</th>
          </tr>
        </thead>
        <tbody>
          {if $data.items}
            {foreach $data.items as $n}
            <tr>
              <td class="text-muted small">{$n.id}</td>
              <td class="fw-semibold">{$n.title|escape|truncate:60:'...'}</td>
              <td class="text-muted small">{$n.publisher_name|default:'—'|escape}</td>
              <td>
                <span class="badge {if $n.status == 'published'}bg-success bg-opacity-25 text-success{else}bg-secondary bg-opacity-25 text-muted{/if}">
                  {$n.status|ucfirst}
                </span>
              </td>
              <td class="text-muted small">
                {if $n.published_at}{$n.published_at|date_format:'%b %d, %Y'}{else}—{/if}
              </td>
              <td class="text-muted small">{$n.created_at|date_format:'%b %d, %Y'}</td>
              <td class="text-end">
                <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#editNewsModal"
                  data-id="{$n.id}" data-title="{$n.title|escape:'html'}"
                  data-content="{$n.content|escape:'html'}" data-status="{$n.status}"
                  data-publisher="{$n.publisher_name|default:''|escape:'html'}"
                  data-hashtags="{$n.hashtags|default:''|escape:'html'}">
                  <i class="fas fa-pen"></i>
                </button>
                <form method="POST" action="/admin/news" class="d-inline">
                  <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                  <input type="hidden" name="action" value="delete">
                  <input type="hidden" name="news_id" value="{$n.id}">
                  <button type="submit" class="btn btn-sm btn-outline-danger"
                          onclick="return confirm('Delete this news post?')">
                    <i class="fas fa-trash"></i>
                  </button>
                </form>
              </td>
            </tr>
            {/foreach}
          {else}
            <tr><td colspan="6" class="text-center text-muted py-5">No news posts yet.</td></tr>
          {/if}
        </tbody>
      </table>
    </div>
  </div>
  {if $data.total_pages > 1}
  <div class="card-footer bg-white d-flex justify-content-between align-items-center py-3">
    <div class="text-muted small">Showing {$data.items|@count} of {$data.total} posts</div>
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
<div class="modal fade" id="createNewsModal" tabindex="-1">
  <div class="modal-dialog modal-lg">
    <form method="POST" action="/admin/news">
      <input type="hidden" name="_csrf_token" value="{$csrf_token}">
      <input type="hidden" name="action" value="create">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title fw-bold">Create News Post</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label class="form-label fw-semibold">Title <span class="text-danger">*</span></label>
            <input type="text" name="title" class="form-control" required>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Publisher Name</label>
            <input type="text" name="publisher_name" class="form-control" placeholder="Author or publisher name">
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Content <span class="text-danger">*</span></label>
            <textarea name="content" class="form-control" rows="6" required></textarea>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Hashtags</label>
            <input type="text" name="hashtags" class="form-control" placeholder="#bitcoin, #investment, #crypto">
            <div class="form-text">Comma-separated hashtags for SEO and discoverability.</div>
          </div>
          <div>
            <label class="form-label fw-semibold">Status</label>
            <select name="status" class="form-select">
              <option value="draft">Draft</option>
              <option value="published">Published</option>
            </select>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
          <button type="submit" class="btn btn-accent"><i class="fas fa-save me-1"></i>Save Post</button>
        </div>
      </div>
    </form>
  </div>
</div>

{* Edit Modal *}
<div class="modal fade" id="editNewsModal" tabindex="-1">
  <div class="modal-dialog modal-lg">
    <form method="POST" action="/admin/news">
      <input type="hidden" name="_csrf_token" value="{$csrf_token}">
      <input type="hidden" name="action" value="update">
      <input type="hidden" name="news_id" id="editNewsId">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title fw-bold">Edit News Post</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label class="form-label fw-semibold">Title</label>
            <input type="text" name="title" id="editNewsTitle" class="form-control" required>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Publisher Name</label>
            <input type="text" name="publisher_name" id="editNewsPublisher" class="form-control" placeholder="Author or publisher name">
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Content</label>
            <textarea name="content" id="editNewsContent" class="form-control" rows="6" required></textarea>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Hashtags</label>
            <input type="text" name="hashtags" id="editNewsHashtags" class="form-control" placeholder="#bitcoin, #investment">
          </div>
          <div>
            <label class="form-label fw-semibold">Status</label>
            <select name="status" id="editNewsStatus" class="form-select">
              <option value="draft">Draft</option>
              <option value="published">Published</option>
            </select>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
          <button type="submit" class="btn btn-accent"><i class="fas fa-save me-1"></i>Update Post</button>
        </div>
      </div>
    </form>
  </div>
</div>

<script>
(function () {
  document.getElementById('editNewsModal').addEventListener('show.bs.modal', function (e) {
    const btn = e.relatedTarget;
    document.getElementById('editNewsId').value        = btn.dataset.id;
    document.getElementById('editNewsTitle').value     = btn.dataset.title;
    document.getElementById('editNewsContent').value   = btn.dataset.content;
    document.getElementById('editNewsStatus').value    = btn.dataset.status;
    document.getElementById('editNewsPublisher').value = btn.dataset.publisher || '';
    document.getElementById('editNewsHashtags').value  = btn.dataset.hashtags || '';
  });
}());
</script>
{/block}

