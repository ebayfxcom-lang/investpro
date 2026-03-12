{extends file="layouts/user.tpl"}
{block name="content"}
<div class="row justify-content-center">
  <div class="col-lg-7">
    <div class="card">
      <div class="card-header py-3 d-flex align-items-center justify-content-between">
        <h6 class="mb-0 fw-bold"><i class="fas fa-id-card me-2 text-primary"></i>KYC Verification</h6>
        {if $kyc}
          {if $kyc.status === 'approved'}
            <span class="badge bg-success">Approved</span>
          {elseif $kyc.status === 'rejected'}
            <span class="badge bg-danger">Rejected</span>
          {else}
            <span class="badge bg-warning text-dark">Pending Review</span>
          {/if}
        {else}
          <span class="badge bg-secondary">Not Submitted</span>
        {/if}
      </div>
      <div class="card-body">

        {if $kyc && $kyc.status === 'approved'}
          <div class="alert alert-success">
            <i class="fas fa-check-circle me-2"></i>Your identity has been verified successfully.
          </div>

        {elseif $kyc && $kyc.status === 'pending'}
          <div class="alert alert-info">
            <i class="fas fa-hourglass-half me-2"></i>Your documents are under review. We will notify you within 24–48 hours.
          </div>

        {elseif $kyc && $kyc.status === 'rejected'}
          <div class="alert alert-danger">
            <i class="fas fa-times-circle me-2"></i>Your KYC was rejected.
            {if $kyc.review_note}<br><strong>Reason:</strong> {$kyc.review_note|escape}{/if}
          </div>
          <p class="text-muted small">Please resubmit with correct documents.</p>
          {include file="user/kyc/_form.tpl"}

        {else}
          <p class="text-muted small mb-4">
            To comply with regulations and unlock full account features, please verify your identity.
          </p>
          {include file="user/kyc/_form.tpl"}
        {/if}

      </div>
    </div>
  </div>
</div>
{/block}
