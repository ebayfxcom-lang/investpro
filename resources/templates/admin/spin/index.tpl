{extends file="layouts/admin.tpl"}
{block name="content"}

<div class="row g-3 mb-4">
  <div class="col-sm-6 col-xl-3">
    <div class="stat-card">
      <div class="d-flex align-items-center justify-content-between">
        <div>
          <div class="text-muted small text-uppercase fw-semibold">Spin Status</div>
          <div class="h4 fw-bold mt-1 mb-0">
            {if $settings.enabled}<span class="text-success">Enabled</span>{else}<span class="text-danger">Disabled</span>{/if}
          </div>
        </div>
        <div class="stat-icon bg-warning bg-opacity-10 text-warning"><i class="fas fa-circle-notch"></i></div>
      </div>
    </div>
  </div>
  <div class="col-sm-6 col-xl-3">
    <div class="stat-card">
      <div class="d-flex align-items-center justify-content-between">
        <div>
          <div class="text-muted small text-uppercase fw-semibold">Spin Price</div>
          <div class="h4 fw-bold mt-1 mb-0">${$settings.spin_price|string_format:"%.2f"}</div>
        </div>
        <div class="stat-icon bg-success bg-opacity-10 text-success"><i class="fas fa-dollar-sign"></i></div>
      </div>
    </div>
  </div>
  <div class="col-sm-6 col-xl-3">
    <div class="stat-card">
      <div class="d-flex align-items-center justify-content-between">
        <div>
          <div class="text-muted small text-uppercase fw-semibold">Free Spins / Day</div>
          <div class="h4 fw-bold mt-1 mb-0">{$settings.daily_free_spins|default:0}</div>
        </div>
        <div class="stat-icon bg-info bg-opacity-10 text-info"><i class="fas fa-gift"></i></div>
      </div>
    </div>
  </div>
  <div class="col-sm-6 col-xl-3">
    <div class="stat-card">
      <div class="d-flex align-items-center justify-content-between">
        <div>
          <div class="text-muted small text-uppercase fw-semibold">Reward Slots</div>
          <div class="h4 fw-bold mt-1 mb-0">{$rewards|count}</div>
        </div>
        <div class="stat-icon bg-primary bg-opacity-10 text-primary"><i class="fas fa-list-ol"></i></div>
      </div>
    </div>
  </div>
</div>

