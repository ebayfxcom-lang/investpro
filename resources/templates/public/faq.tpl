{extends file="layouts/public.tpl"}
{block name="content"}
<section style="padding:5rem 0">
  <div class="container">
    <div class="text-center mb-5">
      <h1 class="fw-bold">Frequently Asked Questions</h1>
      <p class="text-muted">Find answers to common questions about our platform.</p>
    </div>
    {if $items}
    <div class="accordion" id="faqAccordion">
      {foreach $items as $faq}
      <div class="accordion-item mb-2 border-0" style="background:var(--pub-card);border-radius:8px!important">
        <h2 class="accordion-header">
          <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq{$faq.id}"
                  style="background:var(--pub-card);color:var(--pub-text)">
            {$faq.question|escape}
          </button>
        </h2>
        <div id="faq{$faq.id}" class="accordion-collapse collapse" data-bs-parent="#faqAccordion">
          <div class="accordion-body text-muted">{$faq.answer|escape}</div>
        </div>
      </div>
      {foreachelse}
      <p class="text-muted text-center py-5">No FAQ items available yet.</p>
      {/foreach}
    </div>
    {/if}
  </div>
</section>
{/block}
