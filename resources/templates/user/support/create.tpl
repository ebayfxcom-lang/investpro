{extends file="layouts/user.tpl"}
{block name="content"}
<div class="row justify-content-center">
  <div class="col-lg-7">
    <div class="card">
      <div class="card-header py-3">
        <h6 class="mb-0 fw-bold"><i class="fas fa-headset me-2 text-warning"></i>Open a Support Ticket</h6>
      </div>
      <div class="card-body">
        <form method="POST" action="/user/support/create">
          <input type="hidden" name="_csrf_token" value="{$csrf_token}">
          <div class="mb-3">
            <label class="form-label fw-semibold">Department</label>
            <select name="department_id" class="form-select" required>
              <option value="">Select Department</option>
              {foreach $depts as $d}
              <option value="{$d.id}">{$d.name|escape}</option>
              {/foreach}
            </select>
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Subject</label>
            <input type="text" name="subject" class="form-control" required maxlength="300"
                   placeholder="Brief description of your issue">
          </div>
          <div class="mb-3">
            <label class="form-label fw-semibold">Priority</label>
            <select name="priority" class="form-select">
              <option value="low">Low</option>
              <option value="normal" selected>Normal</option>
              <option value="high">High</option>
              <option value="urgent">Urgent</option>
            </select>
          </div>
          <div class="mb-4">
            <label class="form-label fw-semibold">Message</label>
            <textarea name="body" class="form-control" rows="6" required maxlength="5000"
                      placeholder="Describe your issue in detail..."></textarea>
          </div>
          <button type="submit" class="btn btn-accent w-100">Submit Ticket</button>
        </form>
      </div>
    </div>
  </div>
</div>
{/block}
