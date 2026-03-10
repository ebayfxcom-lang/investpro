{extends file="layouts/auth.tpl"}
{block name="content"}
<h4 class="fw-bold mb-1">Create Account</h4>
<p class="text-muted small mb-4">Join thousands of investors worldwide</p>

<form method="POST" action="/register">
  <input type="hidden" name="_csrf_token" value="{$csrf_token}">

  <div class="mb-3">
    <label class="form-label fw-semibold">Username</label>
    <input type="text" name="username" class="form-control" placeholder="Choose a username" required>
  </div>

  <div class="mb-3">
    <label class="form-label fw-semibold">Email Address</label>
    <input type="email" name="email" class="form-control" placeholder="you@example.com" required>
  </div>

  <div class="mb-3">
    <label class="form-label fw-semibold">Password</label>
    <input type="password" name="password" class="form-control" placeholder="Min. 8 characters" required minlength="8">
  </div>

  <div class="mb-3">
    <label class="form-label fw-semibold">Confirm Password</label>
    <input type="password" name="password_confirm" class="form-control" placeholder="Repeat password" required>
  </div>

  {if $ref}
  <input type="hidden" name="ref" value="{$ref|escape}">
  <div class="alert alert-info small py-2">
    <i class="fas fa-user-plus me-1"></i> You were referred by a member (code: {$ref|escape})
  </div>
  {/if}

  <button type="submit" class="btn btn-primary w-100 mb-3">
    <i class="fas fa-user-plus me-2"></i>Create Account
  </button>

  <div class="text-center text-muted small">
    Already have an account? <a href="/login" class="text-primary fw-semibold">Sign in</a>
  </div>
</form>
{/block}
