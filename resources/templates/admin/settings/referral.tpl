{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="row g-3">
  <div class="col-md-3">
    <div class="card">
      <div class="card-body p-0">
        <div class="list-group list-group-flush">
          <a href="/admin/settings" class="list-group-item list-group-item-action"><i class="fas fa-cog me-2"></i>General</a>
          <a href="/admin/settings/referral" class="list-group-item list-group-item-action active fw-semibold"><i class="fas fa-percent me-2"></i>Referral</a>
          <a href="/admin/settings/currencies" class="list-group-item list-group-item-action"><i class="fas fa-dollar-sign me-2"></i>Currencies</a>
          <a href="/admin/settings/email-templates" class="list-group-item list-group-item-action"><i class="fas fa-envelope me-2"></i>Email Templates</a>
          <a href="/admin/settings/security" class="list-group-item list-group-item-action"><i class="fas fa-shield me-2"></i>Security</a>
        </div>
      </div>
    </div>
  </div>
  <div class="col-md-9">
    <div class="card">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-percent me-2 text-warning"></i>Referral Settings</h6>
      </div>
      <div class="card-body">
        <form method="POST" action="/admin/settings/referral">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">
          <div class="row g-3">
            <div class="col-md-6">
              <label class="form-label fw-semibold">Level 1 Commission (%)</label>
              <input type="number" name="referral_percent" class="form-control" step="0.01" value="{$settings.referral_percent|default:5}">
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Number of Referral Levels</label>
              <select name="referral_levels" class="form-select">
                <option value="1" {if $settings.referral_levels == 1}selected{/if}>1 Level</option>
                <option value="2" {if $settings.referral_levels == 2}selected{/if}>2 Levels</option>
                <option value="3" {if $settings.referral_levels == 3}selected{/if}>3 Levels</option>
              </select>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Level 2 Commission (%)</label>
              <input type="number" name="referral_level2" class="form-control" step="0.01" value="{$settings.referral_level2|default:0}">
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Level 3 Commission (%)</label>
              <input type="number" name="referral_level3" class="form-control" step="0.01" value="{$settings.referral_level3|default:0}">
            </div>
            <div class="col-12">
              <label class="form-label fw-semibold">Award Commission On</label>
              <select name="referral_on_deposit" class="form-select">
                <option value="1" {if $settings.referral_on_deposit}selected{/if}>Each Deposit</option>
                <option value="0" {if !$settings.referral_on_deposit}selected{/if}>First Deposit Only</option>
              </select>
            </div>
          </div>
          <div class="mt-4">
            <button type="submit" class="btn btn-accent"><i class="fas fa-save me-2"></i>Save Referral Settings</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>
{/block}
