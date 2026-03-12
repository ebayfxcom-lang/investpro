{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="row justify-content-center">
  <div class="col-lg-8">
    <div class="card">
      <div class="card-header py-3 d-flex align-items-center justify-content-between">
        <h6 class="mb-0 fw-bold">Withdrawal #{$withdrawal.id}</h6>
        <a href="/admin/withdrawals" class="btn btn-sm btn-outline-secondary">Back</a>
      </div>
      <div class="card-body">
        <div class="row g-3 mb-4">
          <div class="col-sm-6">
            <div class="text-muted small text-uppercase fw-semibold mb-1">User ID</div>
            <div>{$withdrawal.user_id}</div>
          </div>
          <div class="col-sm-6">
            <div class="text-muted small text-uppercase fw-semibold mb-1">Requested Amount</div>
            <div class="fw-bold">{$withdrawal.amount|string_format:'%.8f'} {$withdrawal.currency|escape}</div>
          </div>
          {if $withdrawal.actual_crypto_amount}
          <div class="col-sm-6">
            <div class="text-muted small text-uppercase fw-semibold mb-1">Crypto to Send</div>
            <div class="fw-bold text-warning">{$withdrawal.actual_crypto_amount|string_format:'%.8f'} {$withdrawal.currency|escape}</div>
          </div>
          {/if}
          <div class="col-sm-6">
            <div class="text-muted small text-uppercase fw-semibold mb-1">Fee</div>
            <div>{$withdrawal.fee|string_format:'%.8f'} {$withdrawal.currency|escape}</div>
          </div>
          {if $withdrawal.network}
          <div class="col-sm-6">
            <div class="text-muted small text-uppercase fw-semibold mb-1">Network</div>
            <div><span class="badge bg-primary">{$withdrawal.network|escape}</span></div>
          </div>
          {/if}
          <div class="col-sm-6">
            <div class="text-muted small text-uppercase fw-semibold mb-1">Method</div>
            <div>{$withdrawal.method|escape}</div>
          </div>
          <div class="col-12">
            <div class="text-muted small text-uppercase fw-semibold mb-1">Destination Address</div>
            <div class="font-monospace text-break">{$withdrawal.address|escape}</div>
          </div>
          {if $withdrawal.memo}
          <div class="col-sm-6">
            <div class="text-muted small text-uppercase fw-semibold mb-1">Memo / Tag</div>
            <div class="font-monospace">{$withdrawal.memo|escape}</div>
          </div>
          {/if}
          <div class="col-sm-6">
            <div class="text-muted small text-uppercase fw-semibold mb-1">Status</div>
            <div>
              {if $withdrawal.status === 'approved'}<span class="badge badge-status-active">Approved</span>
              {elseif $withdrawal.status === 'pending'}<span class="badge badge-status-pending">Pending</span>
              {else}<span class="badge badge-status-rejected">Rejected</span>{/if}
            </div>
          </div>
          {if $withdrawal.usd_amount}
          <div class="col-sm-6">
            <div class="text-muted small text-uppercase fw-semibold mb-1">USD Equivalent</div>
            <div>${$withdrawal.usd_amount|string_format:'%.2f'}</div>
          </div>
          {/if}
          <div class="col-sm-6">
            <div class="text-muted small text-uppercase fw-semibold mb-1">Created</div>
            <div class="small">{$withdrawal.created_at|date_format:'%b %d, %Y %H:%M'}</div>
          </div>
          {if $withdrawal.sent_tx_hash}
          <div class="col-12">
            <div class="text-muted small text-uppercase fw-semibold mb-1">Sent TX Hash</div>
            <div class="font-monospace text-success text-break">{$withdrawal.sent_tx_hash|escape}</div>
          </div>
          {/if}
          {if $withdrawal.admin_note}
          <div class="col-12">
            <div class="text-muted small text-uppercase fw-semibold mb-1">Admin Note</div>
            <div>{$withdrawal.admin_note|escape}</div>
          </div>
          {/if}
        </div>

        {if $withdrawal.status === 'pending'}
        <hr>
        <div class="row g-3">
          <div class="col-md-6">
            <form method="POST" action="/admin/withdrawals/{$withdrawal.id}/approve">
              <input type="hidden" name="_csrf_token" value="{$csrf_token}">
              <h6 class="fw-semibold mb-3">Approve & Mark Sent</h6>
              <div class="mb-2">
                <label class="form-label small fw-semibold">TX Hash (optional)</label>
                <input type="text" name="sent_tx_hash" class="form-control form-control-sm font-monospace"
                       placeholder="Transaction hash after sending">
              </div>
              <div class="mb-3">
                <label class="form-label small fw-semibold">Admin Note (optional)</label>
                <input type="text" name="admin_note" class="form-control form-control-sm"
                       placeholder="Internal note">
              </div>
              <button type="submit" class="btn btn-success w-100">
                <i class="fas fa-check me-2"></i>Approve Withdrawal
              </button>
            </form>
          </div>
          <div class="col-md-6">
            <form method="POST" action="/admin/withdrawals/{$withdrawal.id}/reject">
              <input type="hidden" name="_csrf_token" value="{$csrf_token}">
              <h6 class="fw-semibold mb-3">Reject & Refund</h6>
              <p class="text-muted small">This will refund the amount back to the user's wallet.</p>
              <button type="submit" class="btn btn-danger w-100 mt-3"
                      onclick="return confirm('Reject and refund this withdrawal?')">
                <i class="fas fa-times me-2"></i>Reject & Refund
              </button>
            </form>
          </div>
        </div>
        {/if}
      </div>
    </div>
  </div>
</div>
{/block}
