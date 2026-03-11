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
    <form method="POST" action="/admin/settings/referral">
      <input type="hidden" name="_csrf_token" value="{$csrf_token}">

      {* Basic referral settings *}
      <div class="card mb-3">
        <div class="card-header bg-white py-3">
          <h6 class="mb-0 fw-bold"><i class="fas fa-percent me-2 text-warning"></i>Referral Settings</h6>
        </div>
        <div class="card-body">
          <div class="row g-3">
            <div class="col-md-4">
              <label class="form-label fw-semibold">Number of Referral Levels</label>
              <select name="referral_levels" class="form-select">
                <option value="1" {if ($settings.referral_levels|default:1) == 1}selected{/if}>1 Level</option>
                <option value="2" {if ($settings.referral_levels|default:1) == 2}selected{/if}>2 Levels</option>
                <option value="3" {if ($settings.referral_levels|default:1) == 3}selected{/if}>3 Levels</option>
              </select>
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Award Commission On</label>
              <select name="referral_on_deposit" class="form-select">
                <option value="1" {if $settings.referral_on_deposit}selected{/if}>Each Deposit</option>
                <option value="0" {if !$settings.referral_on_deposit && isset($settings.referral_on_deposit)}selected{/if}>First Deposit Only</option>
              </select>
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Commission Mode</label>
              <select name="referral_threshold_mode" class="form-select" id="thresholdMode">
                <option value="flat"    {if ($settings.referral_threshold_mode|default:'flat') == 'flat'}selected{/if}>Flat Rate (Fixed %)</option>
                <option value="count"   {if ($settings.referral_threshold_mode|default:'flat') == 'count'}selected{/if}>By Downline Count</option>
                <option value="deposit" {if ($settings.referral_threshold_mode|default:'flat') == 'deposit'}selected{/if}>By Deposit Volume ($)</option>
              </select>
            </div>
          </div>
        </div>
      </div>

      {* Flat rate section *}
      <div class="card mb-3" id="flatSection">
        <div class="card-header bg-white py-3">
          <h6 class="mb-0 fw-bold"><i class="fas fa-layer-group me-2 text-info"></i>Flat Commission Rates</h6>
        </div>
        <div class="card-body">
          <div class="row g-3">
            <div class="col-md-4">
              <label class="form-label fw-semibold">Level 1 Commission (%)</label>
              <input type="number" name="referral_percent" class="form-control" step="0.01" min="0"
                     value="{$settings.referral_percent|default:5}">
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Level 2 Commission (%)</label>
              <input type="number" name="referral_level2" class="form-control" step="0.01" min="0"
                     value="{$settings.referral_level2|default:0}">
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Level 3 Commission (%)</label>
              <input type="number" name="referral_level3" class="form-control" step="0.01" min="0"
                     value="{$settings.referral_level3|default:0}">
            </div>
          </div>
        </div>
      </div>

      {* Threshold-based section *}
      <div class="card mb-3" id="thresholdSection" style="display:none">
        <div class="card-header bg-white py-3">
          <h6 class="mb-0 fw-bold"><i class="fas fa-sliders me-2 text-primary"></i>Threshold-Based Commission Tiers</h6>
        </div>
        <div class="card-body">
          <div class="alert alert-info small mb-3">
            <i class="fas fa-info-circle me-1"></i>
            Define 3 tiers per level. The tier with the highest threshold that the user meets will apply.
            <span id="thresholdModeHint">In <strong>Count</strong> mode, thresholds are based on number of active downlines.</span>
          </div>

          {* Level 1 Thresholds *}
          <h6 class="fw-semibold text-primary mb-2">Level 1 Tiers</h6>
          <div class="table-responsive mb-4">
            <table class="table table-bordered align-middle mb-0">
              <thead class="table-light">
                <tr>
                  <th>Tier</th>
                  <th><span id="thresholdLabel1">Min Downlines</span></th>
                  <th>Commission (%)</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td class="fw-semibold">Tier 1 (base)</td>
                  <td><input type="number" name="referral_l1_threshold1_count" class="form-control form-control-sm"
                             value="{$settings.referral_l1_threshold1_count|default:0}" min="0" placeholder="0"></td>
                  <td><input type="number" name="referral_l1_threshold1_rate" class="form-control form-control-sm"
                             value="{$settings.referral_l1_threshold1_rate|default:5}" step="0.01" min="0"></td>
                </tr>
                <tr>
                  <td class="fw-semibold">Tier 2</td>
                  <td><input type="number" name="referral_l1_threshold2_count" class="form-control form-control-sm"
                             value="{$settings.referral_l1_threshold2_count|default:10}" min="0"></td>
                  <td><input type="number" name="referral_l1_threshold2_rate" class="form-control form-control-sm"
                             value="{$settings.referral_l1_threshold2_rate|default:7}" step="0.01" min="0"></td>
                </tr>
                <tr>
                  <td class="fw-semibold">Tier 3</td>
                  <td><input type="number" name="referral_l1_threshold3_count" class="form-control form-control-sm"
                             value="{$settings.referral_l1_threshold3_count|default:25}" min="0"></td>
                  <td><input type="number" name="referral_l1_threshold3_rate" class="form-control form-control-sm"
                             value="{$settings.referral_l1_threshold3_rate|default:10}" step="0.01" min="0"></td>
                </tr>
              </tbody>
            </table>
          </div>

          {* Level 2 Thresholds *}
          <h6 class="fw-semibold text-success mb-2">Level 2 Tiers</h6>
          <p class="text-muted small mb-2">Level 2 uses the same threshold breakpoints as Level 1. Rates below apply to Level 2 downlines.</p>
          <div class="table-responsive mb-4">
            <table class="table table-bordered align-middle mb-0">
              <thead class="table-light">
                <tr>
                  <th>Tier</th>
                  <th><span id="thresholdLabel2">Same as Level 1</span></th>
                  <th>Commission (%)</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>Tier 1 (base)</td>
                  <td class="text-muted small">Same as L1 Tier 1 threshold</td>
                  <td><input type="number" name="referral_l2_threshold1_rate" class="form-control form-control-sm"
                             value="{$settings.referral_l2_threshold1_rate|default:2}" step="0.01" min="0"></td>
                </tr>
                <tr>
                  <td>Tier 2</td>
                  <td class="text-muted small">Same as L1 Tier 2 threshold</td>
                  <td><input type="number" name="referral_l2_threshold2_rate" class="form-control form-control-sm"
                             value="{$settings.referral_l2_threshold2_rate|default:3}" step="0.01" min="0"></td>
                </tr>
                <tr>
                  <td>Tier 3</td>
                  <td class="text-muted small">Same as L1 Tier 3 threshold</td>
                  <td><input type="number" name="referral_l2_threshold3_rate" class="form-control form-control-sm"
                             value="{$settings.referral_l2_threshold3_rate|default:5}" step="0.01" min="0"></td>
                </tr>
              </tbody>
            </table>
          </div>

          {* Level 3 Thresholds *}
          <h6 class="fw-semibold text-warning mb-2">Level 3 Tiers</h6>
          <p class="text-muted small mb-2">Level 3 uses the same threshold breakpoints as Level 1.</p>
          <div class="table-responsive">
            <table class="table table-bordered align-middle mb-0">
              <thead class="table-light">
                <tr>
                  <th>Tier</th>
                  <th><span id="thresholdLabel3">Same as Level 1</span></th>
                  <th>Commission (%)</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>Tier 1 (base)</td>
                  <td class="text-muted small">Same as L1 Tier 1 threshold</td>
                  <td><input type="number" name="referral_l3_threshold1_rate" class="form-control form-control-sm"
                             value="{$settings.referral_l3_threshold1_rate|default:1}" step="0.01" min="0"></td>
                </tr>
                <tr>
                  <td>Tier 2</td>
                  <td class="text-muted small">Same as L1 Tier 2 threshold</td>
                  <td><input type="number" name="referral_l3_threshold2_rate" class="form-control form-control-sm"
                             value="{$settings.referral_l3_threshold2_rate|default:1.5}" step="0.01" min="0"></td>
                </tr>
                <tr>
                  <td>Tier 3</td>
                  <td class="text-muted small">Same as L1 Tier 3 threshold</td>
                  <td><input type="number" name="referral_l3_threshold3_rate" class="form-control form-control-sm"
                             value="{$settings.referral_l3_threshold3_rate|default:2}" step="0.01" min="0"></td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div class="mt-2">
        <button type="submit" class="btn btn-accent"><i class="fas fa-save me-2"></i>Save Referral Settings</button>
      </div>
    </form>
  </div>
</div>

<script>
(function () {
  const modeSelect = document.getElementById('thresholdMode');
  const flatSection      = document.getElementById('flatSection');
  const thresholdSection = document.getElementById('thresholdSection');
  const thresholdLabel1  = document.getElementById('thresholdLabel1');
  const thresholdHint    = document.getElementById('thresholdModeHint');

  function updateUI() {
    const mode = modeSelect.value;
    if (mode === 'flat') {
      flatSection.style.display      = '';
      thresholdSection.style.display = 'none';
    } else {
      flatSection.style.display      = 'none';
      thresholdSection.style.display = '';
      if (mode === 'count') {
        thresholdLabel1.textContent = 'Min Downlines';
        thresholdHint.innerHTML     = 'In <strong>Count</strong> mode, tiers are based on the number of active direct downlines.';
      } else {
        thresholdLabel1.textContent = 'Min Deposit Volume ($)';
        thresholdHint.innerHTML     = 'In <strong>Deposit Volume</strong> mode, tiers are based on cumulative deposit amount of downlines.';
      }
    }
  }

  modeSelect.addEventListener('change', updateUI);
  updateUI();
}());
</script>
{/block}

