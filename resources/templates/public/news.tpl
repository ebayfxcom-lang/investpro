{extends file="layouts/public.tpl"}
{block name="content"}
<section style="padding:5rem 0">
  <div class="container">
    <div class="text-center mb-5">
      <h1 class="fw-bold">Latest News</h1>
      <p class="text-muted">Stay up to date with platform updates and investment insights.</p>
    </div>
    <div class="row g-4">
      {foreach $items as $n}
      <div class="col-md-6 col-lg-4">
        <div class="card h-100 p-4">
          <div class="text-muted small mb-2">{$n.created_at|date_format:'%b %d, %Y'}</div>
          <h5 class="fw-bold mb-2">{$n.title|escape}</h5>
          <p class="text-muted small flex-grow-1">{$n.content|strip_tags|truncate:150}</p>
        </div>
      </div>
      {foreachelse}
      <div class="col-12 text-center text-muted py-5">No news articles available yet.</div>
      {/foreach}
    </div>
  </div>
</section>
{/block}
