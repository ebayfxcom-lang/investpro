{extends file="layouts/user.tpl"}
{block name="content"}
<div class="row mb-3">
  <div class="col">
    <h5 class="fw-bold mb-1">Community Square</h5>
    <p class="text-muted small">Share your experience, feedback, and updates.</p>
  </div>
</div>

<!-- Post form -->
<div class="card mb-4">
  <div class="card-body">
    <form id="postForm">
      <input type="hidden" name="_csrf_token" value="{$csrf_token}">
      <div class="mb-2">
        <textarea name="content" id="postContent" class="form-control" rows="3"
                  placeholder="Share something with the community..." maxlength="1000" required></textarea>
        <div class="form-text text-end"><span id="charCount">0</span>/1000</div>
      </div>
      <button type="submit" class="btn btn-primary btn-sm">
        <i class="fas fa-paper-plane me-1"></i>Post
      </button>
    </form>
  </div>
</div>

<!-- Feed -->
<div id="feedContainer">
  {foreach $feed.items as $post}
  <div class="card mb-3" id="post-{$post.id}">
    <div class="card-body">
      <div class="d-flex align-items-center mb-2">
        <div class="me-2 bg-primary bg-opacity-10 rounded-circle d-flex align-items-center justify-content-center"
             style="width:38px;height:38px;font-size:.85rem;font-weight:700;color:#60a5fa">
          {$post.username|upper|truncate:1:'':''}
        </div>
        <div>
          <div class="fw-semibold small">{$post.username|escape}</div>
          <div class="text-muted" style="font-size:.75rem">{$post.created_at|date_format:'%b %d, %Y %H:%M'}</div>
        </div>
      </div>
      <p class="mb-2" style="white-space:pre-wrap">{$post.content|escape}</p>
      <div class="d-flex align-items-center gap-3">
        <button class="btn btn-link btn-sm text-muted p-0 like-btn" data-post="{$post.id}">
          <i class="fas fa-thumbs-up me-1"></i>
          <span class="like-count">{$post.likes_count}</span>
        </button>
        <span class="text-muted small">
          <i class="fas fa-comment me-1"></i>{$post.comment_count} comment{if $post.comment_count != 1}s{/if}
        </span>
      </div>
    </div>
  </div>
  {foreachelse}
  <div class="text-center text-muted py-5">
    <i class="fas fa-comments fa-3x mb-3 opacity-25"></i>
    <p>No posts yet. Be the first to share!</p>
  </div>
  {/foreach}
</div>

<!-- Pagination -->
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

<script>
{literal}
const csrfToken = document.querySelector('#postForm [name="_csrf_token"]').value;

// Character counter
document.getElementById('postContent')?.addEventListener('input', function() {
  document.getElementById('charCount').textContent = this.value.length;
});

// Post submission
document.getElementById('postForm')?.addEventListener('submit', async function(e) {
  e.preventDefault();
  const content = document.getElementById('postContent').value.trim();
  if (!content) return;
  const res = await fetch('/user/community/post', {
    method: 'POST',
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: '_csrf_token=' + encodeURIComponent(csrfToken) + '&content=' + encodeURIComponent(content)
  });
  const data = await res.json();
  if (data.success) {
    document.getElementById('postContent').value = '';
    document.getElementById('charCount').textContent = '0';
    location.reload();
  } else {
    alert(data.error || 'Failed to post.');
  }
});

// Likes
document.querySelectorAll('.like-btn').forEach(btn => {
  btn.addEventListener('click', async function() {
    const postId = this.dataset.post;
    const res = await fetch('/user/community/like', {
      method: 'POST',
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: '_csrf_token=' + encodeURIComponent(csrfToken) + '&post_id=' + postId
    });
    const data = await res.json();
    if (data.success) {
      const count = this.querySelector('.like-count');
      let n = parseInt(count.textContent);
      count.textContent = data.liked ? n + 1 : Math.max(0, n - 1);
      this.classList.toggle('text-primary', data.liked);
      this.classList.toggle('text-muted', !data.liked);
    }
  });
});
{/literal}
</script>
