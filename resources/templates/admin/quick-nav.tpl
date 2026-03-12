{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="mb-4">
  <div class="input-group">
    <span class="input-group-text"><i class="fas fa-search"></i></span>
    <input type="text" id="navSearch" class="form-control" placeholder="Search admin pages... (type to filter)" autofocus>
  </div>
</div>

<div id="navResults">
  {foreach $nav_groups as $group => $items}
  <div class="nav-group mb-4" data-group="{$group|escape}">
    <h6 class="fw-bold text-muted text-uppercase mb-2" style="font-size:.75rem;letter-spacing:1px">{$group|escape}</h6>
    <div class="row g-2">
      {foreach $items as $item}
      <div class="col-md-3 col-sm-4 col-6 nav-item-card" data-label="{$item.label|lower}">
        <a href="{$item.url}" class="card text-decoration-none h-100 p-3 d-flex flex-row align-items-center gap-2">
          <i class="{$item.icon} text-warning" style="width:20px;text-align:center"></i>
          <span class="small fw-semibold" style="color:var(--ip-text)">{$item.label|escape}</span>
        </a>
      </div>
      {/foreach}
    </div>
  </div>
  {/foreach}
</div>

<script>
document.getElementById('navSearch').addEventListener('input', function() {
  var q = this.value.toLowerCase().trim();
  document.querySelectorAll('.nav-item-card').forEach(function(card) {
    var label = card.getAttribute('data-label') || '';
    var visible = !q || label.includes(q);
    card.style.display = visible ? '' : 'none';
  });
  document.querySelectorAll('.nav-group').forEach(function(group) {
    var anyVisible = Array.from(group.querySelectorAll('.nav-item-card')).some(function(c) {
      return c.style.display !== 'none';
    });
    group.style.display = anyVisible ? '' : 'none';
  });
});
</script>
{/block}
