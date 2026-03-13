<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  {if isset($seo) && $seo}
  <title>{$seo.meta_title|default:$title|default:$app.name} | {$app.name}</title>
  {if $seo.meta_desc}<meta name="description" content="{$seo.meta_desc|escape}">{/if}
  {if $seo.meta_keywords}<meta name="keywords" content="{$seo.meta_keywords|escape}">{/if}
  {if $seo.canonical_url}<link rel="canonical" href="{$seo.canonical_url|escape}">{/if}
  {if $seo.og_title}<meta property="og:title" content="{$seo.og_title|escape}">{/if}
  {if $seo.og_desc}<meta property="og:description" content="{$seo.og_desc|escape}">{/if}
  {if $seo.og_image}<meta property="og:image" content="{$seo.og_image|escape}">{/if}
  {if $seo.schema_json}
  <script type="application/ld+json">{$seo.schema_json}</script>
  {/if}
  {else}
  <title>{$title|default:$app.name} | {$app.name}</title>
  {/if}
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
  <style>
    :root {
      --pub-primary: #f0b90b;
      --pub-dark: #0d1117;
      --pub-card: #161b22;
      --pub-text: #e6edf3;
      --pub-muted: #8b949e;
      --pub-border: rgba(255,255,255,.07);
    }
    body { background: var(--pub-dark); color: var(--pub-text); font-family: 'Segoe UI', sans-serif; }
    .navbar { background: rgba(22,27,34,.95); backdrop-filter: blur(10px); border-bottom: 1px solid var(--pub-border); }
    .navbar-brand { color: var(--pub-primary) !important; font-weight: 700; font-size: 1.4rem; }
    .nav-link { color: rgba(255,255,255,.75) !important; }
    .nav-link:hover { color: var(--pub-primary) !important; }
    .btn-primary { background: var(--pub-primary); border-color: var(--pub-primary); color: #000; font-weight: 600; }
    .btn-primary:hover { background: #d97706; border-color: #d97706; color: #000; }
    .btn-outline-primary { border-color: var(--pub-primary); color: var(--pub-primary); }
    .btn-outline-primary:hover { background: var(--pub-primary); color: #000; }
    .card { background: var(--pub-card); border: 1px solid var(--pub-border); color: var(--pub-text); }
    .text-muted { color: var(--pub-muted) !important; }
    footer { background: #0a0e14; border-top: 1px solid var(--pub-border); color: var(--pub-muted); }
    .hero { background: linear-gradient(135deg, #0d1117 0%, #161b22 100%); padding: 100px 0; }
    .hero-badge { background: rgba(240,185,11,.1); border: 1px solid rgba(240,185,11,.3); color: var(--pub-primary); display: inline-block; padding: .3rem 1rem; border-radius: 20px; font-size: .85rem; margin-bottom: 1.5rem; }
    .stat-block { text-align: center; padding: 2rem; }
    .stat-num { font-size: 2.5rem; font-weight: 700; color: var(--pub-primary); }
    .feature-icon { width: 60px; height: 60px; background: rgba(240,185,11,.1); border-radius: 16px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; color: var(--pub-primary); margin-bottom: 1rem; }
    .plan-card { border: 2px solid var(--pub-border); transition: border-color .2s; }
    .plan-card:hover, .plan-card.featured { border-color: var(--pub-primary); }
    .plan-badge { background: var(--pub-primary); color: #000; font-weight: 700; }
    a { color: var(--pub-primary); }
    a:hover { color: #d97706; }
    .section-alt { background: rgba(22,27,34,.5); }
  </style>
</head>
<body>
<nav class="navbar navbar-expand-lg sticky-top">
  <div class="container">
    <a class="navbar-brand" href="/">{$app.name}</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navMenu">
      <i class="fas fa-bars text-warning"></i>
    </button>
    <div class="collapse navbar-collapse" id="navMenu">
      <ul class="navbar-nav ms-auto gap-1">
        <li class="nav-item"><a class="nav-link" href="/">Home</a></li>
        <li class="nav-item"><a class="nav-link" href="/about">About</a></li>
        <li class="nav-item"><a class="nav-link" href="/plans">Plans</a></li>
        <li class="nav-item"><a class="nav-link" href="/news">News</a></li>
        <li class="nav-item"><a class="nav-link" href="/community">Community</a></li>
        <li class="nav-item"><a class="nav-link" href="/payout-proofs">Payout Proofs</a></li>
        <li class="nav-item"><a class="nav-link" href="/faq">FAQ</a></li>
        <li class="nav-item"><a class="nav-link" href="/contact">Contact</a></li>
      </ul>
      <div class="d-flex gap-2 ms-3">
        <a href="/login" class="btn btn-outline-primary btn-sm">Sign In</a>
        <a href="/register" class="btn btn-primary btn-sm">Get Started</a>
      </div>
    </div>
  </div>
</nav>

{block name="content"}{/block}

<footer class="py-5 mt-5">
  <div class="container">
    <div class="row g-4">
      <div class="col-md-4">
        <div class="fs-5 fw-bold mb-2" style="color:var(--pub-primary)">{$app.name}</div>
        <p class="small">A professional investment platform built for growth, security, and transparency.</p>
      </div>
      <div class="col-md-2">
        <div class="fw-semibold mb-3">Platform</div>
        <ul class="list-unstyled small">
          <li class="mb-1"><a href="/plans" class="text-decoration-none">Plans</a></li>
          <li class="mb-1"><a href="/about" class="text-decoration-none">About Us</a></li>
          <li class="mb-1"><a href="/faq" class="text-decoration-none">FAQ</a></li>
          <li class="mb-1"><a href="/news" class="text-decoration-none">News</a></li>
        </ul>
      </div>
      <div class="col-md-2">
        <div class="fw-semibold mb-3">Account</div>
        <ul class="list-unstyled small">
          <li class="mb-1"><a href="/register" class="text-decoration-none">Register</a></li>
          <li class="mb-1"><a href="/login" class="text-decoration-none">Login</a></li>
          <li class="mb-1"><a href="/user/support" class="text-decoration-none">Support</a></li>
        </ul>
      </div>
      <div class="col-md-4">
        <div class="fw-semibold mb-3">Newsletter</div>
        <form action="/newsletter/subscribe" method="POST" class="d-flex gap-2">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">
          <input type="email" name="email" class="form-control form-control-sm" placeholder="Your email" required>
          <button type="submit" class="btn btn-primary btn-sm text-nowrap">Subscribe</button>
        </form>
        <p class="small text-muted mt-2">Stay updated with investment tips and offers.</p>
      </div>
    </div>
    <hr style="border-color:var(--pub-border)">
    <div class="text-center small text-muted">
      &copy; {$smarty.now|date_format:'%Y'} {$app.name}. All rights reserved.
    </div>
  </div>
</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
