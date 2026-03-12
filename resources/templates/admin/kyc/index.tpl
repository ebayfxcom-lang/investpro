{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="d-flex justify-content-between align-items-center mb-3">
  <h6 class="fw-bold mb-0">KYC Submissions</h6>
  <div class="d-flex gap-2">
    <a href="?status=" class="btn btn-sm {if !$status}btn-primary{else}btn-outline-secondary{/if}">All</a>
    <a href="?status=pending" class="btn btn-sm {if $status=='pending'}btn-warning text-dark{else}btn-outline-secondary{/if}">Pending</a>
    <a href="?status=approved" class="btn btn-sm {if $status=='approved'}btn-success{else}btn-outline-secondary{/if}">Approved</a>
    <a href="?status=rejected" class="btn btn-sm {if $status=='rejected'}btn-danger{else}btn-outline-secondary{/if}">Rejected</a>
  </div>
</div>

<div class="card">
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead>
          <tr>
            <th>#</th>
            <th>User</th>
            <th>Document Type</th>
            <th>Document #</th>
            <th>Status</th>
            <th>Submitted</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {foreach $data.items as $kyc}
          <tr>
            <td class="small">{$kyc.id}</td>
            <td>
              <div class="fw-semibold">{$kyc.username|escape}</div>
              <div class="text-muted small">{$kyc.email|escape}</div>
            </td>
            <td class="small">{$kyc.document_type|replace:'_':' '|ucfirst}</td>
            <td class="small font-monospace">{$kyc.document_number|escape}</td>
            <td>
              {if $kyc.status === 'approved'}
                <span class="badge badge-status-active">Approved</span>
              {elseif $kyc.status === 'rejected'}
                <span class="badge badge-status-rejected">Rejected</span>
              {else}
                <span class="badge badge-status-pending">Pending</span>
              {/if}
            </td>
            <td class="small text-muted">{$kyc.created_at|date_format:'%b %d, %Y'}</td>
            <td>
              <a href="/admin/kyc/{$kyc.id}" class="btn btn-sm btn-outline-primary">Review</a>
            </td>
          </tr>
          {foreachelse}
          <tr><td colspan="7" class="text-center text-muted py-4">No submissions found.</td></tr>
          {/foreach}
        </tbody>
      </table>
    </div>
  </div>
</div>

{if $data.total_pages > 1}
<nav class="mt-3">
  <ul class="pagination">
    {for $p=1 to $data.total_pages}
    <li class="page-item {if $p == $data.page}active{/if}">
      <a class="page-link" href="?status={$status}&page={$p}">{$p}</a>
    </li>
    {/for}
  </ul>
</nav>
{/if}
{/block}
