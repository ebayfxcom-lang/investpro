{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="row g-3">
  <div class="col-md-3">
    <div class="card">
      <div class="card-body p-0">
        <div class="list-group list-group-flush">
          <a href="/admin/settings" class="list-group-item list-group-item-action active fw-semibold"><i class="fas fa-cog me-2"></i>General</a>
          <a href="/admin/settings/referral" class="list-group-item list-group-item-action"><i class="fas fa-percent me-2"></i>Referral</a>
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
        <h6 class="mb-0 fw-bold"><i class="fas fa-cog me-2 text-primary"></i>General Settings</h6>
      </div>
      <div class="card-body">
        <form method="POST" action="/admin/settings">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">
          <div class="row g-3">
            <div class="col-md-6">
              <label class="form-label fw-semibold">Site Name</label>
              <input type="text" name="site_name" class="form-control" value="{$settings.site_name|default:'InvestPro'|escape}">
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Site Email</label>
              <input type="email" name="site_email" class="form-control" value="{$settings.site_email|default:''|escape}">
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Site URL</label>
              <input type="url" name="site_url" class="form-control" value="{$settings.site_url|default:''|escape}">
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Default Currency</label>
              <select name="currency" class="form-select">
                <option value="USD" {if $settings.currency == 'USD'}selected{/if}>USD - US Dollar</option>
                <option value="EUR" {if $settings.currency == 'EUR'}selected{/if}>EUR - Euro</option>
              </select>
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Min Deposit ($)</label>
              <input type="number" name="min_deposit" class="form-control" step="0.01" value="{$settings.min_deposit|default:10}">
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Min Withdrawal ($)</label>
              <input type="number" name="min_withdrawal" class="form-control" step="0.01" value="{$settings.min_withdrawal|default:10}">
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Withdrawal Fee ($)</label>
              <input type="number" name="withdrawal_fee" class="form-control" step="0.01" value="{$settings.withdrawal_fee|default:0}">
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Registration</label>
              <select name="registration_enabled" class="form-select">
                <option value="1" {if $settings.registration_enabled}selected{/if}>Enabled</option>
                <option value="0" {if !$settings.registration_enabled}selected{/if}>Disabled</option>
              </select>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Maintenance Mode</label>
              <select name="maintenance_mode" class="form-select">
                <option value="0" {if !$settings.maintenance_mode}selected{/if}>Off</option>
                <option value="1" {if $settings.maintenance_mode}selected{/if}>On</option>
              </select>
            </div>
            <div class="col-12">
              <label class="form-label fw-semibold">Maintenance Message</label>
              <textarea name="maintenance_message" class="form-control" rows="2">{$settings.maintenance_message|escape}</textarea>
            </div>
          </div>
          <div class="mt-4">
            <button type="submit" class="btn btn-accent"><i class="fas fa-save me-2"></i>Save Settings</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>
{/block}