<div class="row g-3 mb-4">
  <div class="col-lg-4">
    <div class="card h-100">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-sliders me-2 text-warning"></i>Spin Settings</h6>
      </div>
      <div class="card-body">
        <form method="POST" action="/admin/spin/settings">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">
          <input type="hidden" name="action" value="settings">

          <div class="mb-3">
            <label class="form-label fw-semibold">Spin Wheel Status</label>
            <div class="form-check form-switch">
              <input class="form-check-input" type="checkbox" role="switch"
                     id="spinEnabled" name="enabled" value="1"
                     {if $settings.enabled}checked{/if}>
              <label class="form-check-label" for="spinEnabled">
                Enable spin wheel feature
              </label>
            </div>
          </div>

          <div class="mb-3">
            <label for="spinPrice" class="form-label fw-semibold">Spin Price (USD)</label>
            <div class="input-group">
              <span class="input-group-text">$</span>
              <input type="number" class="form-control" id="spinPrice" name="spin_price"
                     step="0.01" min="0"
                     value="{$settings.spin_price|string_format:'%.2f'|default:'1.00'}">
            </div>
            <div class="form-text">Cost per paid spin. Set to 0 for free paid spins.</div>
          </div>

          <div class="mb-4">
            <label for="dailyFreeSpins" class="form-label fw-semibold">Daily Free Spins</label>
            <input type="number" class="form-control" id="dailyFreeSpins" name="daily_free_spins"
                   min="0" max="100"
                   value="{$settings.daily_free_spins|default:0}">
            <div class="form-text">Number of free spins each user receives per day. Set to 0 to disable.</div>
          </div>

          <button type="submit" class="btn btn-accent w-100">
            <i class="fas fa-save me-2"></i>Save Settings
          </button>
        </form>
      </div>
    </div>
  </div>

  <div class="col-lg-8">
    <div class="card h-100">
      <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
        <h6 class="mb-0 fw-bold"><i class="fas fa-trophy me-2 text-success"></i>Reward Slots</h6>
        <span class="badge bg-secondary">{$rewards|count} slots</span>
      </div>
      <div class="card-body p-0">
        <div class="table-responsive">
          <table class="table table-hover mb-0">
            <thead class="table-light">
              <tr>
                <th>Slot</th>
                <th>Label</th>
                <th>Type</th>
                <th>Applies To</th>
                <th>Value</th>
                <th>Probability</th>
                <th>Color</th>
                <th>Status</th>
                <th class="text-end">Action</th>
              </tr>
            </thead>
            <tbody>
              {if $rewards}
                {foreach $rewards as $reward}
                <tr>
                  <td class="fw-semibold">#{$reward.slot}</td>
                  <td>{$reward.label|escape}</td>
                  <td>
                    <span class="badge bg-secondary bg-opacity-25 text-dark">
                      {$reward.reward_type|replace:'_':' '|ucfirst}
                    </span>
                  </td>
                  <td>
                    <span class="badge {if $reward.spin_mode == 'free'}bg-success bg-opacity-25 text-success{elseif $reward.spin_mode == 'paid'}bg-info bg-opacity-25 text-info{else}bg-primary bg-opacity-25 text-primary{/if}">
                      {$reward.spin_mode|default:'both'|ucfirst}
                    </span>
                  </td>
                  <td class="font-monospace">
                    {if $reward.reward_type == 'cash'}
                      ${$reward.reward_value|string_format:"%.2f"}
                    {elseif $reward.reward_type == 'extra_spin'}
                      {$reward.reward_value} spin{if $reward.reward_value != 1}s{/if}
                    {else}
                      {$reward.reward_value|escape}
                    {/if}
                  </td>
                  <td>
                    <div class="d-flex align-items-center gap-2">
                      <div class="progress flex-grow-1" style="height:6px;">
                        <div class="progress-bar bg-warning" style="width:{$reward.probability}%"></div>
                      </div>
                      <span class="text-muted small" style="min-width:40px;">{$reward.probability}%</span>
                    </div>
                  </td>
                  <td>
                    <span class="d-inline-block rounded-circle border"
                          style="width:20px;height:20px;background:{$reward.color|escape};"></span>
                    <span class="text-muted small ms-1 font-monospace">{$reward.color|escape}</span>
                  </td>
                  <td>
                    <span class="badge badge-status-{$reward.status}">
                      {$reward.status|ucfirst}
                    </span>
                  </td>
                  <td class="text-end">
                    <button type="button" class="btn btn-sm btn-outline-primary"
                            data-bs-toggle="modal"
                            data-bs-target="#editRewardModal"
                            data-id="{$reward.id}"
                            data-slot="{$reward.slot}"
                            data-label="{$reward.label|escape:'html'}"
                            data-type="{$reward.reward_type}"
                            data-mode="{$reward.spin_mode|default:'both'}"
                            data-value="{$reward.reward_value}"
                            data-probability="{$reward.probability}"
                            data-color="{$reward.color|escape:'html'}"
                            data-status="{$reward.status}">
                      <i class="fas fa-edit"></i>
                    </button>
                  </td>
                </tr>
                {/foreach}
              {else}
                <tr><td colspan="8" class="text-center text-muted py-4">No reward slots configured.</td></tr>
              {/if}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>

<div class="card">
  <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
    <h6 class="mb-0 fw-bold"><i class="fas fa-history me-2 text-info"></i>Recent Spin History</h6>
    <a href="/admin/spin/history" class="btn btn-sm btn-outline-info">View All</a>
  </div>
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead class="table-light">
          <tr>
            <th>User</th>
            <th>Spin Type</th>
            <th>Reward Type</th>
            <th>Reward</th>
            <th>Date</th>
          </tr>
        </thead>
        <tbody>
          {if $history}
            {foreach $history as $h}
            <tr>
              <td>
                <div class="d-flex align-items-center gap-2">
                  <div class="bg-primary bg-opacity-10 text-primary rounded-circle d-flex align-items-center justify-content-center"
                       style="width:28px;height:28px;font-size:.75rem;font-weight:700;">
                    {$h.username|upper|truncate:1:''}
                  </div>
                  <span class="fw-semibold">{$h.username|escape}</span>
                </div>
              </td>
              <td>
                <span class="badge {if $h.spin_type == 'free'}bg-success bg-opacity-25 text-success{else}bg-info bg-opacity-25 text-info{/if}">
                  {$h.spin_type|ucfirst}
                </span>
              </td>
              <td>
                <span class="badge bg-secondary bg-opacity-25 text-dark">
                  {$h.reward_type|replace:'_':' '|ucfirst}
                </span>
              </td>
              <td class="fw-semibold">
                {if $h.reward_label}{$h.reward_label|escape}{else}{$h.reward_value|escape}{/if}
              </td>
              <td class="text-muted small">{$h.created_at|date_format:'%b %d, %Y %H:%M'}</td>
            </tr>
            {/foreach}
          {else}
            <tr><td colspan="5" class="text-center text-muted py-4">No spin history yet.</td></tr>
          {/if}
        </tbody>
      </table>
    </div>
  </div>
