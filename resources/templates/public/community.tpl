{extends file="layouts/public.tpl"}
{block name="content"}
<div class="container py-5">
  <div class="row">
    <div class="col-lg-8 mx-auto">
      <div class="mb-4">
        <h2 class="fw-bold">Community</h2>
        <p class="text-muted">See what our members are saying. <a href="/register">Join</a> to participate.</p>
      </div>

      {foreach $feed.items as $post}
      <div class="card mb-3">
        <div class="card-body">
          <div class="d-flex align-items-center mb-2">
            <div class="me-2 rounded-circle d-flex align-items-center justify-content-center"
                 style="width:38px;height:38px;font-size:.85rem;font-weight:700;background:rgba(240,185,11,.15);color:#f0b90b">
              {$post.username|upper|truncate:1:'':''}
            </div>
            <div>
              <div class="fw-semibold small">{$post.username|escape}</div>
              <div class="text-muted" style="font-size:.75rem">{$post.created_at|date_format:'%b %d, %Y'}</div>
            </div>
          </div>
          <p class="mb-2" style="white-space:pre-wrap">{$post.content|escape}</p>
          <div class="d-flex gap-3 text-muted small">
            <span><i class="fas fa-thumbs-up me-1"></i>{$post.likes_count|default:0}</span>
            <span><i class="fas fa-comment me-1"></i>{$post.comment_count} comment{if $post.comment_count != 1}s{/if}</span>
          </div>
        </div>
      </div>
      {foreachelse}
      <div class="text-center text-muted py-5">
        <i class="fas fa-comments fa-3x mb-3 opacity-25"></i>
        <p>No posts yet.</p>
      </div>
      {/foreach}

      {if $feed.total_pages > 1}
      <nav>
        <ul class="pagination justify-content-center">
          {for $p=1 to $feed.total_pages}
          <li class="page-item {if $p == $feed.page}active{/if}">
            <a class="page-link" href="?page={$p}">{$p}</a>
          </li>
          {/for}
        </ul>
      </nav>
      {/if}

      <div class="text-center mt-4">
        <a href="/register" class="btn btn-primary btn-lg">Join Community</a>
      </div>
    </div>
  </div>
</div>
{/block}
