{extends file="layouts/admin.tpl"}
{block name="content"}

<div class="d-flex justify-content-between align-items-center mb-3">
  <h6 class="fw-bold mb-0"><i class="fas fa-question-circle me-2 text-info"></i>FAQ Manager</h6>
  <button class="btn btn-accent btn-sm" data-bs-toggle="modal" data-bs-target="#createFaqModal">
    <i class="fas fa-plus me-1"></i>Add FAQ
  </button>
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
                <option value="{$cat}">{$cat|ucfirst}</option>
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
                <option value="{$cat}">{$cat|ucfirst}</option>
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

