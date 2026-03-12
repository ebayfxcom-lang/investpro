<form method="POST" action="/user/kyc" enctype="multipart/form-data">
  <input type="hidden" name="_csrf_token" value="{$csrf_token}">

  <div class="mb-3">
    <label class="form-label fw-semibold">Document Type <span class="text-danger">*</span></label>
    <select name="document_type" class="form-select" required>
      <option value="national_id">National ID Card</option>
      <option value="passport">Passport</option>
      <option value="drivers_license">Driver's License</option>
      <option value="residence_permit">Residence Permit</option>
    </select>
  </div>

  <div class="mb-3">
    <label class="form-label fw-semibold">Document Number <span class="text-danger">*</span></label>
    <input type="text" name="document_number" class="form-control" required maxlength="100">
  </div>

  <div class="mb-3">
    <label class="form-label fw-semibold">Front Image <span class="text-danger">*</span></label>
    <input type="file" name="front_image" class="form-control" accept=".jpg,.jpeg,.png,.pdf" required>
    <div class="form-text">JPG, PNG or PDF. Max 5MB.</div>
  </div>

  <div class="mb-3">
    <label class="form-label fw-semibold">Back Image <span class="text-muted">(optional)</span></label>
    <input type="file" name="back_image" class="form-control" accept=".jpg,.jpeg,.png,.pdf">
    <div class="form-text">If applicable (e.g. ID card).</div>
  </div>

  <div class="mb-4">
    <label class="form-label fw-semibold">Selfie with Document <span class="text-muted">(optional)</span></label>
    <input type="file" name="selfie_image" class="form-control" accept=".jpg,.jpeg,.png">
    <div class="form-text">Optional: photo of you holding your document.</div>
  </div>

  <button type="submit" class="btn btn-primary w-100">
    <i class="fas fa-upload me-2"></i>Submit for Verification
  </button>
</form>
