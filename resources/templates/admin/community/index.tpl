{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="d-flex justify-content-between align-items-center mb-3">
  <h6 class="fw-bold mb-0">Community Feed</h6>
  <div class="d-flex gap-2">
    <button class="btn btn-sm btn-accent" data-bs-toggle="modal" data-bs-target="#createPostModal">
      <i class="fas fa-pen me-1"></i>New Post
    </button>
    <a href="/admin/community/keywords" class="btn btn-sm btn-outline-danger">
      <i class="fas fa-ban me-1"></i>Keywords
    </a>
    <a href="/admin/community/bots" class="btn btn-sm btn-outline-primary">
      <i class="fas fa-robot me-1"></i>Manage Bots
    </a>
  </div>
</div>

<div class="card">
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead>
          <tr>
            <th>#</th>
            <th>User</th>
            <th>Content</th>
            <th>Likes</th>
            <th>Bot</th>
            <th>Status</th>
            <th>Date</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {foreach $data.items as $post}
          <tr class="{if $post.status !== 'active'}opacity-50{/if}">
            <td class="small">{$post.id}</td>
            <td class="small fw-semibold">{$post.username|escape}</td>
            <td class="small" style="max-width:300px">{$post.content|escape|truncate:80}</td>
            <td class="small">{$post.likes_count}</td>
            <td>{if $post.is_bot}<span class="badge bg-info text-dark">Bot</span>{else}<span class="text-muted small">-</span>{/if}</td>
            <td>
              {if $post.status === 'active'}<span class="badge badge-status-active">Active</span>
              {elseif $post.status === 'hidden'}<span class="badge badge-status-pending">Hidden</span>
              {else}<span class="badge badge-status-rejected">Deleted</span>{/if}
            </td>
            <td class="small text-muted">{$post.created_at|date_format:'%b %d'}</td>
            <td>
              {if $post.status === 'active' || $post.status === 'hidden'}
              <form method="POST" action="/admin/community/{$post.id}/hide" class="d-inline">
                <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                <button type="submit" class="btn btn-sm btn-outline-warning me-1"
                        title="{if $post.is_hidden}Unhide{else}Hide{/if}">
                  <i class="fas {if $post.is_hidden}fa-eye{else}fa-eye-slash{/if}"></i>
                </button>
              </form>
              <form method="POST" action="/admin/community/{$post.id}/feature" class="d-inline">
                <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                <button type="submit" class="btn btn-sm btn-outline-info me-1"
                        title="{if $post.is_featured}Unfeature{else}Feature{/if}">
                  <i class="fas fa-star{if !$post.is_featured}-half-alt{/if}"></i>
                </button>
              </form>
              {/if}
              {if $post.status === 'active'}
              <form method="POST" action="/admin/community/{$post.id}/delete" class="d-inline">
                <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                <button type="submit" class="btn btn-sm btn-outline-danger"
                        onclick="return confirm('Delete this post?')">
                  <i class="fas fa-trash"></i>
                </button>
              </form>
              {/if}
            </td>
          </tr>
          {foreachelse}
          <tr><td colspan="8" class="text-center text-muted py-4">No posts yet.</td></tr>
          {/foreach}
        </tbody>
      </table>
    </div>
  </div>
</div>

{if $data.total_pages > 1}
<nav class="mt-3">
  <ul class="pagination">
    {for $p=1 to $data.total_pages}
    <li class="page-item {if $p == $data.page}active{/if}">
      <a class="page-link" href="?page={$p}">{$p}</a>
    </li>
    {/for}
  </ul>
</nav>
{/if}

<!-- Create Post Modal -->
<div class="modal fade" id="createPostModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title"><i class="fas fa-pen me-2"></i>Post to Community</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <form method="POST" action="/admin/community/post">
        <input type="hidden" name="_csrf_token" value="{$csrf_token}">
        <div class="modal-body">
          <div class="mb-3">
            <label class="form-label fw-semibold">Post Content <span class="text-danger">*</span></label>
            <textarea name="content" class="form-control" rows="5" maxlength="2000"
                      placeholder="Write your community post..." required></textarea>
            <div class="form-text text-end"><span id="adminPostCharCount">0</span>/2000</div>
          </div>
          <div class="form-check">
            <input class="form-check-input" type="checkbox" name="is_featured" value="1" id="adminPostFeatured">
            <label class="form-check-label small" for="adminPostFeatured">Feature this post (pin at top)</label>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
          <button type="submit" class="btn btn-accent">Publish Post</button>
        </div>
      </form>
    </div>
  </div>
</div>
<script>
{literal}
document.querySelector('textarea[name="content"]')?.addEventListener('input', function() {
  document.getElementById('adminPostCharCount').textContent = this.value.length;
});
{/literal}
</script>
{/block}
