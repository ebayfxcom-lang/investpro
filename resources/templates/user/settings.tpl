{extends file="layouts/user.tpl"}
{block name="content"}
<div class="row justify-content-center">
  <div class="col-lg-7">
    <div class="card">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-user-cog me-2 text-primary"></i>Account Settings</h6>
      </div>
      <div class="card-body">
        <form method="POST" action="/user/settings">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">

          <div class="row g-3">
            <div class="col-md-6">
              <label class="form-label fw-semibold">First Name</label>
              <input type="text" name="first_name" class="form-control" value="{$user.first_name|escape}">
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Last Name</label>
              <input type="text" name="last_name" class="form-control" value="{$user.last_name|escape}">
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Username</label>
              <input type="text" class="form-control" value="{$user.username|escape}" disabled>
              <div class="form-text">Username cannot be changed</div>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Email</label>
              <input type="email" class="form-control" value="{$user.email|escape}" disabled>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Phone</label>
              <input type="tel" name="phone" class="form-control" value="{$user.phone|escape}">
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Country</label>
              <select name="country" class="form-select">
                <option value="">Select your country...</option>
                {foreach [
                  'US'=>'United States','GB'=>'United Kingdom','CA'=>'Canada',
                  'AU'=>'Australia','DE'=>'Germany','FR'=>'France',
                  'NG'=>'Nigeria','ZA'=>'South Africa','GH'=>'Ghana',
                  'KE'=>'Kenya','IN'=>'India','PK'=>'Pakistan',
                  'BR'=>'Brazil','MX'=>'Mexico','Other'=>'Other'
                ] as $code => $name}
                <option value="{$code}"{if $user.country == $code} selected{/if}>{$name}</option>
                {/foreach}
              </select>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">WhatsApp Number <span class="text-danger">*</span></label>
              <input type="tel" name="whatsapp_number" class="form-control"
                     value="{$user.whatsapp_number|escape}" placeholder="+1 234 567 8900" required>
              <div class="form-text">Used for account notifications.</div>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Facebook Profile <span class="text-muted small">(optional)</span></label>
              <input type="url" name="facebook_url" class="form-control"
                     value="{$user.facebook_url|escape}" placeholder="https://facebook.com/yourprofile">
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Preferred Display Currency</label>
              <select name="preferred_currency" class="form-select">
                {foreach ['USD'=>'USD – US Dollar','EUR'=>'EUR – Euro','GBP'=>'GBP – British Pound','JPY'=>'JPY – Japanese Yen','CAD'=>'CAD – Canadian Dollar','AUD'=>'AUD – Australian Dollar','CHF'=>'CHF – Swiss Franc','CNY'=>'CNY – Chinese Yuan','HKD'=>'HKD – Hong Kong Dollar','SGD'=>'SGD – Singapore Dollar','SEK'=>'SEK – Swedish Krona','NOK'=>'NOK – Norwegian Krone','NZD'=>'NZD – New Zealand Dollar','MXN'=>'MXN – Mexican Peso','INR'=>'INR – Indian Rupee','BRL'=>'BRL – Brazilian Real','ZAR'=>'ZAR – South African Rand','KRW'=>'KRW – South Korean Won','TRY'=>'TRY – Turkish Lira','AED'=>'AED – UAE Dirham'] as $code => $label}
                <option value="{$code}"{if $user.preferred_currency == $code} selected{/if}>{$label}</option>
                {/foreach}
              </select>
              <div class="form-text">Used to estimate your crypto asset values. Fiat is display-only, not a wallet.</div>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Communication Preferences</label>
              <div class="mt-2 d-flex flex-column gap-1">
                {foreach ['email'=>'Email only','whatsapp'=>'WhatsApp only','both'=>'Email &amp; WhatsApp'] as $val => $lbl}
                <div class="form-check">
                  <input class="form-check-input" type="radio" name="communication_prefs"
                         id="cp_{$val}" value="{$val}"
                         {if $user.communication_prefs == $val}checked{elseif !$user.communication_prefs && $val == 'email'}checked{/if}>
                  <label class="form-check-label" for="cp_{$val}">{$lbl}</label>
                </div>
                {/foreach}
              </div>
            </div>
            <div class="col-12">
              <label class="form-label fw-semibold">Payout Details <span class="text-muted small">(optional)</span></label>
              <textarea name="payout_details" class="form-control" rows="3"
                        placeholder="Bank account number, crypto wallet address, etc.">{$user.payout_details|escape}</textarea>
              <div class="form-text">Your preferred payout method details for withdrawals.</div>
            </div>
          </div>

          <div class="mt-4">
            <button type="submit" class="btn btn-primary"><i class="fas fa-save me-2"></i>Save Changes</button>
          </div>
        </form>
      </div>
    </div>

    <div class="card mt-3">
      <div class="card-header bg-white py-3">
        <h6 class="mb-0 fw-bold text-muted"><i class="fas fa-share-nodes me-2"></i>Referral Code</h6>
      </div>
      <div class="card-body">
        <div class="d-flex align-items-center gap-3">
          <code class="bg-light p-2 rounded fs-6">{$user.referral_code}</code>
          <a href="/user/referrals" class="btn btn-outline-warning btn-sm">View Referral Dashboard</a>
        </div>
      </div>
    </div>
  </div>
</div>
{/block}
