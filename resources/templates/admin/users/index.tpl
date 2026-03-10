{extends file="layouts/admin.tpl"}
{block name="content"}

<div class="card">
  <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
    <h6 class="mb-0 fw-bold"><i class="fas fa-users me-2 text-primary"></i>Users Management</h6>
    <form class="d-flex gap-2" method="GET" action="/admin/users">
      <input type="text" name="search" class="form-control form-control-sm" placeholder="Search users..." value="{$search|escape}">
      <button type="submit" class="btn btn-sm btn-primary">Search</button>
      {if $search}<a href="/admin/users" class="btn btn-sm btn-outline-secondary">Clear</a>{/if}
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
            <th>Role</th>
            <th>Status</th>
            <th>Joined</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {foreach $data.items as $u}
          <tr>
            <td class="text-muted small">{$u.id}</td>
            <td>
              <div class="d-flex align-items-center gap-2">
                <div class="bg-primary bg-opacity-10 text-primary rounded-circle d-flex align-items-center justify-content-center fw-bold" style="width:34px;height:34px;font-size:.8rem;">
                  {$u.username|upper|truncate:1:''}
                </div>
                <div>
                  <strong>{$u.username|escape}</strong>
                  {if $u.referred_by}<div class="text-muted" style="font-size:.7rem;">Referred</div>{/if}
                </div>
              </div>
            </td>
            <td class="text-muted">{$u.email|escape}</td>
            <td><span class="badge bg-secondary bg-opacity-25 text-dark">{$u.role|ucfirst}</span></td>
            <td><span class="badge badge-status-{$u.status}">{$u.status|ucfirst}</span></td>
            <td class="text-muted small">{$u.created_at|date_format:'%b %d, %Y'}</td>
            <td>
              <div class="d-flex gap-1">
                <a href="/admin/users/{$u.id}" class="btn btn-sm btn-outline-primary py-0 px-2">View</a>
                <form method="POST" action="/admin/users/{$u.id}/toggle-status" class="d-inline">
                  <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                  <button type="submit" class="btn btn-sm btn-outline-{if $u.status == 'active'}danger{else}success{/if} py-0 px-2"
                    onclick="return confirm('Change status?')">{if $u.status == 'active'}Ban{else}Activate{/if}</button>
                </form>
              </div>
            </td>
          </tr>
          {foreachelse}
          <tr><td colspan="7" class="text-center text-muted py-4">No users found.</td></tr>
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