</div>

<!-- Edit Reward Modal -->
<div class="modal fade" id="editRewardModal" tabindex="-1" aria-labelledby="editRewardModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <form method="POST" action="/admin/spin">
        <input type="hidden" name="_csrf_token" value="{$csrf_token}">
        <input type="hidden" name="action" value="update_reward">
        <input type="hidden" name="reward_id" id="editRewardId">
        <div class="modal-header">
          <h5 class="modal-title fw-bold" id="editRewardModalLabel">
            <i class="fas fa-edit me-2 text-primary"></i>Edit Reward Slot #<span id="editSlotNumber"></span>
          </h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label for="editLabel" class="form-label fw-semibold">Label</label>
            <input type="text" class="form-control" id="editLabel" name="label" required maxlength="100">
          </div>
          <div class="mb-3">
            <label for="editSpinMode" class="form-label fw-semibold">Applies To</label>
            <select class="form-select" id="editSpinMode" name="spin_mode">
              <option value="both">Both (Free &amp; Paid)</option>
              <option value="free">Free Spins Only</option>
              <option value="paid">Paid Spins Only</option>
            </select>
            <div class="form-text">Configure which type of spin can land on this reward.</div>
          </div>
          <div class="mb-3">
            <label for="editRewardType" class="form-label fw-semibold">Reward Type</label>
            <select class="form-select" id="editRewardType" name="reward_type" required>
              <option value="usd">USD Cash</option>
              <option value="points">Points</option>
              <option value="spin_credits">Spin Credits</option>
              <option value="percent_bonus">% Bonus</option>
              <option value="bonus">Bonus</option>
              <option value="no_reward">No Reward</option>
            </select>
          </div>
          <div class="mb-3">
            <label for="editRewardValue" class="form-label fw-semibold">Reward Value</label>
            <input type="text" class="form-control" id="editRewardValue" name="reward_value" required>
            <div class="form-text">For cash: enter amount in USD. For spin credits: number of spins.</div>
          </div>
          <div class="mb-3">
            <label for="editProbability" class="form-label fw-semibold">Probability (%)</label>
            <input type="number" class="form-control" id="editProbability" name="probability"
                   min="0" max="100" step="0.01" required>
            <div class="form-text">Sum of all probabilities should equal 100%.</div>
          </div>
          <div class="mb-3">
            <label for="editColor" class="form-label fw-semibold">Segment Color</label>
            <div class="input-group">
              <input type="color" class="form-control form-control-color" id="editColorPicker"
                     style="width:50px;" title="Pick a color">
              <input type="text" class="form-control font-monospace" id="editColor" name="color"
                     maxlength="20" placeholder="#f59e0b">
            </div>
          </div>
          <div class="mb-3">
            <label for="editStatus" class="form-label fw-semibold">Status</label>
            <select class="form-select" id="editStatus" name="status" required>
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
            </select>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
          <button type="submit" class="btn btn-accent">
            <i class="fas fa-save me-1"></i>Save Changes
          </button>
        </div>
      </form>
    </div>
  </div>
</div>

<script>
(function () {
  const modal = document.getElementById('editRewardModal');
  modal.addEventListener('show.bs.modal', function (event) {
    const btn = event.relatedTarget;
    document.getElementById('editRewardId').value         = btn.dataset.id;
    document.getElementById('editSlotNumber').textContent  = btn.dataset.slot;
    document.getElementById('editLabel').value            = btn.dataset.label;
    document.getElementById('editSpinMode').value         = btn.dataset.mode || 'both';
    document.getElementById('editRewardType').value       = btn.dataset.type;
    document.getElementById('editRewardValue').value      = btn.dataset.value;
    document.getElementById('editProbability').value      = btn.dataset.probability;
    document.getElementById('editColor').value            = btn.dataset.color;
    document.getElementById('editColorPicker').value      = btn.dataset.color;
    document.getElementById('editStatus').value           = btn.dataset.status;
  });

  const colorPicker = document.getElementById('editColorPicker');
  const colorText   = document.getElementById('editColor');
  colorPicker.addEventListener('input', () => { colorText.value = colorPicker.value; });
  colorText.addEventListener('input', () => {
    if (/^#[0-9a-fA-F]{6}$/.test(colorText.value)) {
      colorPicker.value = colorText.value;
    }
  });
}());
</script>

{/block}
