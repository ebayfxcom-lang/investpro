{extends file="layouts/admin.tpl"}
{block name="content"}

<div class="d-flex align-items-center gap-2 mb-3">
  <a href="/admin/scam-reports" class="btn btn-sm btn-outline-secondary">
    <i class="fas fa-arrow-left me-1"></i>Back
  </a>
  <h6 class="fw-bold mb-0"><i class="fas fa-flag me-2 text-danger"></i>Scam Report #{$report.id}</h6>
</div>

<div class="row g-3">
  <div class="col-md-8">
    <div class="card mb-3">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold">Report Details</h6>
      </div>
      <div class="card-body">
        <dl class="row mb-0">
          <dt class="col-sm-4">Website URL</dt>
          <dd class="col-sm-8 text-danger fw-semibold">
            <a href="{$report.website_url|escape}" target="_blank" rel="noopener noreferrer" class="text-danger">
              {$report.website_url|escape}
            </a>
          </dd>
          <dt class="col-sm-4">Description</dt>
          <dd class="col-sm-8">{$report.description|escape|nl2br}</dd>
          <dt class="col-sm-4">Date of Scam</dt>
          <dd class="col-sm-8">{if $report.scam_date}{$report.scam_date}{else}—{/if}</dd>
          <dt class="col-sm-4">Evidence / Notes</dt>
          <dd class="col-sm-8">{if $report.evidence_note}{$report.evidence_note|escape|nl2br}{else}—{/if}</dd>
          <dt class="col-sm-4">IP Address</dt>
          <dd class="col-sm-8 text-muted font-monospace small">{$report.ip_address|default:'—'}</dd>
          <dt class="col-sm-4">Submitted At</dt>
          <dd class="col-sm-8 text-muted">{$report.created_at|date_format:'%b %d, %Y %H:%M'}</dd>
        </dl>
      </div>
    </div>

    <div class="card">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold">Reporter Information</h6>
      </div>
      <div class="card-body">
        <dl class="row mb-0">
          <dt class="col-sm-4">Name</dt>
          <dd class="col-sm-8">{$report.reporter_name|default:'Anonymous'|escape}</dd>
          <dt class="col-sm-4">Email</dt>
          <dd class="col-sm-8">{$report.reporter_email|default:'—'|escape}</dd>
          <dt class="col-sm-4">Phone</dt>
          <dd class="col-sm-8">{$report.reporter_phone|default:'—'|escape}</dd>
        </dl>
      </div>
    </div>
  </div>

  <div class="col-md-4">
    <div class="card">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold">Actions</h6>
      </div>
      <div class="card-body">
        <div class="mb-3">
          <span class="badge fs-6
            {if $report.status == 'pending'}bg-warning bg-opacity-25 text-warning
            {elseif $report.status == 'confirmed'}bg-danger bg-opacity-25 text-danger
            {elseif $report.status == 'reviewed'}bg-info bg-opacity-25 text-info
            {else}bg-secondary bg-opacity-25 text-muted{/if}">
            {$report.status|ucfirst}
          </span>
        </div>
        <form method="POST" action="/admin/scam-reports">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">
          <input type="hidden" name="report_id" value="{$report.id}">
          <div class="mb-3">
            <label class="form-label fw-semibold">Admin Notes</label>
            <textarea name="admin_notes" class="form-control" rows="4">{$report.admin_notes|escape}</textarea>
          </div>
          <div class="d-grid gap-2">
            <button type="submit" name="action" value="reviewed" class="btn btn-outline-info">
              <i class="fas fa-search me-1"></i>Mark as Reviewed
            </button>
            <button type="submit" name="action" value="confirmed" class="btn btn-outline-danger"
                    onclick="return confirm('Confirm this as a scam site?')">
              <i class="fas fa-exclamation-triangle me-1"></i>Confirm Scam
            </button>
            <button type="submit" name="action" value="dismissed" class="btn btn-outline-secondary"
                    onclick="return confirm('Dismiss this report?')">
              <i class="fas fa-times me-1"></i>Dismiss
            </button>
          </div>
        </form>
        <hr>
        <form method="POST" action="/admin/scam-reports">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">
          <input type="hidden" name="action" value="delete">
          <input type="hidden" name="report_id" value="{$report.id}">
          <button type="submit" class="btn btn-danger w-100"
                  onclick="return confirm('Permanently delete this report?')">
            <i class="fas fa-trash me-1"></i>Delete Report
          </button>
        </form>
      </div>
    </div>
  </div>
</div>
{/block}
