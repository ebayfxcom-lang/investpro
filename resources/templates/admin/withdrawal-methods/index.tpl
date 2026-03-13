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
                  <button type="button" class="btn btn-sm btn-outline-primary me-1 js-edit-method"
                          data-id="{$m.id}"
                          data-name="{$m.name|escape:'html'}"
                          data-currency="{$m.currency|escape:'html'}"
                          data-network="{$m.network|default:''|escape:'html'}"
                          data-min="{$m.min_amount}"
                          data-fee="{$m.fee}"
                          data-fee-percent="{$m.fee_percent}"
                          data-regex="{$m.address_regex|default:''|escape:'html'}"
                          data-instructions="{$m.instructions|default:''|escape:'html'}"
                          data-sort="{$m.sort_order}"
                          data-status="{$m.status}">
                    <i class="fas fa-edit"></i>
                  </button>
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

<div class="modal fade" id="editMethodModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Edit Withdrawal Method</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <form method="POST" action="/admin/withdrawal-methods">
        <input type="hidden" name="_csrf_token" value="{$csrf_token}">
        <input type="hidden" name="action" value="update">
        <input type="hidden" name="method_id" id="edit_method_id">
        <div class="modal-body">
          <div class="mb-2">
            <label class="form-label fw-semibold small">Display Name</label>
            <input type="text" name="name" id="edit_name" class="form-control form-control-sm" required>
          </div>
          <div class="row g-2 mb-2">
            <div class="col">
              <label class="form-label fw-semibold small">Currency</label>
              <input type="text" name="currency" id="edit_currency" class="form-control form-control-sm" required maxlength="10">
            </div>
            <div class="col">
              <label class="form-label fw-semibold small">Network</label>
              <input type="text" name="network" id="edit_network" class="form-control form-control-sm">
            </div>
          </div>
          <div class="row g-2 mb-2">
            <div class="col">
              <label class="form-label fw-semibold small">Min Amount</label>
              <input type="number" name="min_amount" id="edit_min" class="form-control form-control-sm" step="0.00000001">
            </div>
            <div class="col">
              <label class="form-label fw-semibold small">Fixed Fee</label>
              <input type="number" name="fee" id="edit_fee" class="form-control form-control-sm" step="0.00000001">
            </div>
          </div>
          <div class="mb-2">
            <label class="form-label fw-semibold small">Fee Percent (%)</label>
            <input type="number" name="fee_percent" id="edit_fee_percent" class="form-control form-control-sm" step="0.01">
          </div>
          <div class="mb-2">
            <label class="form-label fw-semibold small">Address Regex (optional)</label>
            <input type="text" name="address_regex" id="edit_regex" class="form-control form-control-sm">
          </div>
          <div class="mb-2">
            <label class="form-label fw-semibold small">Instructions</label>
            <textarea name="instructions" id="edit_instructions" class="form-control form-control-sm" rows="2" maxlength="500"></textarea>
          </div>
          <div class="row g-2 mb-2">
            <div class="col">
              <label class="form-label fw-semibold small">Sort Order</label>
              <input type="number" name="sort_order" id="edit_sort" class="form-control form-control-sm">
            </div>
            <div class="col">
              <label class="form-label fw-semibold small">Status</label>
              <select name="status" id="edit_status" class="form-select form-select-sm">
                <option value="active">Active</option>
                <option value="inactive">Inactive</option>
              </select>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
          <button type="submit" class="btn btn-accent">Save Changes</button>
        </div>
      </form>
    </div>
  </div>
</div>
<script>
{literal}
document.querySelectorAll('.js-edit-method').forEach(function(btn) {
  btn.addEventListener('click', function() {
    document.getElementById('edit_method_id').value = this.dataset.id;
    document.getElementById('edit_name').value = this.dataset.name;
    document.getElementById('edit_currency').value = this.dataset.currency;
    document.getElementById('edit_network').value = this.dataset.network;
    document.getElementById('edit_min').value = this.dataset.min;
    document.getElementById('edit_fee').value = this.dataset.fee;
    document.getElementById('edit_fee_percent').value = this.dataset.feePercent;
    document.getElementById('edit_regex').value = this.dataset.regex;
    document.getElementById('edit_instructions').value = this.dataset.instructions;
    document.getElementById('edit_sort').value = this.dataset.sort;
    document.getElementById('edit_status').value = this.dataset.status;
    new bootstrap.Modal(document.getElementById('editMethodModal')).show();
  });
});
{/literal}
</script>
