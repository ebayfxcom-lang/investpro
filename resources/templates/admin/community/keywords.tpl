{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="row g-3">
  <div class="col-md-4">
    <div class="card">
      <div class="card-header py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-ban me-2 text-danger"></i>Add Restricted Keyword</h6>
      </div>
      <div class="card-body">
        <form method="POST" action="/admin/community/keywords">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">
          <input type="hidden" name="action" value="add">
          <div class="mb-2">
            <input type="text" name="keyword" class="form-control form-control-sm"
                   placeholder="e.g. spam, fraud" required maxlength="200">
          </div>
          <button type="submit" class="btn btn-danger btn-sm w-100">Add Keyword</button>
        </form>
      </div>
    </div>
  </div>
  <div class="col-md-8">
    <div class="card">
      <div class="card-header py-3">
        <h6 class="mb-0 fw-bold">Restricted Keywords ({$keywords|count})</h6>
      </div>
      <div class="card-body p-0">
        <ul class="list-group list-group-flush">
          {foreach $keywords as $kw}
          <li class="list-group-item d-flex justify-content-between align-items-center">
            <code>{$kw.keyword|escape}</code>
            <form method="POST" action="/admin/community/keywords" class="d-inline">
              <input type="hidden" name="_csrf_token" value="{$csrf_token}">
              <input type="hidden" name="action" value="delete">
              <input type="hidden" name="keyword_id" value="{$kw.id}">
              <button type="submit" class="btn btn-sm btn-outline-danger"
                      onclick="return confirm('Remove keyword?')">
                <i class="fas fa-trash"></i>
              </button>
            </form>
          </li>
          {foreachelse}
          <li class="list-group-item text-muted text-center py-4">No restricted keywords.</li>
          {/foreach}
        </ul>
      </div>
    </div>
  </div>
</div>
{/block}
