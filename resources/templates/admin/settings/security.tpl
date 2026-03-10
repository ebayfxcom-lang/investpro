{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="row g-3">
  <div class="col-md-3">
    <div class="card">
      <div class="card-body p-0">
        <div class="list-group list-group-flush">
          <a href="/admin/settings" class="list-group-item list-group-item-action"><i class="fas fa-cog me-2"></i>General</a>
          <a href="/admin/settings/referral" class="list-group-item list-group-item-action"><i class="fas fa-percent me-2"></i>Referral</a>
          <a href="/admin/settings/currencies" class="list-group-item list-group-item-action"><i class="fas fa-dollar-sign me-2"></i>Currencies</a>
          <a href="/admin/settings/email-templates" class="list-group-item list-group-item-action"><i class="fas fa-envelope me-2"></i>Email Templates</a>
          <a href="/admin/settings/security" class="list-group-item list-group-item-action active fw-semibold"><i class="fas fa-shield me-2"></i>Security</a>
        </div>
      </div>
    </div>
  </div>
  <div class="col-md-9">
    <div class="card">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-shield-halved me-2 text-danger"></i>Security Settings</h6>
      </div>
      <div class="card-body">
        <form method="POST" action="/admin/settings/security">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">
          <div class="row g-3">
            <div class="col-md-6">
              <label class="form-label fw-semibold">Two-Factor Authentication</label>
              <select name="two_factor_enabled" class="form-select">
                <option value="0" {if !($settings.two_factor_enabled|default:0)}selected{/if}>Disabled</option>
                <option value="1" {if $settings.two_factor_enabled|default:0}selected{/if}>Enabled</option>
              </select>
              <div class="form-text">Require 2FA for all admin logins.</div>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Email Verification</label>
              <select name="email_verification" class="form-select">
                <option value="0" {if !($settings.email_verification|default:0)}selected{/if}>Not Required</option>
                <option value="1" {if $settings.email_verification|default:0}selected{/if}>Required</option>
              </select>
              <div class="form-text">Require email verification on registration.</div>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">New User Registration</label>
              <select name="registration_enabled" class="form-select">
                <option value="1" {if ($settings.registration_enabled|default:1)}selected{/if}>Open</option>
                <option value="0" {if !($settings.registration_enabled|default:1)}selected{/if}>Closed</option>
              </select>
              <div class="form-text">Allow new users to register.</div>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Maintenance Mode</label>
              <select name="maintenance_mode" class="form-select">
                <option value="0" {if !($settings.maintenance_mode|default:0)}selected{/if}>Off</option>
                <option value="1" {if $settings.maintenance_mode|default:0}selected{/if}>On</option>
              </select>
              <div class="form-text">Puts the site in maintenance mode for non-admins.</div>
            </div>
            <div class="col-12">
              <label class="form-label fw-semibold">Maintenance Message</label>
              <textarea name="maintenance_message" class="form-control" rows="2"
                placeholder="We'll be back shortly...">{$settings.maintenance_message|default:'We are currently performing maintenance. Please check back later.'|escape}</textarea>
            </div>
            <div class="col-12">
              <button type="submit" class="btn btn-accent">
                <i class="fas fa-save me-1"></i> Save Security Settings
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>
{/block}
