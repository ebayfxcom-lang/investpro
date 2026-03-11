{extends file="layouts/admin.tpl"}
{block name="content"}

<div class="d-flex justify-content-between align-items-center mb-3">
  <h6 class="fw-bold mb-0"><i class="fas fa-question-circle me-2 text-info"></i>FAQ Manager</h6>
  <div class="d-flex gap-2">
    <button class="btn btn-outline-secondary btn-sm" data-bs-toggle="modal" data-bs-target="#manageCatsModal">
      <i class="fas fa-tags me-1"></i>Manage Categories
    </button>
    <button class="btn btn-accent btn-sm" data-bs-toggle="modal" data-bs-target="#createFaqModal">
      <i class="fas fa-plus me-1"></i>Add FAQ
    </button>
  </div>
</div>

<div class="card">
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead class="table-light">
          <tr>
            <th>#</th>
            <th>Question</th>
            <th>Category</th>
            <th>Order</th>
            <th>Status</th>
            <th class="text-end">Actions</th>
          </tr>
        </thead>
        <tbody>
          {if $faqs}
            {foreach $faqs as $f}
            <tr>
              <td class="text-muted small">{$f.id}</td>
              <td>
                <div class="fw-semibold">{$f.question|escape|truncate:80:'...'}</div>
                <div class="text-muted small">{$f.answer|escape|truncate:60:'...'}</div>
              </td>
              <td><span class="badge bg-secondary bg-opacity-25 text-dark">{$f.category|default:'general'|ucfirst}</span></td>
              <td>{$f.sort_order}</td>
              <td><span class="badge badge-status-{$f.status|default:'active'}">{$f.status|default:'active'|ucfirst}</span></td>
              <td class="text-end">
                <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#editFaqModal"
                  data-id="{$f.id}" data-question="{$f.question|escape:'html'}"
                  data-answer="{$f.answer|escape:'html'}"
                  data-category="{$f.category|default:'general'}"
                  data-sort="{$f.sort_order}" data-status="{$f.status|default:'active'}">
                  <i class="fas fa-pen"></i>
                </button>
                <form method="POST" action="/admin/faq" class="d-inline">
                  <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                  <input type="hidden" name="action" value="delete">
                  <input type="hidden" name="faq_id" value="{$f.id}">
                  <button type="submit" class="btn btn-sm btn-outline-danger"
                          onclick="return confirm('Delete this FAQ?')">
                    <i class="fas fa-trash"></i>
                  </button>
                </form>
              </td>
            </tr>
            {/foreach}
          {else}
            <tr><td colspan="6" class="text-center text-muted py-5">No FAQ items yet. Click "Add FAQ" to create one.</td></tr>
          {/if}
        </tbody>
      </table>
    </div>
  </div>
</div>

{* Manage Categories Modal *}
<div class="modal fade" id="manageCatsModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title fw-bold"><i class="fas fa-tags me-2"></i>Manage FAQ Categories</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        {* Existing categories *}
        <h6 class="fw-semibold mb-3">Current Categories</h6>
        {if $categories}
        <div class="list-group mb-4">
          {foreach $categories as $cat}
          {if $cat.id}
          <div class="list-group-item d-flex justify-content-between align-items-center py-2">
            <div>
              <span class="fw-semibold">{$cat.name|escape}</span>
              <span class="text-muted small ms-2">/{$cat.slug|escape}</span>
              {if $cat.status == 'inactive'}<span class="badge bg-secondary ms-2">Inactive</span>{/if}
            </div>
            <div class="d-flex gap-1">
              <form method="POST" action="/admin/faq" class="d-inline">
                <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                <input type="hidden" name="action" value="toggle_category">
                <input type="hidden" name="category_id" value="{$cat.id}">
                <button type="submit" class="btn btn-xs btn-outline-{if $cat.status == 'active'}warning{else}success{/if} py-0 px-2 btn-sm">
                  {if $cat.status == 'active'}Disable{else}Enable{/if}
                </button>
              </form>
              <form method="POST" action="/admin/faq" class="d-inline">
                <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                <input type="hidden" name="action" value="delete_category">
                <input type="hidden" name="category_id" value="{$cat.id}">
                <button type="submit" class="btn btn-xs btn-outline-danger py-0 px-2 btn-sm"
                        onclick="return confirm('Delete this category?')">
                  <i class="fas fa-trash"></i>
                </button>
              </form>
            </div>
          </div>
          {else}
          <div class="list-group-item d-flex justify-content-between align-items-center py-2">
            <span class="text-muted">{$cat.name|escape} <small>(built-in)</small></span>
          </div>
          {/if}
          {/foreach}
        </div>
        {/if}

        {* Add new category *}
        <h6 class="fw-semibold mb-3">Add New Category</h6>
        <form method="POST" action="/admin/faq">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">
          <input type="hidden" name="action" value="create_category">
          <div class="input-group">
            <input type="text" name="cat_name" class="form-control" placeholder="Category name..." required>
            <input type="number" name="cat_sort_order" class="form-control" placeholder="Order" value="0" style="max-width:80px">
            <button type="submit" class="btn btn-accent"><i class="fas fa-plus"></i></button>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>

