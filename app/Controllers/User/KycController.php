<?php
declare(strict_types=1);

namespace App\Controllers\User;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\KycModel;
use App\Models\SettingsModel;

class KycController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('user');

        $settingsModel = new SettingsModel();
        if (!$settingsModel->get('kyc_enabled', '0')) {
            $this->flash('error', 'KYC verification is not currently available.');
            $this->redirect('/user/dashboard');
        }

        $userId   = (int)Auth::id('user');
        $kycModel = new KycModel();
        $existing = $kycModel->getByUser($userId);

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/user/kyc');
            }

            // Only allow submission if not already approved or pending
            if ($existing && in_array($existing['status'], ['approved', 'pending'])) {
                $this->flash('error', 'Your KYC is already ' . $existing['status'] . '.');
                $this->redirect('/user/kyc');
            }

            $docType   = $request->post('document_type', 'national_id');
            $docNumber = trim($request->post('document_number', ''));

            $allowedTypes = ['passport', 'national_id', 'drivers_license', 'residence_permit'];
            if (!in_array($docType, $allowedTypes, true)) {
                $this->flash('error', 'Invalid document type.');
                $this->redirect('/user/kyc');
            }
            if (empty($docNumber)) {
                $this->flash('error', 'Document number is required.');
                $this->redirect('/user/kyc');
            }

            // Handle file uploads
            $frontImage = null;
            $backImage  = null;
            $selfieImage = null;
            $uploadDir  = dirname(__DIR__, 3) . '/storage/kyc/' . $userId . '/';
            if (!is_dir($uploadDir)) {
                mkdir($uploadDir, 0755, true);
            }

            foreach (['front_image' => 'front', 'back_image' => 'back', 'selfie_image' => 'selfie'] as $field => $label) {
                if (!empty($_FILES[$field]['tmp_name']) && is_uploaded_file($_FILES[$field]['tmp_name'])) {
                    $ext = strtolower(pathinfo($_FILES[$field]['name'], PATHINFO_EXTENSION));
                    if (!in_array($ext, ['jpg', 'jpeg', 'png', 'pdf'], true)) {
                        $this->flash('error', "Invalid file type for {$label} image. Allowed: jpg, png, pdf.");
                        $this->redirect('/user/kyc');
                    }
                    $fileName = $label . '_' . time() . '.' . $ext;
                    move_uploaded_file($_FILES[$field]['tmp_name'], $uploadDir . $fileName);
                    $$field = 'kyc/' . $userId . '/' . $fileName;
                }
            }

            if (!$frontImage) {
                $this->flash('error', 'Front image of document is required.');
                $this->redirect('/user/kyc');
            }

            $kycModel->upsert($userId, [
                'document_type'   => $docType,
                'document_number' => $docNumber,
                'front_image'     => $frontImage,
                'back_image'      => $backImage,
                'selfie_image'    => $selfieImage,
                'status'          => 'pending',
                'review_note'     => null,
            ]);

            (new AuditLog())->log('kyc_submitted', 'KYC documents submitted', $userId, $request->ip());
            $this->flash('success', 'KYC documents submitted! We will review within 24–48 hours.');
            $this->redirect('/user/kyc');
        }

        $this->view('user/kyc/index', [
            'title'    => 'KYC Verification',
            'kyc'      => $existing,
            'authUser' => Auth::user('user'),
        ]);
    }
}
