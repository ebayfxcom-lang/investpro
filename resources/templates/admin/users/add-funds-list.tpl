{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="card">
  <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
    <h6 class="mb-0 fw-bold"><i class="fas fa-wallet me-2 text-success"></i>Add Funds — Select User</h6>
    <form class="d-flex gap-2" method="GET" action="/admin/users/add-funds">
      <input type="text" name="search" class="form-control form-control-sm" placeholder="Search users..."
             value="{$search|escape}">
      <button type="submit" class="btn btn-sm btn-primary">Search</button>
      {if $search}<a href="/admin/users/add-funds" class="btn btn-sm btn-outline-secondary">Clear</a>{/if}
    </form>
  </div>
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead class="table-light">
          <tr>
            <th>#</th>
            <th>User</th>
            <th>Email</th>
            <th>Status</th>
            <th class="text-end">Action</th>
          </tr>
        </thead>
        <tbody>
          {foreach $data.items as $u}
          <tr>
            <td class="text-muted small">{$u.id}</td>
            <td class="fw-semibold">{$u.username|escape}</td>
            <td class="text-muted">{$u.email|escape}</td>
            <td><span class="badge badge-status-{$u.status}">{$u.status|ucfirst}</span></td>
            <td class="text-end">
              <a href="/admin/users/{$u.id}/add-funds" class="btn btn-sm btn-success">
                <i class="fas fa-plus me-1"></i>Add Funds
              </a>
            </td>
          </tr>
          {foreachelse}
          <tr><td colspan="5" class="text-center text-muted py-4">No users found.</td></tr>
          {/foreach}
        </tbody>
      </table>
    </div>
  </div>
  {if $data.total_pages > 1}
  <div class="card-footer bg-white d-flex justify-content-between align-items-center py-3">
    <div class="text-muted small">Showing {$data.items|@count} of {$data.total} users</div>
    <nav><ul class="pagination pagination-sm mb-0">
      {for $p = 1 to $data.total_pages}
      <li class="page-item {if $p == $data.page}active{/if}">
        <a class="page-link" href="?page={$p}{if $search}&search={$search|escape:'url'}{/if}">{$p}</a>
      </li>
      {/for}
    </ul></nav>
  </div>
  {/if}
</div>
{/block}
