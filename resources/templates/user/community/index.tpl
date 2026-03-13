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
        <button class="btn btn-link btn-sm text-muted p-0 comment-toggle-btn"
                data-bs-toggle="collapse" data-bs-target="#comments-{$post.id}">
          <i class="fas fa-comment me-1"></i>
          <span class="comment-count-{$post.id}">{$post.comment_count}</span>
          comment{if $post.comment_count != 1}s{/if}
        </button>
      </div>
    </div>
    <div class="collapse" id="comments-{$post.id}">
      <div class="card-footer bg-transparent pt-0">
        <div class="comment-list-{$post.id} mb-2">
          {if isset($post.comments) && $post.comments}
          {foreach $post.comments as $c}
          <div class="d-flex gap-2 mb-2 align-items-start">
            <div class="bg-secondary bg-opacity-10 rounded-circle d-flex align-items-center justify-content-center flex-shrink-0"
                 style="width:28px;height:28px;font-size:.7rem;font-weight:700">
              {$c.username|upper|truncate:1:'':''}
            </div>
            <div class="bg-light rounded px-2 py-1 flex-grow-1" style="background:rgba(255,255,255,.05)!important">
              <div class="fw-semibold" style="font-size:.75rem">{$c.username|escape}</div>
              <div style="font-size:.85rem">{$c.content|escape}</div>
            </div>
          </div>
          {/foreach}
          {/if}
        </div>
        <form class="comment-form d-flex gap-2" data-post="{$post.id}">
          <input type="text" class="form-control form-control-sm" placeholder="Write a comment..."
                 maxlength="500" required>
          <button type="submit" class="btn btn-primary btn-sm text-nowrap">Post</button>
        </form>
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
  const btn = this.querySelector('[type=submit]');
  btn.disabled = true;
  const res = await fetch('/user/community/post', {
    method: 'POST',
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: '_csrf_token=' + encodeURIComponent(csrfToken) + '&content=' + encodeURIComponent(content)
  });
  const data = await res.json();
  btn.disabled = false;
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

// Comments
document.querySelectorAll('.comment-form').forEach(form => {
  form.addEventListener('submit', async function(e) {
    e.preventDefault();
    const postId = this.dataset.post;
    const input = this.querySelector('input');
    const content = input.value.trim();
    if (!content) return;
    const btn = this.querySelector('[type=submit]');
    btn.disabled = true;
    try {
    const res = await fetch('/user/community/comment', {
      method: 'POST',
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: '_csrf_token=' + encodeURIComponent(csrfToken) + '&post_id=' + postId + '&content=' + encodeURIComponent(content)
    });
    const data = await res.json();
    btn.disabled = false;
    if (data.success) {
      input.value = '';
      // Append new comment to the list
      const list = document.querySelector('.comment-list-' + postId);
      const div = document.createElement('div');
      div.className = 'd-flex gap-2 mb-2 align-items-start';
      const avatar = document.createElement('div');
      avatar.className = 'bg-secondary bg-opacity-10 rounded-circle d-flex align-items-center justify-content-center flex-shrink-0';
      avatar.style.cssText = 'width:28px;height:28px;font-size:.7rem;font-weight:700';
      avatar.textContent = 'You';
      const bubble = document.createElement('div');
      bubble.className = 'bg-light rounded px-2 py-1 flex-grow-1';
      bubble.style.cssText = 'background:rgba(255,255,255,.05)!important';
      const name = document.createElement('div');
      name.className = 'fw-semibold';
      name.style.fontSize = '.75rem';
      name.textContent = 'You';
      const text = document.createElement('div');
      text.style.fontSize = '.85rem';
      text.textContent = data.content || content;
      bubble.appendChild(name);
      bubble.appendChild(text);
      div.appendChild(avatar);
      div.appendChild(bubble);
      list.appendChild(div);
      // Update comment count
      const counter = document.querySelector('.comment-count-' + postId);
      if (counter) counter.textContent = parseInt(counter.textContent || '0') + 1;
    } else {
      alert(data.error || 'Failed to comment.');
    }
    } catch (err) {
      btn.disabled = false;
      alert('Network error. Please try again.');
    }
  });
});
{/literal}
</script>
