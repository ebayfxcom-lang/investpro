{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="row justify-content-center">
  <div class="col-lg-8">
    <form method="POST" action="{if $plan}/admin/plans/{$plan.id}/edit{else}/admin/plans/create{/if}">
      <input type="hidden" name="_csrf_token" value="{$csrf_token}">

      {* Main plan details card *}
      <div class="card mb-4">
        <div class="card-header bg-white py-3">
          <h6 class="mb-0 fw-bold"><i class="fas fa-layer-group me-2 text-primary"></i>{if $plan}Edit Plan: {$plan.name|escape}{else}Create New Plan{/if}</h6>
        </div>
        <div class="card-body">
          <div class="row g-3">
            <div class="col-md-8">
              <label class="form-label fw-semibold">Plan Name <span class="text-danger">*</span></label>
              <input type="text" name="name" class="form-control" value="{$plan.name|escape}" required>
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Sort Order</label>
              <input type="number" name="sort_order" class="form-control" value="{$plan.sort_order|default:0}">
            </div>
            <div class="col-12">
              <label class="form-label fw-semibold">Description</label>
              <textarea name="description" class="form-control" rows="2">{$plan.description|escape}</textarea>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Minimum Amount ($) <span class="text-danger">*</span></label>
              <input type="number" name="min_amount" class="form-control" step="0.01" value="{$plan.min_amount|default:10}" required>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Maximum Amount ($) <span class="text-muted small">(0 = no limit)</span></label>
              <input type="number" name="max_amount" class="form-control" step="0.01" value="{$plan.max_amount|default:0}">
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">ROI Percent (%) <span class="text-danger">*</span></label>
              <input type="number" name="roi_percent" class="form-control" step="0.0001" value="{$plan.roi_percent|default:1.5}" required>
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">ROI Period <span class="text-danger">*</span></label>
              <select name="roi_period" class="form-select">
                {foreach ['hourly','daily','weekly','monthly'] as $period}
                <option value="{$period}" {if $plan.roi_period == $period}selected{/if}>{$period|ucfirst}</option>
                {/foreach}
              </select>
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Duration <span class="text-danger">*</span></label>
              <div class="input-group">
                <input type="number" name="duration_value" class="form-control"
                       value="{$plan.duration_value|default:$plan.duration_days|default:30}" min="1" required>
                <select name="duration_unit" class="form-select" style="max-width:120px;">
                  {foreach ['hour','day','week','month','year'] as $unit}
                  <option value="{$unit}"
                    {if ($plan.duration_unit|default:'day') == $unit}selected{/if}>
                    {$unit|ucfirst}s
                  </option>
                  {/foreach}
                </select>
              </div>
              <div class="form-text">e.g. 30 Days, 4 Weeks, 12 Months</div>
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Currency</label>
              <input type="text" name="currency" class="form-control" value="{$plan.currency|default:'USD'}" maxlength="10">
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Return Principal?</label>
              <select name="principal_return" class="form-select">
                <option value="1" {if $plan.principal_return}selected{/if}>Yes - Return principal</option>
                <option value="0" {if !$plan.principal_return && $plan}selected{/if}>No - Keep principal</option>
              </select>
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Status</label>
              <select name="status" class="form-select">
                <option value="active" {if $plan.status == 'active' || !$plan}selected{/if}>Active</option>
                <option value="inactive" {if $plan.status == 'inactive'}selected{/if}>Inactive</option>
              </select>
            </div>
          </div>
        </div>
      </div>

      {* Conditional Prerequisites card *}
      {if $all_plans}
      <div class="card mb-4">
        <div class="card-header bg-white py-3">
          <h6 class="mb-0 fw-bold"><i class="fas fa-lock me-2 text-warning"></i>Conditional Prerequisites <span class="text-muted fw-normal small">(optional)</span></h6>
        </div>
        <div class="card-body">
          <p class="text-muted small mb-3">Restrict this plan to users who have already invested in specific plans. Leave all fields empty / zero to disable prerequisites.</p>
          <div class="row g-3">
            <div class="col-12">
              <label class="form-label fw-semibold">Required Prerequisite Plans</label>
              {assign var="prereq_ids" value=($plan.requires_plan_ids) ? $plan.requires_plan_ids|json_decode:true : []}
              <select name="requires_plan_ids[]" class="form-select" multiple
                      size="{if $all_plans|@count > 6}6{else}{$all_plans|@count}{/if}">
                {foreach $all_plans as $p}
                <option value="{$p.id}" {if $prereq_ids && in_array($p.id, $prereq_ids)}selected{/if}>
                  #{$p.id} — {$p.name|escape} ({$p.status})
                </option>
                {/foreach}
              </select>
              <div class="form-text">Hold Ctrl/Cmd to select multiple. Users must have deposited in at least one selected plan.</div>
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Min. Deposits Count</label>
              <input type="number" name="prereq_min_deposits" class="form-control"
                     value="{$plan.prereq_min_deposits|default:0}" min="0" placeholder="0 = any">
              <div class="form-text">Min. deposits required in prerequisite plans.</div>
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Min. Total Amount ($)</label>
              <input type="number" name="prereq_min_amount" class="form-control" step="0.01"
                     value="{$plan.prereq_min_amount|default:0}" min="0" placeholder="0 = any">
              <div class="form-text">Min. total invested in prerequisite plans.</div>
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Required Deposit Status</label>
              <select name="prereq_deposit_status" class="form-select">
                <option value="any"       {if ($plan.prereq_deposit_status|default:'any') == 'any'}selected{/if}>Any status</option>
                <option value="active"    {if $plan.prereq_deposit_status == 'active'}selected{/if}>Active only</option>
                <option value="completed" {if $plan.prereq_deposit_status == 'completed'}selected{/if}>Completed only</option>
              </select>
            </div>
          </div>
        </div>
      </div>
      {/if}

      <div class="d-flex gap-2">
        <button type="submit" class="btn btn-accent"><i class="fas fa-save me-2"></i>{if $plan}Update Plan{else}Create Plan{/if}</button>
        <a href="/admin/plans" class="btn btn-outline-secondary">Cancel</a>
      </div>
    </form>
  </div>
</div>
{/block}
