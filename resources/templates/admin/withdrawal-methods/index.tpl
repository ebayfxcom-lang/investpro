{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="row g-3">
  <div class="col-lg-5">
    <div class="card">
      <div class="card-header py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-plus me-2"></i>Add Withdrawal Method</h6>
      </div>
      <div class="card-body">
        <form method="POST" action="/admin/withdrawal-methods">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">
          <input type="hidden" name="action" value="create">
          <div class="mb-2">
            <label class="form-label fw-semibold small">Display Name</label>
            <input type="text" name="name" class="form-control form-control-sm" required placeholder="Bitcoin (BTC)">
          </div>
          <div class="row g-2 mb-2">
            <div class="col">
              <label class="form-label fw-semibold small">Currency</label>
              <input type="text" name="currency" class="form-control form-control-sm" required placeholder="BTC" maxlength="10">
            </div>
            <div class="col">
              <label class="form-label fw-semibold small">Network</label>
              <input type="text" name="network" class="form-control form-control-sm" placeholder="BTC, ERC20, TRC20">
            </div>
          </div>
          <div class="row g-2 mb-2">
            <div class="col">
              <label class="form-label fw-semibold small">Min Amount</label>
              <input type="number" name="min_amount" class="form-control form-control-sm" step="0.00000001" value="10">
            </div>
            <div class="col">
              <label class="form-label fw-semibold small">Fixed Fee</label>
              <input type="number" name="fee" class="form-control form-control-sm" step="0.00000001" value="0">
            </div>
          </div>
          <div class="mb-2">
            <label class="form-label fw-semibold small">Fee Percent (%)</label>
            <input type="number" name="fee_percent" class="form-control form-control-sm" step="0.01" value="0">
          </div>
          <div class="mb-2">
            <label class="form-label fw-semibold small">Address Regex (optional)</label>
            <input type="text" name="address_regex" class="form-control form-control-sm" placeholder="^[13][a-km-zA-HJ-NP-Z1-9]{ldelim}25,34{rdelim}$">
          </div>
          <div class="mb-2">
            <div class="form-check">
              <input class="form-check-input" type="checkbox" name="requires_memo" value="1" id="reqMemo">
              <label class="form-check-label small" for="reqMemo">Requires memo/tag</label>
            </div>
          </div>
          <div class="mb-2">
            <label class="form-label fw-semibold small">Instructions</label>
            <textarea name="instructions" class="form-control form-control-sm" rows="2" maxlength="500"></textarea>
          </div>
          <div class="row g-2 mb-3">
            <div class="col">
              <label class="form-label fw-semibold small">Sort Order</label>
              <input type="number" name="sort_order" class="form-control form-control-sm" value="0">
            </div>
            <div class="col">
              <label class="form-label fw-semibold small">Status</label>
              <select name="status" class="form-select form-select-sm">
                <option value="active">Active</option>
                <option value="inactive">Inactive</option>
              </select>
            </div>
          </div>
          <button type="submit" class="btn btn-accent w-100">Add Method</button>
        </form>
      </div>
    </div>
  </div>

  <div class="col-lg-7">
    <div class="card">
      <div class="card-header py-3">
        <h6 class="mb-0 fw-bold">Withdrawal Methods ({$methods|count})</h6>
      </div>
      <div class="card-body p-0">
        <div class="table-responsive">
          <table class="table mb-0">
            <thead>
              <tr><th>Name</th><th>Currency</th><th>Network</th><th>Min</th><th>Fee</th><th>Status</th><th>Actions</th></tr>
            </thead>
            <tbody>
              {foreach $methods as $m}
              <tr>
                <td class="small fw-semibold">{$m.name|escape}</td>
                <td class="small">{$m.currency|escape}</td>
                <td class="small">{$m.network|escape|default:'-'}</td>
                <td class="small">{$m.min_amount|string_format:'%.2f'}</td>
                <td class="small">
                  {if $m.fee > 0}{$m.fee|string_format:'%.4f'}{/if}
                  {if $m.fee_percent > 0} +{$m.fee_percent}%{/if}
                  {if $m.fee == 0 && $m.fee_percent == 0}-{/if}
                </td>
                <td>
                  {if $m.status === 'active'}<span class="badge badge-status-active">Active</span>
                  {else}<span class="badge badge-status-rejected">Inactive</span>{/if}
                </td>
                <td>
                  <form method="POST" action="/admin/withdrawal-methods" class="d-inline">
                    <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                    <input type="hidden" name="action" value="toggle">
                    <input type="hidden" name="method_id" value="{$m.id}">
                    <button type="submit" class="btn btn-sm btn-outline-secondary me-1">Toggle</button>
                  </form>
                  <form method="POST" action="/admin/withdrawal-methods" class="d-inline">
                    <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="method_id" value="{$m.id}">
                    <button type="submit" class="btn btn-sm btn-outline-danger"
                            onclick="return confirm('Delete?')">
                      <i class="fas fa-trash"></i>
                    </button>
                  </form>
                </td>
              </tr>
              {foreachelse}
              <tr><td colspan="7" class="text-center text-muted py-4">No methods configured.</td></tr>
              {/foreach}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>
{/block}
