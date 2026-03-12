{extends file="layouts/public.tpl"}
{block name="content"}
<section style="padding:5rem 0">
  <div class="container">
    <div class="text-center mb-5">
      <h1 class="fw-bold">Investment Plans</h1>
      <p class="text-muted">Choose the plan that matches your investment goals.</p>
    </div>
    <div class="row g-4 justify-content-center">
      {foreach $plans as $plan}
      <div class="col-md-4">
        <div class="card plan-card h-100 text-center p-4">
          <h4 class="fw-bold mb-2">{$plan.name|escape}</h4>
          {if $plan.description}<p class="text-muted small mb-3">{$plan.description|escape|truncate:120}</p>{/if}
          <div class="display-5 fw-bold my-3" style="color:var(--pub-primary)">{$plan.roi_percent}%
            <span class="fs-6 text-muted fw-normal">/{$plan.roi_period}</span>
          </div>
          <ul class="list-unstyled text-muted small mb-4">
            <li>Min: <strong>${$plan.min_amount|string_format:'%.0f'}</strong></li>
            {if $plan.max_amount > 0}<li>Max: <strong>${$plan.max_amount|string_format:'%.0f'}</strong></li>{/if}
            <li>Duration: <strong>{$plan.duration_days} days</strong></li>
            <li>Principal: <strong>{if $plan.principal_return}Returned{else}Not Returned{/if}</strong></li>
          </ul>
          <a href="/register" class="btn btn-primary w-100">Invest Now</a>
        </div>
      </div>
      {foreachelse}
      <p class="text-muted text-center py-5">No active plans available.</p>
      {/foreach}
    </div>
  </div>
</section>
{/block}
