{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="row g-3">
  <div class="col-12">
    <a href="/admin/team" class="btn btn-sm btn-outline-secondary mb-3">← Back to Roles</a>
  </div>
  <div class="col-12">
    <div class="card">
      <div class="card-header py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-shield-halved me-2 text-warning"></i>{$title}</h6>
      </div>
      <div class="card-body">
        <form method="POST" action="/admin/team/{$role.id}/edit">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">
          {if !$role.is_system}
          <div class="row g-2 mb-3">
            <div class="col-md-4">
              <label class="form-label fw-semibold small">Label</label>
              <input type="text" name="label" class="form-control form-control-sm" value="{$role.label|escape}" required>
            </div>
            <div class="col-md-8">
              <label class="form-label fw-semibold small">Description</label>
              <input type="text" name="description" class="form-control form-control-sm" value="{$role.description|default:''|escape}">
            </div>
          </div>
          {/if}
          <h6 class="fw-bold mb-3 mt-3">Permissions</h6>
          <div class="row g-3">
            {foreach $all_perms as $module => $perms}
            <div class="col-md-4">
              <div class="card h-100">
                <div class="card-header py-2">
                  <div class="form-check mb-0">
                    <input class="form-check-input" type="checkbox" id="mod_{$module}" onchange="toggleModule('{$module}', this.checked)">
                    <label class="form-check-label fw-semibold text-capitalize" for="mod_{$module}">{$module|replace:'_':' '}</label>
                  </div>
                </div>
                <div class="card-body py-2">
                  {foreach $perms as $p}
                  <div class="form-check mb-1">
                    <input class="form-check-input perm-{$module}" type="checkbox" name="permissions[]" value="{$p.id}" id="perm_{$p.id}"
                           {if in_array($p.name, $assigned)}checked{/if}>
                    <label class="form-check-label small" for="perm_{$p.id}">{$p.label}</label>
                  </div>
                  {/foreach}
                </div>
              </div>
            </div>
            {/foreach}
          </div>
          <div class="mt-4">
            <button type="submit" class="btn btn-accent">Save Permissions</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>
<script>
function toggleModule(module, checked) {
  document.querySelectorAll('.perm-' + module).forEach(function(cb) { cb.checked = checked; });
}
</script>
{/block}
