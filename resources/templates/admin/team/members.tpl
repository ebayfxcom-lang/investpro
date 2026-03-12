{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="card">
  <div class="card-header py-3 d-flex justify-content-between align-items-center">
    <h6 class="mb-0 fw-bold"><i class="fas fa-users me-2 text-warning"></i>Team Members ({$members|count})</h6>
    <a href="/admin/team" class="btn btn-sm btn-outline-secondary">← Roles</a>
  </div>
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table mb-0">
        <thead>
          <tr><th>User</th><th>Email</th><th>Role</th><th>Status</th><th>Actions</th></tr>
        </thead>
        <tbody>
          {foreach $members as $m}
          <tr>
            <td class="small fw-semibold">{$m.username|escape}</td>
            <td class="small text-muted">{$m.email|escape}</td>
            <td class="small">{$m.role_label|default:$m.role|escape}</td>
            <td>{if $m.status === 'active'}<span class="badge badge-status-active">Active</span>{else}<span class="badge badge-status-rejected">{$m.status|ucfirst}</span>{/if}</td>
            <td>
              <form method="POST" action="/admin/team/members" class="d-inline-flex gap-1 align-items-center">
                <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                <input type="hidden" name="action" value="assign_role">
                <input type="hidden" name="user_id" value="{$m.id}">
                <select name="role_id" class="form-select form-select-sm" style="width:auto">
                  <option value="">Remove Role</option>
                  {foreach $roles as $r}
                  <option value="{$r.id}" {if $m.team_role_id == $r.id}selected{/if}>{$r.label}</option>
                  {/foreach}
                </select>
                <button type="submit" class="btn btn-sm btn-outline-secondary">Save</button>
              </form>
            </td>
          </tr>
          {foreachelse}
          <tr><td colspan="5" class="text-muted text-center py-4">No team members yet.</td></tr>
          {/foreach}
        </tbody>
      </table>
    </div>
  </div>
</div>
{/block}
