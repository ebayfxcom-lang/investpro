{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="row g-3">
  <div class="col-lg-4">
    <div class="card">
      <div class="card-header py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-search me-2 text-info"></i>Edit Page SEO</h6>
      </div>
      <div class="card-body">
        <form method="POST" action="/admin/seo" id="seoForm">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">
          <div class="mb-2">
            <label class="form-label fw-semibold small">Page</label>
            <select name="page_key" class="form-select form-select-sm" id="pageSelect" onchange="loadPage(this.value)">
              <option value="">-- Select Page --</option>
              {foreach $pages as $p}
              <option value="{$p.page_key}">{$p.page_label} ({$p.page_key})</option>
              {/foreach}
            </select>
          </div>
          <div class="mb-2">
            <label class="form-label fw-semibold small">Page Label</label>
            <input type="text" name="page_label" id="f_page_label" class="form-control form-control-sm">
          </div>
          <div class="mb-2">
            <label class="form-label fw-semibold small">Meta Title</label>
            <input type="text" name="meta_title" id="f_meta_title" class="form-control form-control-sm" maxlength="300">
          </div>
          <div class="mb-2">
            <label class="form-label fw-semibold small">Meta Description</label>
            <textarea name="meta_desc" id="f_meta_desc" class="form-control form-control-sm" rows="2"></textarea>
          </div>
          <div class="mb-2">
            <label class="form-label fw-semibold small">Meta Keywords</label>
            <input type="text" name="meta_keywords" id="f_meta_keywords" class="form-control form-control-sm">
          </div>
          <div class="mb-2">
            <label class="form-label fw-semibold small">OG Title</label>
            <input type="text" name="og_title" id="f_og_title" class="form-control form-control-sm" maxlength="300">
          </div>
          <div class="mb-2">
            <label class="form-label fw-semibold small">OG Description</label>
            <textarea name="og_desc" id="f_og_desc" class="form-control form-control-sm" rows="2"></textarea>
          </div>
          <div class="mb-2">
            <label class="form-label fw-semibold small">OG Image URL</label>
            <input type="url" name="og_image" id="f_og_image" class="form-control form-control-sm">
          </div>
          <div class="mb-2">
            <label class="form-label fw-semibold small">Canonical URL</label>
            <input type="url" name="canonical_url" id="f_canonical_url" class="form-control form-control-sm">
          </div>
          <div class="mb-2">
            <label class="form-label fw-semibold small">Schema JSON-LD</label>
            <textarea name="schema_json" id="f_schema_json" class="form-control form-control-sm" rows="3" placeholder='{"@context":"https://schema.org",...}'></textarea>
          </div>
          <div class="mb-2">
            <label class="form-label fw-semibold small">Admin Guide Text</label>
            <textarea name="admin_guide" id="f_admin_guide" class="form-control form-control-sm" rows="2" placeholder="Help text shown to admin on this page..."></textarea>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold small">User Guide Text</label>
            <textarea name="user_guide" id="f_user_guide" class="form-control form-control-sm" rows="2" placeholder="Help text shown to users on this page..."></textarea>
          </div>
          <button type="submit" class="btn btn-accent w-100">Save SEO Settings</button>
        </form>
      </div>
    </div>
  </div>

  <div class="col-lg-8">
    <div class="card">
      <div class="card-header py-3">
        <h6 class="mb-0 fw-bold">All Pages ({$pages|count})</h6>
      </div>
      <div class="card-body p-0">
        <div class="table-responsive">
          <table class="table mb-0">
            <thead>
              <tr><th>Page</th><th>Meta Title</th><th>OG Tags</th><th>Schema</th><th></th></tr>
            </thead>
            <tbody>
              {foreach $pages as $p}
              <tr>
                <td class="small fw-semibold">{$p.page_label}<br><span class="text-muted">{$p.page_key}</span></td>
                <td class="small">{if $p.meta_title}{$p.meta_title|escape|truncate:40}{else}<span class="text-muted">—</span>{/if}</td>
                <td class="small">{if $p.og_title}<i class="fas fa-check text-success"></i>{else}<span class="text-muted">—</span>{/if}</td>
                <td class="small">{if $p.schema_json}<i class="fas fa-check text-success"></i>{else}<span class="text-muted">—</span>{/if}</td>
                <td><button class="btn btn-sm btn-outline-secondary js-seo-edit" data-page-key="{$p.page_key|escape}">Edit</button></td>
              </tr>
              {foreachelse}
              <tr><td colspan="5" class="text-muted text-center py-4">No pages configured.</td></tr>
              {/foreach}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>
<script>
const pagesData = {$pages|json_encode};
document.addEventListener('click', function(e) {
  var btn = e.target.closest('.js-seo-edit');
  if (!btn) return;
  var key = btn.getAttribute('data-page-key');
  var p = pagesData.find(function(x) { return x.page_key === key; });
  if (p) fillForm(p);
});
function fillForm(p) {
  document.getElementById('pageSelect').value   = p.page_key       || '';
  document.getElementById('f_page_label').value  = p.page_label     || '';
  document.getElementById('f_meta_title').value  = p.meta_title     || '';
  document.getElementById('f_meta_desc').value   = p.meta_desc      || '';
  document.getElementById('f_meta_keywords').value = p.meta_keywords || '';
  document.getElementById('f_og_title').value    = p.og_title       || '';
  document.getElementById('f_og_desc').value     = p.og_desc        || '';
  document.getElementById('f_og_image').value    = p.og_image       || '';
  document.getElementById('f_canonical_url').value = p.canonical_url || '';
  document.getElementById('f_schema_json').value = p.schema_json    || '';
  document.getElementById('f_admin_guide').value = p.admin_guide    || '';
  document.getElementById('f_user_guide').value  = p.user_guide     || '';
}
function loadPage(key) {
  var p = pagesData.find(function(x){ return x.page_key === key; });
  if (p) fillForm(p);
}
</script>
{/block}
