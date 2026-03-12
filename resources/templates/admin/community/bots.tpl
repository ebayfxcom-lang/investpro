{extends file="layouts/admin.tpl"}
{block name="content"}
<div class="row g-3">
  <div class="col-lg-5">
    <div class="card">
      <div class="card-header py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-robot me-2 text-info"></i>Create Bot Profile</h6>
      </div>
      <div class="card-body">
        <form method="POST" action="/admin/community/bots">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">
          <input type="hidden" name="action" value="create_bot">
          <div class="mb-3">
            <label class="form-label fw-semibold">Display Name</label>
            <input type="text" name="display_name" class="form-control" required maxlength="80" value="Bot User">
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Tone Category</label>
            <select name="tone_category" class="form-select">
              <option value="paying_status">Paying Status</option>
              <option value="platform_performance">Platform Performance</option>
              <option value="investment_excitement">Investment Excitement</option>
              <option value="support_praise">Support Praise</option>
              <option value="withdrawal_received">Withdrawal Received</option>
              <option value="general" selected>General</option>
            </select>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Keywords / Topics</label>
            <input type="text" name="keywords" class="form-control" placeholder="profit, withdrawal, investment (comma-separated)">
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Post Frequency (minutes)</label>
            <input type="number" name="post_frequency" class="form-control" value="60" min="5">
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Status</label>
            <select name="status" class="form-select">
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
            </select>
          </div>
          <button type="submit" class="btn btn-primary w-100">Create Bot</button>
        </form>
      </div>
    </div>
  </div>

  <div class="col-lg-7">
    <div class="card">
      <div class="card-header py-3">
        <h6 class="mb-0 fw-bold">Bot Profiles ({$bots|count})</h6>
      </div>
      <div class="card-body p-0">
        <div class="table-responsive">
          <table class="table mb-0">
            <thead>
              <tr>
                <th>Name</th>
                <th>Tone</th>
                <th>Frequency</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {foreach $bots as $bot}
              <tr>
                <td class="small fw-semibold">{$bot.display_name|escape}</td>
                <td class="small">{$bot.tone_category|replace:'_':' '|ucfirst}</td>
                <td class="small">{$bot.post_frequency}m</td>
                <td>
                  {if $bot.status === 'active'}
                    <span class="badge badge-status-active">Active</span>
                  {else}
                    <span class="badge badge-status-rejected">Inactive</span>
                  {/if}
                </td>
                <td>
                  <form method="POST" action="/admin/community/bots" class="d-inline">
                    <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                    <input type="hidden" name="action" value="toggle_bot">
                    <input type="hidden" name="bot_id" value="{$bot.id}">
                    <button type="submit" class="btn btn-sm btn-outline-secondary me-1">Toggle</button>
                  </form>
                  <form method="POST" action="/admin/community/bots" class="d-inline">
                    <input type="hidden" name="_csrf_token" value="{$csrf_token}">
                    <input type="hidden" name="action" value="delete_bot">
                    <input type="hidden" name="bot_id" value="{$bot.id}">
                    <button type="submit" class="btn btn-sm btn-outline-danger"
                            onclick="return confirm('Delete?')">
                      <i class="fas fa-trash"></i>
                    </button>
                  </form>
                </td>
              </tr>
              {foreachelse}
              <tr><td colspan="5" class="text-center text-muted py-3">No bot profiles.</td></tr>
              {/foreach}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>
{/block}
