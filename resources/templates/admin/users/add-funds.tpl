{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="row justify-content-center">
  <div class="col-lg-6">
    <div class="card">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-wallet me-2 text-success"></i>Add Funds to User</h6>
      </div>
      <div class="card-body">
        {if $user}
        <div class="alert alert-light border mb-4">
          <strong>{$user.username|escape}</strong> &mdash; {$user.email|escape}
        </div>
        {/if}
        <form method="POST" action="/admin/users/{$user.id}/add-funds">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">
          <div class="mb-3">
            <label class="form-label fw-semibold">Amount <span class="text-danger">*</span></label>
            <div class="input-group">
              <span class="input-group-text">$</span>
              <input type="number" name="amount" class="form-control" step="0.01" min="0.01" placeholder="0.00" required>
            </div>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Currency</label>
            <select name="currency" class="form-select">
              <option value="USD">USD - US Dollar</option>
              <option value="EUR">EUR - Euro</option>
              <option value="BTC">BTC - Bitcoin</option>
              <option value="ETH">ETH - Ethereum</option>
              <option value="USDT">USDT</option>
            </select>
          </div>
          <div class="mb-4">
            <label class="form-label fw-semibold">Note / Description</label>
            <input type="text" name="note" class="form-control" placeholder="Reason for adding funds...">
          </div>
          <div class="d-flex gap-2">
            <button type="submit" class="btn btn-success"><i class="fas fa-plus me-2"></i>Add Funds</button>
            <a href="/admin/users/{$user.id}" class="btn btn-outline-secondary">Cancel</a>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>
{/block}
