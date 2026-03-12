<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\ScamReportModel;

class ScamReportsController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');
        $model = new ScamReportModel();

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/admin/scam-reports');
            }
            $action = $request->post('action', '');
            $id     = (int)$request->post('report_id', 0);

            if (in_array($action, ['reviewed', 'confirmed', 'dismissed'], true) && $id > 0) {
                $model->update($id, [
                    'status'      => $action,
                    'admin_notes' => trim($request->post('admin_notes', '')),
                    'updated_at'  => date('Y-m-d H:i:s'),
                ]);
                (new AuditLog())->log('scam_report_updated', "Scam report #{$id} marked as {$action}", Auth::id('admin'), $request->ip());
                $this->flash('success', "Report marked as {$action}.");
            }

            if ($action === 'delete' && $id > 0) {
                $model->delete($id);
                (new AuditLog())->log('scam_report_deleted', "Scam report #{$id} deleted", Auth::id('admin'), $request->ip());
                $this->flash('success', 'Report deleted.');
            }

            $this->redirect('/admin/scam-reports');
        }

        $page   = (int)($request->get('page', 1));
        $status = $request->get('status', '');
        $where  = $status ? 'status = ?' : '';
        $params = $status ? [$status] : [];
        $data   = $model->paginate($page, 20, $where, $params, 'created_at DESC');
        $stats  = $model->getStats();

        $this->view('admin/scam-reports/index', [
            'title'          => 'Scam Reports',
            'data'           => $data,
            'stats'          => $stats,
            'current_status' => $status,
            'admin'          => Auth::user('admin'),
        ]);
    }

    public function show(Request $request, array $params): void
    {
        $this->requireAuth('admin');
        $model  = new ScamReportModel();
        $report = $model->find((int)$params['id']);
        if (!$report) {
            $this->flash('error', 'Report not found.');
            $this->redirect('/admin/scam-reports');
        }
        $this->view('admin/scam-reports/view', [
            'title'  => 'Scam Report #' . $report['id'],
            'report' => $report,
            'admin'  => Auth::user('admin'),
        ]);
    }
}
