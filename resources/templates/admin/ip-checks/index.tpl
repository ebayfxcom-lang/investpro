{extends file="layouts/admin.tpl"}
{block name="content"}

<div class="card mb-4">
  <div class="card-header bg-white py-3">
    <h6 class="mb-0 fw-bold"><i class="fas fa-search me-2 text-primary"></i>Check IP Address</h6>
  </div>
  <div class="card-body">
    <form class="d-flex gap-2" method="GET" action="/admin/ip-checks">
      <input type="text" name="q" class="form-control" placeholder="Enter IP address to check..." value="{$query|escape}">
      <button type="submit" class="btn btn-primary px-4">Check</button>
    </form>
    {if $result}
    <div class="mt-3 alert {if $result.status == 'blocked'}alert-danger{else}alert-success{/if}">
      <i class="fas {if $result.status == 'blocked'}fa-ban{else}fa-check-circle{/if} me-2"></i>
      IP <strong>{$result.ip|escape}</strong> is
      {if $result.status == 'blocked'}<strong>BLOCKED</strong>{else}<strong>clean</strong> (not blacklisted){/if}.
    </div>
    {/if}
  </div>
</div>

<div class="d-flex justify-content-between align-items-center mb-3">
  <h6 class="fw-bold mb-0"><i class="fas fa-globe me-2"></i>Blocked IPs</h6>
  <button class="btn btn-accent btn-sm" data-bs-toggle="modal" data-bs-target="#blockModal">
    <i class="fas fa-plus me-1"></i> Block IP
  </button>
</div>

<div class="card">
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead class="table-light">
          <tr>
            <th>#</th>
            <th>IP Address</th>
            <th>Reason</th>
            <th>Expires</th>
            <th>Blocked On</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {foreach $data.items as $b}
          <tr>
            <td class="text-muted small">{$b.id}</td>
            <td class="fw-semibold font-monospace">{$b.value|escape}</td>
            <td class="text-muted">{$b.reason|escape|default:'—'}</td>
            <td class="text-muted small">{if $b.expires_at}{$b.expires_at|date_format:'%b %d, %Y'}{else}Never{/if}</td>
            <td class="text-muted small">{$b.created_at|date_format:'%b %d, %Y'}</td>
            <td>
              <form method="POST" action="/admin/ip-checks/{$b.id}/unblock" class="d-inline">
                <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                <button type="submit" class="btn btn-sm btn-outline-success py-0 px-2"
                  onclick="return confirm('Unblock this IP?')">Unblock</button>
              </form>
            </td>
          </tr>
          {foreachelse}
          <tr><td colspan="6" class="text-center text-muted py-4">No blocked IPs found.</td></tr>
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

<!-- Block IP Modal -->
<div class="modal fade" id="blockModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <form method="POST" action="/admin/ip-checks/block">
        <input type="hidden" name="_csrf_token" value="{$csrf_token}">
        <div class="modal-header">
          <h5 class="modal-title"><i class="fas fa-ban me-2"></i>Block IP Address</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <div class="mb-3">
            <label class="form-label fw-semibold">IP Address</label>
            <input type="text" name="ip" class="form-control font-monospace" placeholder="e.g. 192.168.1.1" required>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Reason <span class="text-muted fw-normal">(optional)</span></label>
            <input type="text" name="reason" class="form-control" placeholder="Reason for blocking">
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
          <button type="submit" class="btn btn-danger">Block IP</button>
        </div>
      </form>
    </div>
  </div>
</div>

{/block}
