{extends file="layouts/user.tpl"}
{block name="content"}
<div class="row mb-3">
  <div class="col">
    <h5 class="fw-bold mb-1"><i class="fas fa-gift me-2 text-warning"></i>Rewards Hub</h5>
    <p class="text-muted small">Exclusive offers and rewards just for you.</p>
  </div>
</div>

<!-- Active Offers -->
{if $active_offers}
<div class="row g-3 mb-4">
  {foreach $active_offers as $offer}
  {assign var="elig" value=$offer.eligibility}
  <div class="col-md-6 col-lg-4">
    <div class="card h-100">
      {if $offer.banner_url}
      <img src="{$offer.banner_url|escape}" class="card-img-top" style="height:140px;object-fit:cover" alt="">
      {/if}
      <div class="card-body d-flex flex-column">
        <h6 class="fw-bold mb-1">{$offer.title|escape}</h6>
        {if $offer.description}
        <p class="text-muted small mb-2">{$offer.description|escape|truncate:120}</p>
        {/if}
        <div class="small mb-2">
          <span class="badge bg-primary me-1">{$offer.reward_type|replace:'_':' '|ucfirst}</span>
          <span class="badge bg-success">+{$offer.reward_value|string_format:'%.2f'}</span>
        </div>
        {if $offer.end_at}
        <div class="text-muted small mb-2">
          <i class="fas fa-clock me-1"></i>Expires: {$offer.end_at|date_format:'%b %d, %Y'}
        </div>
        {/if}

        {* Progress indicator *}
        {if !isset($claimed_ids[$offer.id]) && isset($elig)}
        <div class="mb-2">
          <div class="d-flex justify-content-between align-items-center mb-1">
            <span class="small text-muted">{$elig.label|escape}</span>
            <span class="small fw-semibold {if $elig.eligible}text-success{else}text-warning{/if}">{$elig.pct|default:0}%</span>
          </div>
          <div class="progress" style="height:6px">
            <div class="progress-bar {if $elig.eligible}bg-success{else}bg-warning{/if}"
                 style="width:{$elig.pct|default:0}%"></div>
          </div>
        </div>
        {/if}

        <div class="mt-auto pt-2">
          {if isset($claimed_ids[$offer.id])}
            <button class="btn btn-outline-success btn-sm w-100" disabled>
              <i class="fas fa-check me-1"></i>Claimed
            </button>
          {elseif isset($elig) && !$elig.eligible}
            <button class="btn btn-outline-secondary btn-sm w-100" disabled
                    title="Complete the task to unlock: {$elig.label|escape}">
              <i class="fas fa-lock me-1"></i>Task Incomplete
            </button>
          {else}
            <form method="POST" action="/user/rewards/claim">
              <input type="hidden" name="_csrf_token" value="{$csrf_token}">
              <input type="hidden" name="offer_id" value="{$offer.id}">
              <button type="submit" class="btn btn-warning btn-sm w-100 fw-semibold">
                <i class="fas fa-gift me-1"></i>Claim Reward
              </button>
            </form>
          {/if}
        </div>
      </div>
    </div>
  </div>
  {/foreach}
</div>
{else}
<div class="text-center text-muted py-5">
  <i class="fas fa-gift fa-3x mb-3 opacity-25"></i>
  <p>No active offers at the moment. Check back soon!</p>
</div>
{/if}

<!-- Expired Offers -->
{if $expired_offers}
<h6 class="fw-semibold text-muted mt-4 mb-3">Expired Offers</h6>
<div class="row g-3">
  {foreach $expired_offers as $offer}
  <div class="col-md-6 col-lg-4">
    <div class="card h-100 opacity-50">
      <div class="card-body">
        <h6 class="fw-bold mb-1">{$offer.title|escape}</h6>
        <span class="badge bg-secondary">Expired</span>
        {if $offer.end_at}
        <div class="text-muted small mt-1">Ended: {$offer.end_at|date_format:'%b %d, %Y'}</div>
        {/if}
      </div>
    </div>
  </div>
  {/foreach}
</div>
{/if}

{/block}
