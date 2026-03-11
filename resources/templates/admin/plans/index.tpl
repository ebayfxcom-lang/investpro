{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="d-flex justify-content-end mb-3">
  <a href="/admin/plans/create" class="btn btn-accent"><i class="fas fa-plus me-2"></i>Add New Plan</a>
</div>

<div class="card">
  <div class="card-header bg-white py-3">
    <h6 class="mb-0 fw-bold"><i class="fas fa-layer-group me-2 text-primary"></i>Investment Plans</h6>
  </div>
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead class="table-light">
          <tr>
            <th>Plan Name</th>
            <th>Min / Max</th>
            <th>ROI</th>
            <th>Period</th>
            <th>Duration</th>
            <th>Principal</th>
            <th>Status</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {foreach $plans as $p}
          <tr>
            <td>
              <strong>{$p.name|escape}</strong>
              {if $p.description}<div class="text-muted small">{$p.description|escape|truncate:50}</div>{/if}
            </td>
            <td>${$p.min_amount|string_format:"%.2f"} - {if $p.max_amount > 0}${$p.max_amount|string_format:"%.2f"}{else}<span class="text-muted">No limit</span>{/if}</td>
            <td><strong class="text-success">{$p.roi_percent}%</strong></td>
            <td class="text-capitalize">{$p.roi_period}</td>
            <td>{if $p.duration_value && $p.duration_unit}{$p.duration_value} {if $p.duration_value == 1}{$p.duration_unit}{else}{$p.duration_unit}s{/if}{else}{$p.duration_days} days{/if}</td>
            <td>{if $p.principal_return}<span class="text-success"><i class="fas fa-check"></i> Yes</span>{else}<span class="text-muted">No</span>{/if}</td>
            <td><span class="badge badge-status-{$p.status}">{$p.status|ucfirst}</span></td>
            <td>
              <div class="d-flex gap-1">
                <a href="/admin/plans/{$p.id}/edit" class="btn btn-sm btn-outline-primary py-0 px-2">Edit</a>
                <form method="POST" action="/admin/plans/{$p.id}/delete" class="d-inline">
                  <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                  <button type="submit" class="btn btn-sm btn-outline-danger py-0 px-2" onclick="return confirm('Delete this plan?')">Delete</button>
                </form>
              </div>
            </td>
          </tr>
          {foreachelse}
          <tr><td colspan="8" class="text-center text-muted py-4">No plans found. <a href="/admin/plans/create">Create one</a></td></tr>
          {/foreach}
        </tbody>
      </table>
    </div>
  </div>
</div>
{/block}
