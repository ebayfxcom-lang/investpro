{extends file="layouts/user.tpl"}
{block name="content"}

<style>
  .spin-stat-card { border-left: 4px solid; }
  .spin-stat-card.free  { border-color: #10b981; }
  .spin-stat-card.paid  { border-color: #f59e0b; }
  .spin-stat-card.total { border-color: #6366f1; }

  #wheelCanvas {
    display: block;
    margin: 0 auto;
    border-radius: 50%;
    box-shadow: 0 8px 32px rgba(0,0,0,.18);
    max-width: 100%;
    cursor: default;
  }
  #wheelWrap {
    position: relative;
    display: inline-block;
  }
  #wheelPointer {
    position: absolute;
    top: -18px;
    left: 50%;
    transform: translateX(-50%);
    width: 0;
    height: 0;
    border-left: 14px solid transparent;
    border-right: 14px solid transparent;
    border-top: 28px solid #dc2626;
    filter: drop-shadow(0 2px 4px rgba(0,0,0,.4));
    z-index: 10;
  }
  #spinBtn {
    font-size: 1.1rem;
    font-weight: 700;
    letter-spacing: .5px;
    min-width: 180px;
    transition: transform .1s;
  }
  #spinBtn:active { transform: scale(.97); }
  #spinBtn:disabled { opacity: .6; cursor: not-allowed; }

  .result-badge {
    font-size: 1.5rem;
    font-weight: 800;
    color: #1e40af;
  }
  .history-reward { font-weight: 600; color: #059669; }
  .history-reward.miss { color: #9ca3af; }
</style>

<!-- ── Stats row ── -->
<div class="row g-3 mb-4">
  <div class="col-sm-4">
    <div class="card spin-stat-card free">
      <div class="card-body py-3">
        <div class="stat-label">Free Spins</div>
        <div class="stat-value text-success">{$user_spins.free_spins|default:0}</div>
      </div>
    </div>
  </div>
  <div class="col-sm-4">
    <div class="card spin-stat-card paid">
      <div class="card-body py-3">
        <div class="stat-label">Paid Spins</div>
        <div class="stat-value text-warning">{$user_spins.paid_spins|default:0}</div>
      </div>
    </div>
  </div>
  <div class="col-sm-4">
    <div class="card spin-stat-card total">
      <div class="card-body py-3">
        <div class="stat-label">Total Winnings</div>
        <div class="stat-value text-indigo">${$user_spins.total_winnings|default:'0.00'}</div>
      </div>
    </div>
  </div>
</div>

{if !$settings.enabled}
<div class="alert alert-warning"><i class="fas fa-ban me-2"></i>Spin &amp; Earn is currently disabled. Check back soon!</div>
{else}

<div class="row g-4">

  <!-- ── Wheel column ── -->
  <div class="col-lg-7">
    <div class="card">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-gamepad me-2 text-primary"></i>Spin the Wheel</h6>
      </div>
      <div class="card-body text-center py-4">
        <div id="wheelWrap">
          <div id="wheelPointer"></div>
          <canvas id="wheelCanvas" width="420" height="420"></canvas>
        </div>

        <div class="mt-4">
          {if $user_spins.free_spins > 0}
            <button id="spinBtn" class="btn btn-success btn-lg px-5" data-type="free">
              <i class="fas fa-sync-alt me-2"></i>Free Spin
            </button>
            <div class="form-text mt-1 text-success fw-semibold">
              {$user_spins.free_spins} free spin{if $user_spins.free_spins != 1}s{/if} remaining today
            </div>
          {elseif $user_spins.paid_spins > 0}
            <button id="spinBtn" class="btn btn-warning btn-lg px-5 text-white" data-type="paid">
              <i class="fas fa-sync-alt me-2"></i>Paid Spin
            </button>
            <div class="form-text mt-1 text-warning fw-semibold">
              {$user_spins.paid_spins} paid spin{if $user_spins.paid_spins != 1}s{/if} available
            </div>
          {else}
            <button id="spinBtn" class="btn btn-secondary btn-lg px-5" disabled>
              <i class="fas fa-sync-alt me-2"></i>No Spins Left
            </button>
            <div class="form-text mt-1 text-muted">
              Purchase spins below or wait for your daily free spin.
            </div>
          {/if}
        </div>
      </div>
    </div>
  </div>

  <!-- ── Purchase column ── -->
  <div class="col-lg-5">
    <div class="card h-100">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-coins me-2 text-warning"></i>Purchase Spins</h6>
      </div>
      <div class="card-body">
        <p class="text-muted small mb-3">
          Each paid spin costs <strong>${$settings.spin_price|default:'1.00'}</strong>.
          Daily free spins reset at midnight UTC
          ({$settings.daily_free_spins|default:1} per day).
        </p>
        <div class="alert alert-info py-2 small mb-3">
          <i class="fas fa-wallet me-1"></i>
          Your account balance: <strong>${$usd_balance|default:'0.00'|string_format:'%.2f'}</strong>
        </div>
        <form id="buySpinsForm" method="POST" action="/user/spin">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">
          <input type="hidden" name="action" value="purchase">

          <div class="mb-3">
            <label class="form-label fw-semibold">Number of Spins</label>
            <input type="number" name="quantity" class="form-control"
                   min="1" max="100" value="5" required>
          </div>

          <div class="mb-3 p-3 bg-light rounded">
            <div class="d-flex justify-content-between small text-muted mb-1">
              <span>Price per spin</span>
              <span>${$settings.spin_price|default:'1.00'}</span>
            </div>
            <div class="d-flex justify-content-between fw-bold">
              <span>Total</span>
              <span id="totalCost">$5.00</span>
            </div>
            <div id="balanceWarning" class="text-danger small mt-1 d-none">
              Insufficient balance. Please deposit funds.
            </div>
          </div>

          <button type="submit" class="btn btn-primary w-100" id="buySpinsBtn">
            <i class="fas fa-shopping-cart me-2"></i>Buy Spins
          </button>
        </form>
      </div>
    </div>
  </div>

</div><!-- /row -->

<!-- ── History table ── -->
<div class="card mt-4">
  <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
    <h6 class="mb-0 fw-bold"><i class="fas fa-history me-2 text-secondary"></i>Recent Spins</h6>
    <span class="badge bg-secondary">Last 20</span>
  </div>
  <div class="card-body p-0">
    {if $history}
    <div class="table-responsive">
      <table class="table mb-0">
        <thead class="table-light">
          <tr>
            <th>#</th>
            <th>Date</th>
            <th>Type</th>
            <th>Reward</th>
            <th>Amount</th>
          </tr>
        </thead>
        <tbody>
          {foreach $history as $spin}
          <tr>
            <td class="text-muted small">{$spin.id}</td>
            <td class="small">{$spin.created_at|date_format:'%d %b %Y %H:%M'}</td>
            <td>
              {if $spin.spin_type == 'free'}
                <span class="badge badge-active">Free</span>
              {else}
                <span class="badge badge-pending">Paid</span>
              {/if}
            </td>
            <td class="history-reward{if !$spin.reward_value || $spin.reward_value == 0} miss{/if}">
              {$spin.reward_label|escape|default:'No Prize'}
            </td>
            <td>
              {if $spin.reward_value > 0}
                <span class="text-success fw-semibold">+${$spin.reward_value|string_format:'%.2f'}</span>
              {else}
                <span class="text-muted">—</span>
              {/if}
            </td>
          </tr>
          {/foreach}
        </tbody>
      </table>
    </div>
    {else}
    <div class="text-center text-muted py-5">
      <i class="fas fa-gamepad fa-3x mb-3 opacity-25"></i>
      <p>No spins yet — give the wheel a whirl!</p>
    </div>
    {/if}
  </div>
</div>

{/if}{* /settings.enabled *}

<!-- ── Result modal ── -->
<div class="modal fade" id="resultModal" tabindex="-1">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content text-center">
      <div class="modal-body py-5">
        <div id="resultIcon" class="mb-3" style="font-size:3rem;"></div>
        <h4 id="resultTitle" class="fw-bold mb-2"></h4>
        <div id="resultBody" class="result-badge mb-3"></div>
        <p id="resultMsg" class="text-muted small mb-4"></p>
        <button class="btn btn-primary px-5" data-bs-dismiss="modal">Awesome!</button>
      </div>
    </div>
  </div>
</div>

<script>
(function () {
  /* ── Wheel data from Smarty ── */
  const rewards = {ldelim}
    {foreach $rewards as $r}
    "{$r.id}": { label: "{$r.label|escape:'javascript'}", color: "{$r.color|default:'#6366f1'|escape:'javascript'}" },
    {/foreach}
  {rdelim};

  const segments = Object.values(rewards);
  /* Fall back to generic segments when none configured */
  const SEGMENTS = segments.length >= 2 ? segments : [
    {ldelim}label:"$5 Bonus",   color:"#10b981"{rdelim},
    {ldelim}label:"No Prize",   color:"#e5e7eb"{rdelim},
    {ldelim}label:"$2 Bonus",   color:"#6366f1"{rdelim},
    {ldelim}label:"Extra Spin", color:"#f59e0b"{rdelim},
    {ldelim}label:"No Prize",   color:"#e5e7eb"{rdelim},
    {ldelim}label:"$10 Bonus",  color:"#ec4899"{rdelim},
    {ldelim}label:"No Prize",   color:"#e5e7eb"{rdelim},
    {ldelim}label:"$1 Bonus",   color:"#14b8a6"{rdelim},
    {ldelim}label:"No Prize",   color:"#e5e7eb"{rdelim},
    {ldelim}label:"$20 Bonus",  color:"#f97316"{rdelim},
    {ldelim}label:"No Prize",   color:"#e5e7eb"{rdelim},
    {ldelim}label:"$3 Bonus",   color:"#8b5cf6"{rdelim},
  ];

  /* ── Canvas drawing ── */
  const canvas = document.getElementById('wheelCanvas');
  const ctx    = canvas.getContext('2d');
  const N      = SEGMENTS.length;
  const ARC    = (2 * Math.PI) / N;
  const cx     = canvas.width  / 2;
  const cy     = canvas.height / 2;
  const R      = cx - 8;

  let currentAngle = 0;
  let spinning     = false;

  function drawWheel(angle) {
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    /* Outer ring */
    ctx.beginPath();
    ctx.arc(cx, cy, R + 6, 0, 2 * Math.PI);
    ctx.fillStyle = '#1e3a8a';
    ctx.fill();

    SEGMENTS.forEach((seg, i) => {
      const start = angle + i * ARC;
      const end   = start + ARC;

      /* Segment fill */
      ctx.beginPath();
      ctx.moveTo(cx, cy);
      ctx.arc(cx, cy, R, start, end);
      ctx.closePath();
      ctx.fillStyle = seg.color;
      ctx.fill();
      ctx.strokeStyle = 'rgba(255,255,255,.4)';
      ctx.lineWidth = 2;
      ctx.stroke();

      /* Label */
      ctx.save();
      ctx.translate(cx, cy);
      ctx.rotate(start + ARC / 2);
      ctx.textAlign  = 'right';
      ctx.fillStyle  = '#fff';
      ctx.font       = 'bold ' + Math.max(10, Math.floor(R / N * 1.1)) + 'px Segoe UI, sans-serif';
      ctx.shadowColor = 'rgba(0,0,0,.5)';
      ctx.shadowBlur  = 3;
      ctx.fillText(seg.label, R - 12, 5);
      ctx.restore();
    });

    /* Centre hub */
    ctx.beginPath();
    ctx.arc(cx, cy, 22, 0, 2 * Math.PI);
    ctx.fillStyle = '#fff';
    ctx.fill();
    ctx.strokeStyle = '#1e3a8a';
    ctx.lineWidth = 3;
    ctx.stroke();
  }

  drawWheel(currentAngle);

  /* ── Spin logic ── */
  const spinBtn  = document.getElementById('spinBtn');
  const csrfToken = "{$csrf_token|escape:'javascript'}";

  if (spinBtn && !spinBtn.disabled) {
    spinBtn.addEventListener('click', function () {
      if (spinning) return;
      spinning = true;
      spinBtn.disabled = true;
      spinBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Spinning…';

      const spinType = spinBtn.dataset.type || 'free';

      fetch('/user/spin', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({
          _csrf_token: csrfToken,
          action: 'spin',
          spin_type: spinType
        })
      })
      .then(r => r.json())
      .then(data => {
        if (!data.success) {
          throw new Error(data.message || 'Spin failed. Please try again.');
        }

        /* Determine target segment index from server response */
        const targetIdx = typeof data.segment_index === 'number'
          ? data.segment_index
          : Math.floor(Math.random() * N);

        animateSpin(targetIdx, data);
      })
      .catch(err => {
        spinning = false;
        if (spinBtn) {
          spinBtn.disabled = false;
          spinBtn.innerHTML = '<i class="fas fa-sync-alt me-2"></i>' +
            (spinBtn.dataset.type === 'free' ? 'Free Spin' : 'Paid Spin');
        }
        showResult('❌', 'Error', err.message, '');
      });
    });
  }

  function animateSpin(targetIdx, data) {
    /* Spin at least 5 full rotations, land precisely on target segment */
    const targetAngle = -(targetIdx * ARC + ARC / 2);
    const extraSpins  = (5 + Math.floor(Math.random() * 3)) * 2 * Math.PI;
    const finalAngle  = targetAngle - extraSpins;

    const duration  = 4000;
    const startTime = performance.now();
    const startAngle = currentAngle;

    function easeOut(t) {
      return 1 - Math.pow(1 - t, 4);
    }

    function frame(now) {
      const elapsed  = now - startTime;
      const progress = Math.min(elapsed / duration, 1);
      const easedP   = easeOut(progress);

      currentAngle = startAngle + (finalAngle - startAngle) * easedP;
      drawWheel(currentAngle);

      if (progress < 1) {
        requestAnimationFrame(frame);
      } else {
        currentAngle = finalAngle % (2 * Math.PI);
        spinning = false;
        showResult(
          data.reward_amount > 0 ? '🎉' : '😔',
          data.reward_amount > 0 ? 'Congratulations! You won!' : 'Better luck next time!',
          data.reward_label || 'No Prize',
          data.reward_amount > 0
            ? '+$' + parseFloat(data.reward_amount).toFixed(2) + ' has been credited to your account.'
            : 'Try again for another chance!'
        );
        /* Reload to refresh spin count */
        setTimeout(() => window.location.reload(), 3500);
      }
    }

    requestAnimationFrame(frame);
  }

  function showResult(icon, title, body, msg) {
    document.getElementById('resultIcon').textContent = icon;
    document.getElementById('resultTitle').textContent = title;
    document.getElementById('resultBody').textContent  = body;
    document.getElementById('resultMsg').textContent   = msg;
    new bootstrap.Modal(document.getElementById('resultModal')).show();
  }

  /* ── Purchase cost calculator with balance check ── */
  const qtyInput      = document.querySelector('input[name="quantity"]');
  const totalSpan     = document.getElementById('totalCost');
  const balanceWarn   = document.getElementById('balanceWarning');
  const buyBtn        = document.getElementById('buySpinsBtn');
  const price         = parseFloat("{$settings.spin_price|default:'1.00'}") || 1;
  const usdBalance    = parseFloat("{$usd_balance|default:'0.00'}") || 0;

  if (qtyInput && totalSpan) {
    function updateTotal() {
      const qty   = parseInt(qtyInput.value, 10) || 0;
      const total = qty * price;
      totalSpan.textContent = '$' + total.toFixed(2);
      if (balanceWarn && buyBtn) {
        if (total > usdBalance) {
          balanceWarn.classList.remove('d-none');
          buyBtn.disabled = true;
        } else {
          balanceWarn.classList.add('d-none');
          buyBtn.disabled = false;
        }
      }
    }
    qtyInput.addEventListener('input', updateTotal);
    updateTotal();
  }
}());
</script>

{/block}
