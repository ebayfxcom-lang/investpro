{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="row g-3">
  <div class="col-lg-5">
    <div class="card">
      <div class="card-header py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-gift me-2 text-warning"></i>Create Offer</h6>
      </div>
      <div class="card-body">
        <form method="POST" action="/admin/rewards">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">
          <input type="hidden" name="action" value="create_offer">
          <div class="mb-2">
            <label class="form-label fw-semibold small">Title</label>
            <input type="text" name="title" class="form-control form-control-sm" required maxlength="200">
          </div>
          <div class="mb-2">
            <label class="form-label fw-semibold small">Description</label>
            <textarea name="description" class="form-control form-control-sm" rows="2" maxlength="500"></textarea>
          </div>
          <div class="row g-2 mb-2">
            <div class="col">
              <label class="form-label fw-semibold small">Reward Type</label>
              <select name="reward_type" class="form-select form-select-sm">
                <option value="balance_credit">Balance Credit (USD)</option>
                <option value="spin_credits">Spin Credits</option>
                <option value="bonus_percent">Bonus %</option>
              </select>
            </div>
            <div class="col">
              <label class="form-label fw-semibold small">Reward Value</label>
              <input type="number" name="reward_value" class="form-control form-control-sm" step="0.01" min="0" required>
            </div>
          </div>
          <div class="row g-2 mb-2">
            <div class="col">
              <label class="form-label fw-semibold small">Eligibility Rule</label>
              <select name="eligibility_rule" class="form-select form-select-sm">
                <option value="first_deposit">First Deposit</option>
                <option value="invest_plan">Invest in Plan</option>
                <option value="complete_deposits">Complete X Deposits</option>
                <option value="refer_users">Refer X Users</option>
                <option value="buy_spins">Buy Spins</option>
                <option value="daily_login">Daily Login Streak</option>
                <option value="earn_spin_rewards">Earn Spin Rewards</option>
              </select>
            </div>
            <div class="col">
              <label class="form-label fw-semibold small">Rule Value</label>
              <input type="number" name="rule_value" class="form-control form-control-sm" value="1" min="0" step="0.01">
            </div>
          </div>
          <div class="row g-2 mb-2">
            <div class="col">
              <label class="form-label fw-semibold small">Start Date</label>
              <input type="datetime-local" name="start_at" class="form-control form-control-sm">
            </div>
            <div class="col">
              <label class="form-label fw-semibold small">End Date</label>
              <input type="datetime-local" name="end_at" class="form-control form-control-sm">
            </div>
          </div>
          <div class="row g-2 mb-2">
            <div class="col">
              <label class="form-label fw-semibold small">Max Claims (0=unlimited)</label>
              <input type="number" name="max_claims" class="form-control form-control-sm" value="0" min="0">
            </div>
            <div class="col">
              <label class="form-label fw-semibold small">Sort Order</label>
              <input type="number" name="sort_order" class="form-control form-control-sm" value="0">
            </div>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold small">Status</label>
            <select name="status" class="form-select form-select-sm">
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
            </select>
          </div>
          <button type="submit" class="btn btn-accent w-100">Create Offer</button>
        </form>
      </div>
    </div>
  </div>

  <div class="col-lg-7">
    <div class="card">
      <div class="card-header py-3">
        <h6 class="mb-0 fw-bold">All Offers ({$data.total})</h6>
      </div>
      <div class="card-body p-0">
        <div class="table-responsive">
          <table class="table mb-0">
            <thead>
              <tr><th>Title</th><th>Reward</th><th>Rule</th><th>Claims</th><th>Status</th><th>Actions</th></tr>
            </thead>
            <tbody>
              {foreach $data.items as $offer}
              <tr>
                <td class="small fw-semibold">{$offer.title|escape|truncate:40}</td>
                <td class="small">{$offer.reward_type|replace:'_':' '|ucfirst}<br>
                  <span class="text-success fw-semibold">+{$offer.reward_value|string_format:'%.2f'}</span></td>
                <td class="small">{$offer.eligibility_rule|replace:'_':' '|ucfirst}</td>
                <td class="small">{$offer.impressions} views</td>
                <td>
                  {if $offer.status === 'active'}<span class="badge badge-status-active">Active</span>
                  {elseif $offer.status === 'inactive'}<span class="badge badge-status-pending">Inactive</span>
                  {else}<span class="badge badge-status-rejected">Expired</span>{/if}
                </td>
                <td>
                  <form method="POST" action="/admin/rewards" class="d-inline">
                    <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                    <input type="hidden" name="action" value="toggle_offer">
                    <input type="hidden" name="offer_id" value="{$offer.id}">
                    <button type="submit" class="btn btn-sm btn-outline-secondary me-1">Toggle</button>
                  </form>
                  <form method="POST" action="/admin/rewards" class="d-inline">
                    <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                    <input type="hidden" name="action" value="delete_offer">
                    <input type="hidden" name="offer_id" value="{$offer.id}">
                    <button type="submit" class="btn btn-sm btn-outline-danger"
                            onclick="return confirm('Delete offer?')">
                      <i class="fas fa-trash"></i>
                    </button>
                  </form>
                </td>
              </tr>
              {foreachelse}
              <tr><td colspan="6" class="text-center text-muted py-4">No offers yet.</td></tr>
              {/foreach}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>
{/block}
