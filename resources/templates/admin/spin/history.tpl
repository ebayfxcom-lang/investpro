{extends file="layouts/admin.tpl"}
{block name="content"}

<div class="card">
  <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
    <h6 class="mb-0 fw-bold"><i class="fas fa-history me-2 text-info"></i>Spin History</h6>
    <a href="/admin/spin" class="btn btn-sm btn-outline-secondary">
      <i class="fas fa-arrow-left me-1"></i>Back to Spin Settings
    </a>
  </div>
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead class="table-light">
          <tr>
            <th>#</th>
            <th>User</th>
            <th>Spin Type</th>
            <th>Reward</th>
            <th>Value</th>
            <th>Date</th>
          </tr>
        </thead>
        <tbody>
          {if $data.items}
            {foreach $data.items as $index => $h}
            <tr>
              <td class="text-muted small">
                {($data.page - 1) * $data.per_page + $index + 1}
              </td>
              <td>
                <div class="d-flex align-items-center gap-2">
                  <div class="bg-primary bg-opacity-10 text-primary rounded-circle d-flex align-items-center justify-content-center"
                       style="width:28px;height:28px;font-size:.75rem;font-weight:700;">
                    {$h.username|upper|truncate:1:''}
                  </div>
                  <span class="fw-semibold">{$h.username|escape}</span>
                </div>
              </td>
              <td>
                <span class="badge {if $h.spin_type == 'free'}bg-success bg-opacity-25 text-success{else}bg-info bg-opacity-25 text-info{/if}">
                  {$h.spin_type|ucfirst}
                </span>
              </td>
              <td>
                <span class="badge bg-secondary bg-opacity-25 text-dark">
                  {$h.reward_type|replace:'_':' '|ucfirst}
                </span>
              </td>
              <td class="fw-semibold">
                {if $h.reward_label}{$h.reward_label|escape}{else}{$h.reward_value|escape}{/if}
              </td>
              <td class="text-muted small">{$h.created_at|date_format:'%b %d, %Y %H:%M'}</td>
            </tr>
            {/foreach}
          {else}
            <tr><td colspan="6" class="text-center text-muted py-5">No spin history found.</td></tr>
          {/if}
        </tbody>
      </table>
    </div>
  </div>

  {if $data.total_pages > 1}
  <div class="card-footer bg-white d-flex align-items-center justify-content-between flex-wrap gap-2 py-3">
    <div class="text-muted small">
      Showing {($data.page - 1) * $data.per_page + 1}–{min($data.page * $data.per_page, $data.total)}
      of {$data.total} records
    </div>
    <nav aria-label="Spin history pagination">
      <ul class="pagination pagination-sm mb-0">
        <li class="page-item {if $data.page <= 1}disabled{/if}">
          <a class="page-link" href="/admin/spin/history?page={$data.page - 1}"
             aria-label="Previous">&laquo;</a>
        </li>
        {for $p = 1 to $data.total_pages}
          {if $p == $data.page}
            <li class="page-item active"><span class="page-link">{$p}</span></li>
          {elseif $p == 1 || $p == $data.total_pages || ($p >= $data.page - 2 && $p <= $data.page + 2)}
            <li class="page-item">
              <a class="page-link" href="/admin/spin/history?page={$p}">{$p}</a>
            </li>
          {elseif $p == $data.page - 3 || $p == $data.page + 3}
            <li class="page-item disabled"><span class="page-link">&hellip;</span></li>
          {/if}
        {/for}
        <li class="page-item {if $data.page >= $data.total_pages}disabled{/if}">
          <a class="page-link" href="/admin/spin/history?page={$data.page + 1}"
             aria-label="Next">&raquo;</a>
        </li>
      </ul>
    </nav>
  </div>
  {/if}
</div>

{/block}
