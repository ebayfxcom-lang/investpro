{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="row justify-content-center">
  <div class="col-lg-8">
    <div class="card mb-3">
      <div class="card-header py-3 d-flex align-items-center justify-content-between">
        <h6 class="mb-0 fw-bold">KYC Review – #{$kyc.id}</h6>
        <a href="/admin/kyc" class="btn btn-sm btn-outline-secondary">Back to List</a>
      </div>
      <div class="card-body">
        <div class="row g-3 mb-4">
          <div class="col-sm-6">
            <div class="text-muted small text-uppercase fw-semibold mb-1">User</div>
            <div class="fw-semibold">{$kyc.username|escape}</div>
          </div>
          <div class="col-sm-6">
            <div class="text-muted small text-uppercase fw-semibold mb-1">Document Type</div>
            <div>{$kyc.document_type|replace:'_':' '|ucfirst}</div>
          </div>
          <div class="col-sm-6">
            <div class="text-muted small text-uppercase fw-semibold mb-1">Document Number</div>
            <div class="font-monospace">{$kyc.document_number|escape}</div>
          </div>
          <div class="col-sm-6">
            <div class="text-muted small text-uppercase fw-semibold mb-1">Status</div>
            <div>
              {if $kyc.status === 'approved'}<span class="badge badge-status-active">Approved</span>
              {elseif $kyc.status === 'rejected'}<span class="badge badge-status-rejected">Rejected</span>
              {else}<span class="badge badge-status-pending">Pending</span>{/if}
            </div>
          </div>
        </div>

        {if $kyc.front_image}
        <div class="mb-3">
          <div class="text-muted small text-uppercase fw-semibold mb-1">Front Image</div>
          <img src="/storage/{$kyc.front_image|escape}" class="img-fluid rounded border" style="max-height:250px">
        </div>
        {/if}
        {if $kyc.back_image}
        <div class="mb-3">
          <div class="text-muted small text-uppercase fw-semibold mb-1">Back Image</div>
          <img src="/storage/{$kyc.back_image|escape}" class="img-fluid rounded border" style="max-height:250px">
        </div>
        {/if}
        {if $kyc.selfie_image}
        <div class="mb-3">
          <div class="text-muted small text-uppercase fw-semibold mb-1">Selfie</div>
          <img src="/storage/{$kyc.selfie_image|escape}" class="img-fluid rounded border" style="max-height:250px">
        </div>
        {/if}

        {if $kyc.status === 'pending'}
        <hr>
        <div class="row g-2">
          <div class="col-md-6">
            <form method="POST" action="/admin/kyc/{$kyc.id}/approve">
              <input type="hidden" name="_csrf_token" value="{$csrf_token}">
              <div class="mb-2">
                <input type="text" name="review_note" class="form-control form-control-sm"
                       placeholder="Optional note for user">
              </div>
              <button type="submit" class="btn btn-success w-100">
                <i class="fas fa-check me-2"></i>Approve KYC
              </button>
            </form>
          </div>
          <div class="col-md-6">
            <form method="POST" action="/admin/kyc/{$kyc.id}/reject">
              <input type="hidden" name="_csrf_token" value="{$csrf_token}">
              <div class="mb-2">
                <input type="text" name="review_note" class="form-control form-control-sm"
                       placeholder="Rejection reason (required for user)" required>
              </div>
              <button type="submit" class="btn btn-danger w-100">
                <i class="fas fa-times me-2"></i>Reject KYC
              </button>
            </form>
          </div>
        </div>
        {/if}

        {if $kyc.review_note}
        <div class="alert alert-info mt-3 mb-0 small">
          <strong>Review Note:</strong> {$kyc.review_note|escape}
        </div>
        {/if}

      </div>
    </div>
  </div>
</div>
{/block}
