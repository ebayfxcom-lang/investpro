{extends file="layouts/user.tpl"}
{block name="content"}
<div class="row justify-content-center">
  <div class="col-lg-7">
    <div class="card">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-user-cog me-2 text-primary"></i>Account Settings</h6>
      </div>
      <div class="card-body">
        <form method="POST" action="/user/settings">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">

          <div class="row g-3">
            <div class="col-md-6">
              <label class="form-label fw-semibold">First Name</label>
              <input type="text" name="first_name" class="form-control" value="{$user.first_name|escape}">
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Last Name</label>
              <input type="text" name="last_name" class="form-control" value="{$user.last_name|escape}">
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Username</label>
              <input type="text" class="form-control" value="{$user.username|escape}" disabled>
              <div class="form-text">Username cannot be changed</div>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Email</label>
              <input type="email" class="form-control" value="{$user.email|escape}" disabled>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Phone</label>
              <input type="tel" name="phone" class="form-control" value="{$user.phone|escape}">
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Country</label>
              <input type="text" name="country" class="form-control" value="{$user.country|escape}" placeholder="Your country">
            </div>
          </div>

          <div class="mt-4">
            <button type="submit" class="btn btn-primary"><i class="fas fa-save me-2"></i>Save Changes</button>
          </div>
        </form>
      </div>
    </div>

    <div class="card mt-3">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold text-muted"><i class="fas fa-share-nodes me-2"></i>Referral Code</h6>
      </div>
      <div class="card-body">
        <div class="d-flex align-items-center gap-3">
          <code class="bg-light p-2 rounded fs-6">{$user.referral_code}</code>
          <a href="/user/referrals" class="btn btn-outline-warning btn-sm">View Referral Dashboard</a>
        </div>
      </div>
    </div>
  </div>
</div>
{/block}
