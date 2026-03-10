{extends file="layouts/admin.tpl"}
{block name="content"}

<div class="row justify-content-center">
  <div class="col-lg-7">
    <div class="card">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-user-circle me-2 text-primary"></i>Admin Profile</h6>
      </div>
      <div class="card-body">
        <form method="POST" action="/admin/profile">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">

          <div class="mb-3">
            <label class="form-label fw-semibold">Username</label>
            <input type="text" name="username" class="form-control" value="{$admin.username|escape}" required>
          </div>

          <div class="mb-3">
            <label class="form-label fw-semibold">Email</label>
            <input type="email" name="email" class="form-control" value="{$admin.email|escape}" required>
          </div>

          <hr class="my-4">
          <p class="text-muted small mb-3">Leave the password fields blank to keep your current password.</p>

          <div class="mb-3">
            <label class="form-label fw-semibold">New Password</label>
            <input type="password" name="password" class="form-control" autocomplete="new-password">
          </div>

          <div class="mb-4">
            <label class="form-label fw-semibold">Confirm New Password</label>
            <input type="password" name="confirm_password" class="form-control" autocomplete="new-password">
          </div>

          <button type="submit" class="btn btn-accent px-4">
            <i class="fas fa-save me-1"></i> Save Changes
          </button>
        </form>
      </div>
    </div>
  </div>
</div>

{/block}
