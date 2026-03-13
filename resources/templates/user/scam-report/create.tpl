{extends file="layouts/auth.tpl"}
{block name="content"}
<div class="container py-5">
  <div class="row justify-content-center">
    <div class="col-lg-7">
      <div class="card shadow-sm">
        <div class="card-header bg-white py-4 text-center border-bottom-0">
          <div class="mb-2">
            <span class="bg-danger bg-opacity-10 text-danger rounded-circle d-inline-flex align-items-center justify-content-center"
                  style="width:56px;height:56px;font-size:1.5rem;">
              <i class="fas fa-flag"></i>
            </span>
          </div>
          <h4 class="fw-bold mb-1">Report a Scam Website</h4>
          <p class="text-muted mb-0">Help protect others by reporting fraudulent websites</p>
        </div>
        <div class="card-body px-4 pb-4">
          {if $flash.success}
          <div class="alert alert-success"><i class="fas fa-check-circle me-2"></i>{$flash.success}</div>
          {/if}
          {if $flash.error}
          <div class="alert alert-danger"><i class="fas fa-exclamation-circle me-2"></i>{$flash.error}</div>
          {/if}

          <form method="POST" action="/report-scam">
            <div class="mb-3">
              <label class="form-label fw-semibold">Scam Website URL <span class="text-danger">*</span></label>
              <input type="url" name="website_url" class="form-control" required
                     placeholder="https://example-scam-site.com">
            </div>
            <div class="mb-3">
              <label class="form-label fw-semibold">Describe the Scam <span class="text-danger">*</span></label>
              <textarea name="description" class="form-control" rows="4" required
                        placeholder="Explain what happened, how you were scammed, and any relevant details..."></textarea>
            </div>
            <div class="row g-3 mb-3">
              <div class="col-md-6">
                <label class="form-label fw-semibold">When did it happen?</label>
                <input type="date" name="scam_date" class="form-control" max="{$smarty.now|to_input_date}">
              </div>
              <div class="col-md-6">
                <label class="form-label fw-semibold">Your Name <span class="text-muted small">(optional)</span></label>
                <input type="text" name="reporter_name" class="form-control" placeholder="Anonymous">
              </div>
            </div>
            <div class="mb-3">
              <label class="form-label fw-semibold">Additional Evidence / Notes</label>
              <textarea name="evidence_note" class="form-control" rows="2"
                        placeholder="Any additional information, links to evidence, screenshots descriptions..."></textarea>
            </div>
            <div class="row g-3 mb-4">
              <div class="col-md-6">
                <label class="form-label fw-semibold">Your Email <span class="text-muted small">(optional)</span></label>
                <input type="email" name="reporter_email" class="form-control" placeholder="for follow-up">
              </div>
              <div class="col-md-6">
                <label class="form-label fw-semibold">Your Phone <span class="text-muted small">(optional)</span></label>
                <input type="tel" name="reporter_phone" class="form-control" placeholder="+1 234 567 8900">
              </div>
            </div>
            <div class="d-grid">
              <button type="submit" class="btn btn-danger">
                <i class="fas fa-flag me-2"></i>Submit Report
              </button>
            </div>
          </form>
        </div>
      </div>
      <p class="text-center text-muted small mt-3">
        All reports are reviewed by our team. Your personal information is kept confidential.
      </p>
    </div>
  </div>
</div>
{/block}
