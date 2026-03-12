{extends file="layouts/auth.tpl"}
{block name="content"}
<div class="auth-card mx-auto">
  <div class="auth-logo">
    <a href="/">{$app.name}</a>
    <div class="tagline text-muted mt-1">Stay Updated</div>
  </div>

  {if $flash.success}
  <div class="alert alert-success rounded-3 mb-3">
    <i class="fas fa-check-circle me-2"></i>{$flash.success}
  </div>
  {/if}
  {if $flash.error}
  <div class="alert alert-danger rounded-3 mb-3">
    <i class="fas fa-exclamation-circle me-2"></i>{$flash.error}
  </div>
  {/if}

  {if !$subscribed}
  <h5 class="fw-bold mb-1 text-center">Subscribe to Our Newsletter</h5>
  <p class="text-muted text-center small mb-4">Get the latest updates, news and platform announcements.</p>
  <form method="POST" action="/newsletter/subscribe">
    <input type="hidden" name="_csrf_token" value="{$csrf_token}">
    <div class="mb-3">
      <label class="form-label fw-semibold">Email Address <span class="text-danger">*</span></label>
      <input type="email" name="email" class="form-control" placeholder="you@example.com" required autofocus>
    </div>
    <div class="mb-4">
      <label class="form-label fw-semibold">WhatsApp Number <span class="text-muted small">(optional)</span></label>
      <input type="tel" name="whatsapp" class="form-control" placeholder="+1 234 567 8900">
    </div>
    <button type="submit" class="btn btn-primary w-100">
      <i class="fas fa-envelope me-2"></i>Subscribe
    </button>
  </form>
  {else}
  <div class="text-center py-3">
    <i class="fas fa-check-circle text-success fa-3x mb-3"></i>
    <h5 class="fw-bold">You're subscribed!</h5>
    <p class="text-muted">Thank you for subscribing to our newsletter.</p>
    <a href="/" class="btn btn-outline-primary mt-2">Back to Home</a>
  </div>
  {/if}
</div>
{/block}
