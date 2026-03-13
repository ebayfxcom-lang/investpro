<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\KycModel;

class KycController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');

        $kycModel = new KycModel();
        $page     = (int)($request->get('page', 1));
        $status   = $request->get('status', '');
        $data     = $kycModel->paginate($page, 20, $status);

        $this->view('admin/kyc/index', [
            'title'  => 'KYC Submissions',
            'data'   => $data,
            'status' => $status,
            'admin'  => Auth::user('admin'),
        ]);
    }

    public function show(Request $request, array $params): void
    {
        $this->requireAuth('admin');

        $kycModel = new KycModel();
        try {
            $kyc = $kycModel->find((int)$params['id']);
        } catch (\Throwable) {
            $kyc = null;
        }
        if (!$kyc) {
            $this->flash('error', 'KYC submission not found.');
            $this->redirect('/admin/kyc');
        }

        $this->view('admin/kyc/show', [
            'title' => 'KYC Review',
            'kyc'   => $kyc,
            'admin' => Auth::user('admin'),
        ]);
    }

    public function approve(Request $request, array $params): void
    {
        $this->requireAuth('admin');
        if (!Csrf::validateRequest($request)) {
            $this->flash('error', 'Invalid CSRF token.');
            $this->redirect('/admin/kyc');
        }

        $kycModel = new KycModel();
        try {
            $kyc = $kycModel->find((int)$params['id']);
            if ($kyc) {
                $kycModel->update((int)$params['id'], [
                    'status'      => 'approved',
                    'review_note' => trim($request->post('review_note', '')),
                    'reviewed_by' => Auth::id('admin'),
                    'reviewed_at' => date('Y-m-d H:i:s'),
                ]);
                (new AuditLog())->log('kyc_approved', "KYC #{$params['id']} approved", Auth::id('admin'), $request->ip());
                $this->flash('success', 'KYC submission approved.');
            }
        } catch (\Throwable $e) {
            error_log('KycController approve error: ' . $e->getMessage());
            $this->flash('error', 'Could not update KYC status.');
        }
        $this->redirect('/admin/kyc');
    }

    public function reject(Request $request, array $params): void
    {
        $this->requireAuth('admin');
        if (!Csrf::validateRequest($request)) {
            $this->flash('error', 'Invalid CSRF token.');
            $this->redirect('/admin/kyc');
        }

        $kycModel = new KycModel();
        try {
            $kyc = $kycModel->find((int)$params['id']);
            if ($kyc) {
                $kycModel->update((int)$params['id'], [
                    'status'      => 'rejected',
                    'review_note' => trim($request->post('review_note', '')),
                    'reviewed_by' => Auth::id('admin'),
                    'reviewed_at' => date('Y-m-d H:i:s'),
                ]);
                (new AuditLog())->log('kyc_rejected', "KYC #{$params['id']} rejected", Auth::id('admin'), $request->ip());
                $this->flash('success', 'KYC submission rejected.');
            }
        } catch (\Throwable $e) {
            error_log('KycController reject error: ' . $e->getMessage());
            $this->flash('error', 'Could not update KYC status.');
        }
        $this->redirect('/admin/kyc');
    }
}
