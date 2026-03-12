{extends file="layouts/auth.tpl"}
{block name="content"}
<div class="auth-card mx-auto">
  <div class="auth-logo">
    <a href="/">{$app.name}</a>
  </div>
  <div class="text-center py-3">
    {if $success}
    <i class="fas fa-check-circle text-success fa-3x mb-3"></i>
    <h5 class="fw-bold">Unsubscribed</h5>
    <p class="text-muted">You have been successfully removed from our mailing list.</p>
    {else}
    <i class="fas fa-exclamation-circle text-warning fa-3x mb-3"></i>
    <h5 class="fw-bold">Invalid Link</h5>
    <p class="text-muted">This unsubscribe link is invalid or has already been used.</p>
    {/if}
    <a href="/" class="btn btn-outline-primary mt-2">Back to Home</a>
  </div>
</div>
{/block}
