<?php
declare(strict_types=1);

namespace App\Controllers\User;

use App\Core\Controller;
use App\Core\Request;
use App\Models\ScamReportModel;

class ScamReportController extends Controller
{
    public function create(Request $request): void
    {
        if ($request->isPost()) {
            $url   = filter_var(trim($request->post('website_url', '')), FILTER_SANITIZE_URL);
            $desc  = trim($request->post('description', ''));

            if (!$url || !$desc) {
                $this->flash('error', 'Website URL and description are required.');
                $this->redirect('/report-scam');
            }

            $model = new ScamReportModel();
            $model->create([
                'website_url'    => $url,
                'description'    => $desc,
                'scam_date'      => $request->post('scam_date', null) ?: null,
                'evidence_note'  => trim($request->post('evidence_note', '')),
                'reporter_name'  => trim($request->post('reporter_name', '')),
                'reporter_email' => trim($request->post('reporter_email', '')),
                'reporter_phone' => trim($request->post('reporter_phone', '')),
                'status'         => 'pending',
                'ip_address'     => $request->ip(),
                'created_at'     => date('Y-m-d H:i:s'),
            ]);
            $this->flash('success', 'Thank you. Your scam report has been submitted and will be reviewed.');
            $this->redirect('/report-scam');
        }

        $this->view('user/scam-report/create', [
            'title' => 'Report a Scam Website',
        ]);
    }
}
