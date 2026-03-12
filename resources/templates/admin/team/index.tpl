{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="card">
  <div class="card-header py-3 d-flex justify-content-between align-items-center">
    <h6 class="mb-0 fw-bold"><i class="fas fa-users-gear me-2 text-warning"></i>Team Roles</h6>
    <a href="/admin/team/members" class="btn btn-sm btn-outline-secondary">Manage Members</a>
  </div>
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table mb-0">
        <thead>
          <tr><th>#</th><th>Role Name</th><th>Label</th><th>System</th><th>Actions</th></tr>
        </thead>
        <tbody>
          {foreach $roles as $r}
          <tr>
            <td class="small text-muted">{$r.id}</td>
            <td class="small fw-semibold"><code>{$r.name}</code></td>
            <td class="small">{$r.label|escape}</td>
            <td>{if $r.is_system}<span class="badge badge-status-active">System</span>{else}<span class="badge bg-secondary">Custom</span>{/if}</td>
            <td><a href="/admin/team/{$r.id}/edit" class="btn btn-sm btn-outline-secondary">Edit Permissions</a></td>
          </tr>
          {foreachelse}
          <tr><td colspan="5" class="text-muted text-center py-4">No roles defined.</td></tr>
          {/foreach}
        </tbody>
      </table>
    </div>
  </div>
</div>
{/block}
