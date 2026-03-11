{extends file="layouts/admin.tpl"}
{block name="content"}

<div class="card mb-4">
  <div class="card-header bg-white py-3">
    <h6 class="mb-0 fw-bold"><i class="fas fa-filter me-2 text-secondary"></i>Filter Price History</h6>
  </div>
  <div class="card-body">
    <form method="GET" action="/admin/currencies/price-history" class="row g-3 align-items-end">
      <div class="col-md-4">
        <label for="filterCode" class="form-label fw-semibold">Currency</label>
        <select class="form-select" id="filterCode" name="code">
          <option value="">— All Currencies —</option>
          {foreach $currencies as $c}
            <option value="{$c.code|escape}" {if $code == $c.code}selected{/if}>
              {$c.code|escape} — {$c.name|escape}
            </option>
          {/foreach}
        </select>
      </div>
      <div class="col-md-3">
        <label for="filterDays" class="form-label fw-semibold">Period</label>
        <select class="form-select" id="filterDays" name="days">
          <option value="1"  {if $days == 1}selected{/if}>Last 24 hours</option>
          <option value="7"  {if $days == 7 || !$days}selected{/if}>Last 7 days</option>
          <option value="14" {if $days == 14}selected{/if}>Last 14 days</option>
          <option value="30" {if $days == 30}selected{/if}>Last 30 days</option>
          <option value="90" {if $days == 90}selected{/if}>Last 90 days</option>
        </select>
      </div>
      <div class="col-md-auto">
        <button type="submit" class="btn btn-accent">
          <i class="fas fa-search me-1"></i>Filter
        </button>
        <a href="/admin/currencies/price-history" class="btn btn-outline-secondary ms-1">
          <i class="fas fa-times me-1"></i>Reset
        </a>
      </div>
    </form>
  </div>
</div>

<div class="card">
  <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
    <h6 class="mb-0 fw-bold"><i class="fas fa-chart-line me-2 text-info"></i>Price History</h6>
    <a href="/admin/currencies" class="btn btn-sm btn-outline-secondary">
      <i class="fas fa-arrow-left me-1"></i>Back to Currencies
    </a>
  </div>
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead class="table-light">
          <tr>
            <th>Currency</th>
            <th>Price USD</th>
            <th>Price EUR</th>
            <th>Source</th>
            <th>Recorded At</th>
          </tr>
        </thead>
        <tbody>
          {if $history}
            {foreach $history as $h}
            <tr>
              <td>
                <span class="fw-semibold font-monospace">{$h.currency_code|escape}</span>
              </td>
              <td class="font-monospace">
                <span class="text-success fw-semibold">${$h.price_usd|string_format:"%.8f"}</span>
              </td>
              <td class="font-monospace text-muted">
                €{$h.price_eur|string_format:"%.8f"}
              </td>
              <td>
                <span class="badge bg-secondary bg-opacity-25 text-dark">{$h.source|escape}</span>
              </td>
              <td class="text-muted small">{$h.recorded_at|date_format:'%b %d, %Y %H:%M:%S'}</td>
            </tr>
            {/foreach}
          {else}
            <tr>
              <td colspan="5" class="text-center text-muted py-5">
                <i class="fas fa-chart-line fa-2x mb-2 d-block opacity-25"></i>
                No price history found for the selected filters.
              </td>
            </tr>
          {/if}
        </tbody>
      </table>
    </div>
  </div>
  {if $history}
  <div class="card-footer bg-white py-2 text-muted small">
    <i class="fas fa-info-circle me-1"></i>
    Showing {$history|count} record{if $history|count != 1}s{/if}
    {if $code}for <strong>{$code|escape}</strong>{/if}
    over the last <strong>{$days|default:7}</strong> day{if ($days|default:7) != 1}s{/if}.
  </div>
  {/if}
</div>

{/block}
