{extends file="layouts/admin.tpl"}
{block name="content"}

<div class="d-flex justify-content-between align-items-center mb-4">
  <div></div>
  <button class="btn btn-accent" data-bs-toggle="modal" data-bs-target="#addModal">
    <i class="fas fa-plus me-1"></i> Add to Blacklist
  </button>
</div>

<div class="card">
  <div class="card-header bg-white py-3">
    <h6 class="mb-0 fw-bold"><i class="fas fa-ban me-2 text-danger"></i>Blacklist Entries</h6>
  </div>
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead class="table-light">
          <tr>
            <th>#</th>
            <th>Type</th>
            <th>Value</th>
            <th>Reason</th>
            <th>Expires</th>
            <th>Added</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {foreach $data.items as $b}
          <tr>
            <td class="text-muted small">{$b.id}</td>
            <td><span class="badge bg-secondary">{$b.type|ucfirst|escape}</span></td>
            <td class="fw-semibold font-monospace">{$b.value|escape}</td>
            <td class="text-muted">{$b.reason|escape|default:'—'}</td>
            <td class="text-muted small">{if $b.expires_at}{$b.expires_at|date_format:'%b %d, %Y'}{else}Never{/if}</td>
            <td class="text-muted small">{$b.created_at|date_format:'%b %d, %Y'}</td>
            <td>
              <form method="POST" action="/admin/blacklist/{$b.id}/remove" class="d-inline">
                <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                <button type="submit" class="btn btn-sm btn-outline-danger py-0 px-2"
                  onclick="return confirm('Remove this blacklist entry?')">Remove</button>
              </form>
            </td>
          </tr>
          {foreachelse}
          <tr><td colspan="7" class="text-center text-muted py-4">No blacklist entries found.</td></tr>
          {/foreach}
        </tbody>
      </table>
    </div>
  </div>
  {if $data.total_pages > 1}
  <div class="card-footer bg-white py-3 d-flex justify-content-between align-items-center">
    <div class="text-muted small">Showing {$data.items|@count} of {$data.total} entries</div>
    <nav>
      <ul class="pagination pagination-sm mb-0">
        {section name=p loop=$data.total_pages start=1}
        <li class="page-item {if $smarty.section.p.index+1 == $data.page}active{/if}">
          <a class="page-link" href="?page={$smarty.section.p.index+1}">{$smarty.section.p.index+1}</a>
        </li>
        {/section}
      </ul>
    </nav>
  </div>
  {/if}
</div>

<!-- Add to Blacklist Modal -->
<div class="modal fade" id="addModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <form method="POST" action="/admin/blacklist/add">
        <input type="hidden" name="_csrf_token" value="{$csrf_token}">
        <div class="modal-header">
          <h5 class="modal-title"><i class="fas fa-ban me-2"></i>Add to Blacklist</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label class="form-label fw-semibold">Type</label>
            <select name="type" class="form-select" required>
              <option value="ip">IP Address</option>
              <option value="email">Email</option>
              <option value="username">Username</option>
            </select>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Value</label>
            <input type="text" name="value" class="form-control" placeholder="e.g. 192.168.1.1" required>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Reason <span class="text-muted fw-normal">(optional)</span></label>
            <input type="text" name="reason" class="form-control" placeholder="Reason for blacklisting">
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Expires At <span class="text-muted fw-normal">(optional)</span></label>
            <input type="datetime-local" name="expires_at" class="form-control">
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
          <button type="submit" class="btn btn-accent">Add Entry</button>
        </div>
      </form>
    </div>
  </div>
</div>

{/block}
