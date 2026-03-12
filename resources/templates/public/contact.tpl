{extends file="layouts/public.tpl"}
{block name="content"}
<section style="padding:5rem 0">
  <div class="container">
    <div class="row justify-content-center">
      <div class="col-lg-6">
        <div class="text-center mb-5">
          <h1 class="fw-bold">Contact Us</h1>
          <p class="text-muted">Have a question? We're here to help.</p>
        </div>
        <div class="card p-4">
          <p class="text-muted mb-4 text-center">
            <i class="fas fa-headset fa-2x mb-3 d-block" style="color:var(--pub-primary)"></i>
            For support, please <a href="/login">log in</a> and open a support ticket, or register a new account to get started.
          </p>
          <div class="d-flex gap-2 justify-content-center">
            <a href="/login" class="btn btn-outline-primary">Sign In</a>
            <a href="/register" class="btn btn-primary">Create Account</a>
          </div>
        </div>
      </div>
    </div>
  </div>
</section>
{/block}
