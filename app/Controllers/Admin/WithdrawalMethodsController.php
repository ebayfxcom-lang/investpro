<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\WithdrawalMethodModel;

class WithdrawalMethodsController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');
        $model = new WithdrawalMethodModel();

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/admin/withdrawal-methods');
            }

            $action = $request->post('action', '');

            try {
                if ($action === 'create') {
                    $model->create([
                        'name'          => trim($request->post('name', '')),
                        'currency'      => strtoupper(trim($request->post('currency', ''))),
                        'network'       => trim($request->post('network', '')),
                        'min_amount'    => max(0, (float)$request->post('min_amount', 10)),
                        'fee'           => max(0, (float)$request->post('fee', 0)),
                        'fee_percent'   => max(0, (float)$request->post('fee_percent', 0)),
                        'address_regex' => trim($request->post('address_regex', '')) ?: null,
                        'requires_memo' => (int)$request->post('requires_memo', 0),
                        'instructions'  => trim($request->post('instructions', '')) ?: null,
                        'status'        => $request->post('status', 'active'),
                        'sort_order'    => (int)$request->post('sort_order', 0),
                        'created_at'    => date('Y-m-d H:i:s'),
                    ]);
                    (new AuditLog())->log('withdrawal_method_created', 'Withdrawal method created', Auth::id('admin'), $request->ip());
                    $this->flash('success', 'Withdrawal method created.');
                    $this->redirect('/admin/withdrawal-methods');
                }

                if ($action === 'toggle') {
                    $id     = (int)$request->post('method_id', 0);
                    $method = $model->find($id);
                    if ($method) {
                        $newStatus = $method['status'] === 'active' ? 'inactive' : 'active';
                        $model->update($id, ['status' => $newStatus, 'updated_at' => date('Y-m-d H:i:s')]);
                        (new AuditLog())->log('withdrawal_method_toggled', "Method #{$id} set to {$newStatus}", Auth::id('admin'), $request->ip());
                        $this->flash('success', "Method {$newStatus}.");
                    }
                    $this->redirect('/admin/withdrawal-methods');
                }

                if ($action === 'delete') {
                    $id = (int)$request->post('method_id', 0);
                    if ($id > 0) {
                        $model->delete($id);
                        (new AuditLog())->log('withdrawal_method_deleted', "Method #{$id} deleted", Auth::id('admin'), $request->ip());
                        $this->flash('success', 'Method deleted.');
                    }
                    $this->redirect('/admin/withdrawal-methods');
                }

                if ($action === 'update') {
                    $id = (int)$request->post('method_id', 0);
                    if ($id > 0) {
                        $model->update($id, [
                            'name'          => trim($request->post('name', '')),
                            'currency'      => strtoupper(trim($request->post('currency', ''))),
                            'network'       => trim($request->post('network', '')),
                            'min_amount'    => max(0, (float)$request->post('min_amount', 10)),
                            'fee'           => max(0, (float)$request->post('fee', 0)),
                            'fee_percent'   => max(0, (float)$request->post('fee_percent', 0)),
                            'address_regex' => trim($request->post('address_regex', '')) ?: null,
                            'requires_memo' => (int)$request->post('requires_memo', 0),
                            'instructions'  => trim($request->post('instructions', '')) ?: null,
                            'status'        => $request->post('status', 'active'),
                            'sort_order'    => (int)$request->post('sort_order', 0),
                            'updated_at'    => date('Y-m-d H:i:s'),
                        ]);
                        (new AuditLog())->log('withdrawal_method_updated', "Method #{$id} updated", Auth::id('admin'), $request->ip());
                        $this->flash('success', 'Method updated.');
                    }
                    $this->redirect('/admin/withdrawal-methods');
                }
            } catch (\Throwable $e) {
                error_log('WithdrawalMethodsController error: ' . $e->getMessage());
                $this->flash('error', 'Operation failed. Please ensure the database migration has been applied.');
                $this->redirect('/admin/withdrawal-methods');
            }
        }

        $methods = $model->getAllMethods();

        $this->view('admin/withdrawal-methods/index', [
            'title'   => 'Withdrawal Methods',
            'methods' => $methods,
            'admin'   => Auth::user('admin'),
        ]);
    }
}
