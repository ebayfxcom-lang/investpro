{extends file="layouts/public.tpl"}
{block name="content"}
<!-- Hero -->
<section class="hero">
  <div class="container text-center">
    <div class="hero-badge"><i class="fas fa-shield-halved me-1"></i>Trusted Investment Platform</div>
    <h1 class="display-4 fw-bold mb-3">{$app.name}</h1>
    <p class="lead text-muted mb-5">Grow your wealth with our professional investment plans. Transparent, secure, and reliable.</p>
    <div class="d-flex gap-3 justify-content-center">
      <a href="/register" class="btn btn-primary btn-lg px-5">Start Investing</a>
      <a href="/plans" class="btn btn-outline-primary btn-lg px-5">View Plans</a>
    </div>
    <div class="row g-4 mt-5 justify-content-center">
      <div class="col-md-3 col-6">
        <div class="stat-block">
          <div class="stat-num">$1M+</div>
          <div class="small text-muted">Total Invested</div>
        </div>
      </div>
      <div class="col-md-3 col-6">
        <div class="stat-block">
          <div class="stat-num">5,000+</div>
          <div class="small text-muted">Active Investors</div>
        </div>
      </div>
      <div class="col-md-3 col-6">
        <div class="stat-block">
          <div class="stat-num">99.9%</div>
          <div class="small text-muted">Uptime</div>
        </div>
      </div>
      <div class="col-md-3 col-6">
        <div class="stat-block">
          <div class="stat-num">24/7</div>
          <div class="small text-muted">Support</div>
        </div>
      </div>
    </div>
  </div>
</section>

<!-- Features -->
<section class="section-alt" style="padding:5rem 0">
  <div class="container">
    <div class="text-center mb-5">
      <h2 class="fw-bold">Why Choose {$app.name}?</h2>
      <p class="text-muted">Everything you need to invest with confidence.</p>
    </div>
    <div class="row g-4">
      <div class="col-md-4">
        <div class="d-flex gap-3">
          <div class="feature-icon flex-shrink-0"><i class="fas fa-shield-halved"></i></div>
          <div>
            <h5 class="fw-bold">Bank-Grade Security</h5>
            <p class="text-muted small">Multi-layer security with 2FA, KYC, and encrypted data protection.</p>
          </div>
        </div>
      </div>
      <div class="col-md-4">
        <div class="d-flex gap-3">
          <div class="feature-icon flex-shrink-0"><i class="fas fa-chart-line"></i></div>
          <div>
            <h5 class="fw-bold">Consistent Returns</h5>
            <p class="text-muted small">Predictable ROI with transparent plans and daily earnings tracking.</p>
          </div>
        </div>
      </div>
      <div class="col-md-4">
        <div class="d-flex gap-3">
          <div class="feature-icon flex-shrink-0"><i class="fas fa-bolt"></i></div>
          <div>
            <h5 class="fw-bold">Fast Withdrawals</h5>
            <p class="text-muted small">Quick and reliable crypto withdrawals processed by our team.</p>
          </div>
        </div>
      </div>
      <div class="col-md-4">
        <div class="d-flex gap-3">
          <div class="feature-icon flex-shrink-0"><i class="fas fa-share-nodes"></i></div>
          <div>
            <h5 class="fw-bold">Referral Earnings</h5>
            <p class="text-muted small">Earn commissions by referring friends to our platform.</p>
          </div>
        </div>
      </div>
      <div class="col-md-4">
        <div class="d-flex gap-3">
          <div class="feature-icon flex-shrink-0"><i class="fas fa-headset"></i></div>
          <div>
            <h5 class="fw-bold">24/7 Support</h5>
            <p class="text-muted small">Our dedicated team is here to help you anytime.</p>
          </div>
        </div>
      </div>
      <div class="col-md-4">
        <div class="d-flex gap-3">
          <div class="feature-icon flex-shrink-0"><i class="fas fa-globe"></i></div>
          <div>
            <h5 class="fw-bold">Global Access</h5>
            <p class="text-muted small">Available worldwide with multi-currency support.</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</section>

<!-- Plans -->
{if $plans}
<section style="padding:5rem 0">
  <div class="container">
    <div class="text-center mb-5">
      <h2 class="fw-bold">Investment Plans</h2>
      <p class="text-muted">Choose the plan that works for you.</p>
    </div>
    <div class="row g-4 justify-content-center">
      {foreach $plans as $plan}
      <div class="col-md-4">
        <div class="card plan-card h-100 text-center p-4 {if $plan@iteration == 2}featured{/if}">
          {if $plan@iteration == 2}<div class="plan-badge badge mb-3">Most Popular</div>{/if}
          <h4 class="fw-bold mb-2">{$plan.name|escape}</h4>
          <div class="display-5 fw-bold my-3" style="color:var(--pub-primary)">{$plan.roi_percent}%
            <span class="fs-6 text-muted fw-normal">/{$plan.roi_period}</span>
          </div>
          <div class="text-muted small mb-4">
            <div>Min: ${$plan.min_amount|string_format:'%.0f'}</div>
            {if $plan.max_amount > 0}<div>Max: ${$plan.max_amount|string_format:'%.0f'}</div>{/if}
            <div>Duration: {$plan.duration_days} days</div>
          </div>
          <a href="/register" class="btn btn-primary w-100">Get Started</a>
        </div>
      </div>
      {/foreach}
    </div>
  </div>
</section>
{/if}

<!-- News -->
{if $news}
<section class="section-alt" style="padding:5rem 0">
  <div class="container">
    <div class="text-center mb-5">
      <h2 class="fw-bold">Latest News</h2>
    </div>
    <div class="row g-4">
      {foreach $news as $n}
      <div class="col-md-4">
        <div class="card h-100 p-4">
          <div class="text-muted small mb-2">{$n.created_at|date_format:'%b %d, %Y'}</div>
          <h5 class="fw-bold mb-2">{$n.title|escape}</h5>
          <p class="text-muted small">{$n.content|strip_tags|truncate:120}</p>
        </div>
      </div>
      {/foreach}
    </div>
  </div>
</section>
{/if}

<!-- CTA -->
<section style="padding:5rem 0">
  <div class="container text-center">
    <h2 class="fw-bold mb-3">Ready to Start Earning?</h2>
    <p class="text-muted mb-4">Join thousands of investors already growing their wealth.</p>
    <a href="/register" class="btn btn-primary btn-lg px-5">Create Free Account</a>
  </div>
</section>
{/block}
