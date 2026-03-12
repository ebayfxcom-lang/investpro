{extends file="layouts/public.tpl"}
{block name="content"}
<section style="padding:5rem 0">
  <div class="container">
    <div class="row justify-content-center">
      <div class="col-lg-8 text-center mb-5">
        <h1 class="fw-bold">About {$app.name}</h1>
        <p class="text-muted lead">We are a professional investment platform committed to helping you grow your wealth safely and transparently.</p>
      </div>
    </div>
    <div class="row g-4 mt-3">
      <div class="col-md-6">
        <div class="card p-4 h-100">
          <div class="feature-icon mb-3"><i class="fas fa-bullseye"></i></div>
          <h5 class="fw-bold">Our Mission</h5>
          <p class="text-muted">To provide every person with access to professional-grade investment tools, transparent earnings, and reliable payouts.</p>
        </div>
      </div>
      <div class="col-md-6">
        <div class="card p-4 h-100">
          <div class="feature-icon mb-3"><i class="fas fa-eye"></i></div>
          <h5 class="fw-bold">Our Vision</h5>
          <p class="text-muted">A world where financial growth is accessible, secure, and rewarding for everyone regardless of background.</p>
        </div>
      </div>
    </div>
  </div>
</section>
{/block}
