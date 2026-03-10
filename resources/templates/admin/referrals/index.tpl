{extends file="layouts/admin.tpl"}
{block name="content"}

<div class="card">
  <div class="card-header bg-white py-3">
    <h6 class="mb-0 fw-bold"><i class="fas fa-share-nodes me-2 text-primary"></i>Referral Earnings</h6>
  </div>
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead class="table-light">
          <tr>
            <th>#</th>
            <th>Referrer ID</th>
            <th>Referred User ID</th>
            <th>Amount</th>
            <th>Status</th>
            <th>Date</th>
          </tr>
        </thead>
        <tbody>
          {foreach $data.items as $r}
          <tr>
            <td class="text-muted small">{$r.id}</td>
            <td>{$r.referrer_id}</td>
            <td>{$r.user_id|default:'—'}</td>
            <td class="fw-semibold">${$r.amount|string_format:"%.2f"}</td>
            <td><span class="badge badge-status-{$r.status}">{$r.status|ucfirst}</span></td>
            <td class="text-muted small">{$r.created_at|date_format:'%b %d, %Y %H:%M'}</td>
          </tr>
          {foreachelse}
          <tr><td colspan="6" class="text-center text-muted py-4">No referral earnings found.</td></tr>
          {/foreach}
        </tbody>
      </table>
    </div>
  </div>
  {if $data.total_pages > 1}
  <div class="card-footer bg-white py-3 d-flex justify-content-between align-items-center">
    <div class="text-muted small">Showing {$data.items|@count} of {$data.total} records</div>
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

{/block}
