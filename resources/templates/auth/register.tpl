{extends file="layouts/auth.tpl"}
{block name="content"}
<div class="text-center mb-4">
  <div style="width:56px;height:56px;background:rgba(240,185,11,.12);border:1px solid rgba(240,185,11,.25);border-radius:14px;display:inline-flex;align-items:center;justify-content:center;margin-bottom:1rem;">
    <i class="fas fa-user-plus" style="color:#f0b90b;font-size:1.4rem;"></i>
  </div>
  <h4 class="fw-bold mb-1">Create Account</h4>
  <p class="subtitle">Join thousands of investors worldwide</p>
</div>

<form method="POST" action="/register" novalidate>
  <input type="hidden" name="_csrf_token" value="{$csrf_token}">

  <div class="row g-3 mb-3">
    <div class="col-12">
      <label class="form-label">Username</label>
      <input type="text" name="username" class="form-control" placeholder="Choose a username" required autocomplete="username">
    </div>
    <div class="col-12">
      <label class="form-label">Email Address</label>
      <input type="email" name="email" class="form-control" placeholder="you@example.com" required autocomplete="email">
    </div>
    <div class="col-sm-6">
      <label class="form-label">Password</label>
      <input type="password" name="password" class="form-control" placeholder="Min. 8 characters" required minlength="8" autocomplete="new-password">
    </div>
    <div class="col-sm-6">
      <label class="form-label">Confirm Password</label>
      <input type="password" name="password_confirm" class="form-control" placeholder="Repeat password" required autocomplete="new-password">
    </div>
  </div>

  <div class="mb-3">
    <label class="form-label">WhatsApp Number <span style="color:#f87171;">*</span></label>
    <div class="input-group">
      <span class="input-group-text" style="background:var(--auth-input-bg);border-color:var(--auth-input-border);color:#25d366;">
        <i class="fab fa-whatsapp"></i>
      </span>
      <input type="tel" name="whatsapp_number" class="form-control" placeholder="+1 234 567 8900" required autocomplete="tel">
    </div>
    <div class="form-text">Used for account notifications and support.</div>
  </div>

  <div class="row g-3 mb-3">
    <div class="col-sm-6">
      <label class="form-label">Country</label>
      <select name="country" class="form-select">
        <option value="">Select country...</option>
        <option value="AF">Afghanistan</option>
        <option value="AL">Albania</option>
        <option value="DZ">Algeria</option>
        <option value="AD">Andorra</option>
        <option value="AO">Angola</option>
        <option value="AG">Antigua and Barbuda</option>
        <option value="AR">Argentina</option>
        <option value="AM">Armenia</option>
        <option value="AU">Australia</option>
        <option value="AT">Austria</option>
        <option value="AZ">Azerbaijan</option>
        <option value="BS">Bahamas</option>
        <option value="BH">Bahrain</option>
        <option value="BD">Bangladesh</option>
        <option value="BB">Barbados</option>
        <option value="BY">Belarus</option>
        <option value="BE">Belgium</option>
        <option value="BZ">Belize</option>
        <option value="BJ">Benin</option>
        <option value="BT">Bhutan</option>
        <option value="BO">Bolivia</option>
        <option value="BA">Bosnia and Herzegovina</option>
        <option value="BW">Botswana</option>
        <option value="BR">Brazil</option>
        <option value="BN">Brunei</option>
        <option value="BG">Bulgaria</option>
        <option value="BF">Burkina Faso</option>
        <option value="BI">Burundi</option>
        <option value="CV">Cabo Verde</option>
        <option value="KH">Cambodia</option>
        <option value="CM">Cameroon</option>
        <option value="CA">Canada</option>
        <option value="CF">Central African Republic</option>
        <option value="TD">Chad</option>
        <option value="CL">Chile</option>
        <option value="CN">China</option>
        <option value="CO">Colombia</option>
        <option value="KM">Comoros</option>
        <option value="CD">Congo (DRC)</option>
        <option value="CG">Congo (Republic)</option>
        <option value="CR">Costa Rica</option>
        <option value="CI">Côte d'Ivoire</option>
        <option value="HR">Croatia</option>
        <option value="CU">Cuba</option>
        <option value="CY">Cyprus</option>
        <option value="CZ">Czech Republic</option>
        <option value="DK">Denmark</option>
        <option value="DJ">Djibouti</option>
        <option value="DM">Dominica</option>
        <option value="DO">Dominican Republic</option>
        <option value="EC">Ecuador</option>
        <option value="EG">Egypt</option>
        <option value="SV">El Salvador</option>
        <option value="GQ">Equatorial Guinea</option>
        <option value="ER">Eritrea</option>
        <option value="EE">Estonia</option>
        <option value="SZ">Eswatini</option>
        <option value="ET">Ethiopia</option>
        <option value="FJ">Fiji</option>
        <option value="FI">Finland</option>
        <option value="FR">France</option>
        <option value="GA">Gabon</option>
        <option value="GM">Gambia</option>
        <option value="GE">Georgia</option>
        <option value="DE">Germany</option>
        <option value="GH">Ghana</option>
        <option value="GR">Greece</option>
        <option value="GD">Grenada</option>
        <option value="GT">Guatemala</option>
        <option value="GN">Guinea</option>
        <option value="GW">Guinea-Bissau</option>
        <option value="GY">Guyana</option>
        <option value="HT">Haiti</option>
        <option value="HN">Honduras</option>
        <option value="HU">Hungary</option>
        <option value="IS">Iceland</option>
        <option value="IN">India</option>
        <option value="ID">Indonesia</option>
        <option value="IR">Iran</option>
        <option value="IQ">Iraq</option>
        <option value="IE">Ireland</option>
        <option value="IL">Israel</option>
        <option value="IT">Italy</option>
        <option value="JM">Jamaica</option>
        <option value="JP">Japan</option>
        <option value="JO">Jordan</option>
        <option value="KZ">Kazakhstan</option>
        <option value="KE">Kenya</option>
        <option value="KI">Kiribati</option>
        <option value="KW">Kuwait</option>
        <option value="KG">Kyrgyzstan</option>
        <option value="LA">Laos</option>
        <option value="LV">Latvia</option>
        <option value="LB">Lebanon</option>
        <option value="LS">Lesotho</option>
        <option value="LR">Liberia</option>
        <option value="LY">Libya</option>
        <option value="LI">Liechtenstein</option>
        <option value="LT">Lithuania</option>
        <option value="LU">Luxembourg</option>
        <option value="MG">Madagascar</option>
        <option value="MW">Malawi</option>
        <option value="MY">Malaysia</option>
        <option value="MV">Maldives</option>
        <option value="ML">Mali</option>
        <option value="MT">Malta</option>
        <option value="MH">Marshall Islands</option>
        <option value="MR">Mauritania</option>
        <option value="MU">Mauritius</option>
        <option value="MX">Mexico</option>
        <option value="FM">Micronesia</option>
        <option value="MD">Moldova</option>
        <option value="MC">Monaco</option>
        <option value="MN">Mongolia</option>
        <option value="ME">Montenegro</option>
        <option value="MA">Morocco</option>
        <option value="MZ">Mozambique</option>
        <option value="MM">Myanmar</option>
        <option value="NA">Namibia</option>
        <option value="NR">Nauru</option>
        <option value="NP">Nepal</option>
        <option value="NL">Netherlands</option>
        <option value="NZ">New Zealand</option>
        <option value="NI">Nicaragua</option>
        <option value="NE">Niger</option>
        <option value="NG">Nigeria</option>
        <option value="NO">Norway</option>
        <option value="OM">Oman</option>
        <option value="PK">Pakistan</option>
        <option value="PW">Palau</option>
        <option value="PA">Panama</option>
        <option value="PG">Papua New Guinea</option>
        <option value="PY">Paraguay</option>
        <option value="PE">Peru</option>
        <option value="PH">Philippines</option>
        <option value="PL">Poland</option>
        <option value="PT">Portugal</option>
        <option value="QA">Qatar</option>
        <option value="RO">Romania</option>
        <option value="RU">Russia</option>
        <option value="RW">Rwanda</option>
        <option value="KN">Saint Kitts and Nevis</option>
        <option value="LC">Saint Lucia</option>
        <option value="VC">Saint Vincent and the Grenadines</option>
        <option value="WS">Samoa</option>
        <option value="SM">San Marino</option>
        <option value="ST">Sao Tome and Principe</option>
        <option value="SA">Saudi Arabia</option>
        <option value="SN">Senegal</option>
        <option value="RS">Serbia</option>
        <option value="SC">Seychelles</option>
        <option value="SL">Sierra Leone</option>
        <option value="SG">Singapore</option>
        <option value="SK">Slovakia</option>
        <option value="SI">Slovenia</option>
        <option value="SB">Solomon Islands</option>
        <option value="SO">Somalia</option>
        <option value="ZA">South Africa</option>
        <option value="SS">South Sudan</option>
        <option value="ES">Spain</option>
        <option value="LK">Sri Lanka</option>
        <option value="SD">Sudan</option>
        <option value="SR">Suriname</option>
        <option value="SE">Sweden</option>
        <option value="CH">Switzerland</option>
        <option value="SY">Syria</option>
        <option value="TW">Taiwan</option>
        <option value="TJ">Tajikistan</option>
        <option value="TZ">Tanzania</option>
        <option value="TH">Thailand</option>
        <option value="TL">Timor-Leste</option>
        <option value="TG">Togo</option>
        <option value="TO">Tonga</option>
        <option value="TT">Trinidad and Tobago</option>
        <option value="TN">Tunisia</option>
        <option value="TR">Turkey</option>
        <option value="TM">Turkmenistan</option>
        <option value="TV">Tuvalu</option>
        <option value="UG">Uganda</option>
        <option value="UA">Ukraine</option>
        <option value="AE">United Arab Emirates</option>
        <option value="GB">United Kingdom</option>
        <option value="US">United States</option>
        <option value="UY">Uruguay</option>
        <option value="UZ">Uzbekistan</option>
        <option value="VU">Vanuatu</option>
        <option value="VE">Venezuela</option>
        <option value="VN">Vietnam</option>
        <option value="YE">Yemen</option>
        <option value="ZM">Zambia</option>
        <option value="ZW">Zimbabwe</option>
      </select>
    </div>
    <div class="col-sm-6">
      <label class="form-label">Preferred Display Currency</label>
      <select name="preferred_currency" class="form-select">
        <option value="USD">USD – US Dollar</option>
        <option value="EUR">EUR – Euro</option>
        <option value="GBP">GBP – British Pound</option>
        <option value="JPY">JPY – Japanese Yen</option>
        <option value="CAD">CAD – Canadian Dollar</option>
        <option value="AUD">AUD – Australian Dollar</option>
        <option value="CHF">CHF – Swiss Franc</option>
        <option value="CNY">CNY – Chinese Yuan</option>
        <option value="HKD">HKD – Hong Kong Dollar</option>
        <option value="SGD">SGD – Singapore Dollar</option>
        <option value="SEK">SEK – Swedish Krona</option>
        <option value="NOK">NOK – Norwegian Krone</option>
        <option value="NZD">NZD – New Zealand Dollar</option>
        <option value="MXN">MXN – Mexican Peso</option>
        <option value="INR">INR – Indian Rupee</option>
        <option value="BRL">BRL – Brazilian Real</option>
        <option value="ZAR">ZAR – South African Rand</option>
        <option value="KRW">KRW – South Korean Won</option>
        <option value="TRY">TRY – Turkish Lira</option>
        <option value="AED">AED – UAE Dirham</option>
      </select>
      <div class="form-text" style="color:#8b949e;">Used to estimate your crypto asset values. Not a fiat wallet.</div>
    </div>
  </div>

  <div class="mb-3">
    <label class="form-label">
      Facebook Profile
      <span style="color:#8b949e;font-size:.78rem;">(optional)</span>
    </label>
    <input type="url" name="facebook_url" class="form-control" placeholder="https://facebook.com/yourprofile" autocomplete="url">
  </div>

  {if $ref}
  <input type="hidden" name="ref" value="{$ref|escape}">
  <div class="alert alert-info d-flex align-items-center gap-2 mb-3" style="font-size:.875rem;padding:.65rem 1rem;">
    <i class="fas fa-user-plus"></i>
    <span>Referred by a member (code: <strong>{$ref|escape}</strong>)</span>
  </div>
  {/if}

  <button type="submit" class="btn btn-primary w-100 mb-3">
    <i class="fas fa-user-plus me-2"></i>Create My Account
  </button>

  <hr class="auth-divider">

  <div class="text-center" style="color:#8b949e;font-size:.875rem;">
    Already have an account?&nbsp;<a href="/login" class="fw-semibold">Sign in</a>
  </div>
</form>
{/block}
