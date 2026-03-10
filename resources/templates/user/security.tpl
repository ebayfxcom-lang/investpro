{extends file="layouts/user.tpl"}
{block name="content"}
<div class="row justify-content-center">
  <div class="col-lg-6">
    <div class="card">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-shield-halved me-2 text-danger"></i>Change Password</h6>
      </div>
      <div class="card-body">
        <form method="POST" action="/user/security">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">

          <div class="mb-3">
            <label class="form-label fw-semibold">Current Password <span class="text-danger">*</span></label>
            <input type="password" name="current_password" class="form-control" required>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">New Password <span class="text-danger">*</span></label>
            <input type="password" name="new_password" class="form-control" minlength="8" required>
            <div class="form-text">Minimum 8 characters.</div>
          </div>
          <div class="mb-4">
            <label class="form-label fw-semibold">Confirm New Password <span class="text-danger">*</span></label>
            <input type="password" name="confirm_password" class="form-control" required>
          </div>

          <button type="submit" class="btn btn-danger w-100">
            <i class="fas fa-key me-2"></i>Change Password
          </button>
        </form>
      </div>
    </div>

    <div class="card mt-3">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-info-circle me-2 text-info"></i>Security Tips</h6>
      </div>
      <div class="card-body">
        <ul class="list-unstyled mb-0">
          <li class="mb-2"><i class="fas fa-check-circle text-success me-2"></i>Use a unique, strong password (12+ characters)</li>
          <li class="mb-2"><i class="fas fa-check-circle text-success me-2"></i>Include uppercase, lowercase, numbers and symbols</li>
          <li class="mb-2"><i class="fas fa-check-circle text-success me-2"></i>Never share your password with anyone</li>
          <li><i class="fas fa-check-circle text-success me-2"></i>Change your password regularly</li>
        </ul>
      </div>
    </div>
  </div>
</div>
{/block}