{* Create FAQ Modal *}
<div class="modal fade" id="createFaqModal" tabindex="-1">
  <div class="modal-dialog modal-lg">
    <form method="POST" action="/admin/faq">
      <input type="hidden" name="_csrf_token" value="{$csrf_token}">
      <input type="hidden" name="action" value="create">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title fw-bold">Add FAQ Item</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label class="form-label fw-semibold">Question <span class="text-danger">*</span></label>
            <input type="text" name="question" class="form-control" required placeholder="Enter the question...">
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Answer <span class="text-danger">*</span></label>
            <textarea name="answer" class="form-control" rows="4" required placeholder="Enter the answer..."></textarea>
          </div>
          <div class="row g-3">
            <div class="col-md-4">
              <label class="form-label fw-semibold">Category</label>
              <select name="category" class="form-select">
                {foreach $categories as $cat}
                <option value="{if $cat.slug}{$cat.slug}{else}{$cat}{/if}">
                  {if $cat.name}{$cat.name|escape}{else}{$cat|ucfirst}{/if}
                </option>
                {/foreach}
              </select>
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Sort Order</label>
              <input type="number" name="sort_order" class="form-control" value="0" min="0">
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Status</label>
              <select name="status" class="form-select">
                <option value="active">Active</option>
                <option value="inactive">Inactive</option>
              </select>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
          <button type="submit" class="btn btn-accent"><i class="fas fa-save me-1"></i>Save FAQ</button>
        </div>
      </div>
    </form>
  </div>
</div>

{* Edit FAQ Modal *}
<div class="modal fade" id="editFaqModal" tabindex="-1">
  <div class="modal-dialog modal-lg">
    <form method="POST" action="/admin/faq">
      <input type="hidden" name="_csrf_token" value="{$csrf_token}">
      <input type="hidden" name="action" value="update">
      <input type="hidden" name="faq_id" id="editFaqId">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title fw-bold">Edit FAQ Item</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label class="form-label fw-semibold">Question <span class="text-danger">*</span></label>
            <input type="text" name="question" id="editFaqQuestion" class="form-control" required>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Answer <span class="text-danger">*</span></label>
            <textarea name="answer" id="editFaqAnswer" class="form-control" rows="4" required></textarea>
          </div>
          <div class="row g-3">
            <div class="col-md-4">
              <label class="form-label fw-semibold">Category</label>
              <select name="category" id="editFaqCategory" class="form-select">
                {foreach $categories as $cat}
                <option value="{if $cat.slug}{$cat.slug}{else}{$cat}{/if}">
                  {if $cat.name}{$cat.name|escape}{else}{$cat|ucfirst}{/if}
                </option>
                {/foreach}
              </select>
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Sort Order</label>
              <input type="number" name="sort_order" id="editFaqSort" class="form-control" min="0">
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Status</label>
              <select name="status" id="editFaqStatus" class="form-select">
                <option value="active">Active</option>
                <option value="inactive">Inactive</option>
              </select>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
          <button type="submit" class="btn btn-accent"><i class="fas fa-save me-1"></i>Update FAQ</button>
        </div>
      </div>
    </form>
  </div>
</div>

<script>
(function () {
  document.getElementById('editFaqModal').addEventListener('show.bs.modal', function (e) {
    const btn = e.relatedTarget;
    document.getElementById('editFaqId').value       = btn.dataset.id;
    document.getElementById('editFaqQuestion').value = btn.dataset.question;
    document.getElementById('editFaqAnswer').value   = btn.dataset.answer;
    document.getElementById('editFaqCategory').value = btn.dataset.category;
    document.getElementById('editFaqSort').value     = btn.dataset.sort;
    document.getElementById('editFaqStatus').value   = btn.dataset.status;
  });
}());
</script>
{/block}
