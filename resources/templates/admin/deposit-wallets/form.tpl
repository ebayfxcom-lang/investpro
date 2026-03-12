{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="row justify-content-center">
  <div class="col-lg-7">
    <div class="card">
      <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
        <h6 class="mb-0 fw-bold">
          <i class="fas fa-wallet me-2 text-primary"></i>{$title|escape}
        </h6>
        <a href="/admin/deposit-wallets" class="btn btn-sm btn-outline-secondary">
          <i class="fas fa-arrow-left me-1"></i>Back
        </a>
      </div>
      <div class="card-body">
        <form method="POST" action="{if $wallet}/admin/deposit-wallets/{$wallet.id}/edit{else}/admin/deposit-wallets/create{/if}">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">

          <div class="row g-3">
            <div class="col-md-6">
              <label class="form-label fw-semibold">Coin / Currency Code <span class="text-danger">*</span></label>
              <input type="text" name="currency_code" class="form-control text-uppercase" maxlength="10" placeholder="e.g. BTC, ETH, USDT" value="{if $wallet}{$wallet.currency_code|escape}{/if}" required>
              <div class="form-text">Use a short code: BTC, ETH, USDT, etc.</div>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Network</label>
              <input type="text" name="network" class="form-control" maxlength="50" placeholder="e.g. ERC20, TRC20, BEP20" value="{if $wallet}{$wallet.network|escape}{/if}">
              <div class="form-text">Leave blank for native chain.</div>
            </div>
            <div class="col-12">
              <label class="form-label fw-semibold">Wallet Address <span class="text-danger">*</span></label>
              <input type="text" name="wallet_address" class="form-control font-monospace" maxlength="255" placeholder="Deposit wallet address" value="{if $wallet}{$wallet.wallet_address|escape}{/if}" required>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Memo / Tag</label>
              <input type="text" name="memo" class="form-control" maxlength="100" placeholder="Optional memo or destination tag" value="{if $wallet}{$wallet.memo|escape}{/if}">
            </div>
            <div class="col-md-3">
              <label class="form-label fw-semibold">Min Deposit</label>
              <input type="number" name="min_deposit" class="form-control" step="0.00000001" min="0" value="{if $wallet}{$wallet.min_deposit}{else}0{/if}">
            </div>
            <div class="col-md-3">
              <label class="form-label fw-semibold">Confirmations</label>
              <input type="number" name="confirmations" class="form-control" step="1" min="1" value="{if $wallet}{$wallet.confirmations}{else}3{/if}">
            </div>
            <div class="col-12">
              <label class="form-label fw-semibold">Instructions for Users</label>
              <textarea name="instructions" class="form-control" rows="3" placeholder="Optional instructions shown to users when depositing">{if $wallet}{$wallet.instructions|escape}{/if}</textarea>
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Status</label>
              <select name="status" class="form-select">
                <option value="active" {if !$wallet || $wallet.status == 'active'}selected{/if}>Active</option>
                <option value="inactive" {if $wallet && $wallet.status == 'inactive'}selected{/if}>Inactive</option>
              </select>
            </div>
          </div>

          <div class="mt-4 d-flex gap-2">
            <button type="submit" class="btn btn-accent">
              <i class="fas fa-save me-2"></i>{if $wallet}Update Wallet{else}Create Wallet{/if}
            </button>
            <a href="/admin/deposit-wallets" class="btn btn-outline-secondary">Cancel</a>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>
{/block}
