{extends file="layouts/admin.tpl"}
{block name="content"}

<div class="card mb-3">
  <div class="card-body">
    <p class="text-muted mb-0">
      <i class="fas fa-info-circle me-1"></i>
      Select a user below to add funds to their account.
    </p>
  </div>
</div>

<div class="card">
  <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
    <h6 class="mb-0 fw-bold"><i class="fas fa-wallet me-2 text-warning"></i>Select User</h6>
    <form class="d-flex gap-2" method="GET" action="/admin/users/add-funds">
      <input type="text" name="search" class="form-control form-control-sm" placeholder="Search users..." value="{$search|escape}">
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
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {foreach $data.items as $u}
          <tr>
            <td class="text-muted small">{$u.id}</td>
            <td><strong>{$u.username|escape}</strong></td>
            <td class="text-muted">{$u.email|escape}</td>
            <td><span class="badge badge-status-{$u.status}">{$u.status|ucfirst}</span></td>
            <td>
              <a href="/admin/users/{$u.id}/add-funds" class="btn btn-sm btn-accent py-0 px-2">
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
  <div class="card-footer bg-white py-3 d-flex justify-content-between align-items-center">
    <div class="text-muted small">Showing {$data.items|@count} of {$data.total} users</div>
    <nav>
      <ul class="pagination pagination-sm mb-0">
        {section name=p loop=$data.total_pages start=1}
        <li class="page-item {if $smarty.section.p.index+1 == $data.page}active{/if}">
          <a class="page-link" href="?page={$smarty.section.p.index+1}{if $search}&search={$search|escape:'url'}{/if}">{$smarty.section.p.index+1}</a>
        </li>
        {/section}
      </ul>
    </nav>
  </div>
  {/if}
</div>

{/block}
