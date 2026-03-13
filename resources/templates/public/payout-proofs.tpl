{extends file="layouts/public.tpl"}
{block name="content"}
<div class="container py-5">
  <div class="text-center mb-5">
    <h2 class="fw-bold">Payout Proofs</h2>
    <p class="text-muted">Verified withdrawals from our members. Transparency you can trust.</p>
  </div>

  {if $proofs}
  <div class="row g-3">
    {foreach $proofs as $proof}
    <div class="col-sm-6 col-lg-4">
      <div class="card h-100">
        <div class="card-body">
          {if $proof.proof_image}
          <img src="/storage/{$proof.proof_image|escape}" class="img-fluid rounded mb-2" style="max-height:200px;width:100%;object-fit:cover">
          {/if}
          <div class="d-flex justify-content-between align-items-center">
            <div>
              <div class="fw-semibold">{$proof.currency} {$proof.amount|string_format:'%.2f'}</div>
              <div class="text-muted small">{$proof.username|escape}</div>
            </div>
            <div class="text-end">
              <span class="badge bg-success">Paid</span>
              <div class="text-muted small">{$proof.created_at|date_format:'%b %d, %Y'}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
    {/foreach}
  </div>
  {else}
  <div class="text-center text-muted py-5">
    <i class="fas fa-check-circle fa-3x mb-3 opacity-25"></i>
    <p>Payout proofs are coming soon.</p>
  </div>
  {/if}

  <div class="text-center mt-5">
    <a href="/register" class="btn btn-primary btn-lg">Start Earning Today</a>
  </div>
</div>
{/block}
