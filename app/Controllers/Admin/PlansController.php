<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\PlanModel;

class PlansController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');
        $planModel = new PlanModel();
        $plans = $planModel->findAll('', [], 'sort_order ASC, id ASC');
        $this->view('admin/plans/index', [
            'title' => 'Investment Plans',
            'plans' => $plans,
            'admin' => Auth::user('admin'),
        ]);
    }

    public function create(Request $request): void
    {
        $this->requireAuth('admin');
        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/admin/plans/create');
            }
            $planModel = new PlanModel();
            $planModel->create([
                'name'          => $request->post('name'),
                'description'   => $request->post('description', ''),
                'min_amount'    => (float)$request->post('min_amount'),
                'max_amount'    => (float)$request->post('max_amount'),
                'roi_percent'   => (float)$request->post('roi_percent'),
                'roi_period'    => $request->post('roi_period', 'daily'),
                'duration_days' => (int)$request->post('duration_days'),
                'principal_return' => (int)$request->post('principal_return', 1),
                'currency'      => strtoupper($request->post('currency', 'USD')),
                'status'        => $request->post('status', 'active'),
                'sort_order'    => (int)$request->post('sort_order', 0),
                'created_at'    => date('Y-m-d H:i:s'),
            ]);
            (new AuditLog())->log('plan_created', 'New plan created: ' . $request->post('name'), Auth::id('admin'), $request->ip());
            $this->flash('success', 'Plan created successfully.');
            $this->redirect('/admin/plans');
        }
        $this->view('admin/plans/form', [
            'title' => 'Create Plan',
            'plan'  => null,
            'admin' => Auth::user('admin'),
        ]);
    }

    public function edit(Request $request, array $params): void
    {
        $this->requireAuth('admin');
        $planModel = new PlanModel();
        $plan = $planModel->find((int)$params['id']);
        if (!$plan) {
            $this->flash('error', 'Plan not found.');
            $this->redirect('/admin/plans');
        }
        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect("/admin/plans/{$params['id']}/edit");
            }
            $planModel->update((int)$params['id'], [
                'name'          => $request->post('name'),
                'description'   => $request->post('description', ''),
                'min_amount'    => (float)$request->post('min_amount'),
                'max_amount'    => (float)$request->post('max_amount'),
                'roi_percent'   => (float)$request->post('roi_percent'),
                'roi_period'    => $request->post('roi_period', 'daily'),
                'duration_days' => (int)$request->post('duration_days'),
                'principal_return' => (int)$request->post('principal_return', 1),
                'currency'      => strtoupper($request->post('currency', 'USD')),
                'status'        => $request->post('status', 'active'),
                'sort_order'    => (int)$request->post('sort_order', 0),
                'updated_at'    => date('Y-m-d H:i:s'),
            ]);
            $this->flash('success', 'Plan updated successfully.');
            $this->redirect('/admin/plans');
        }
        $this->view('admin/plans/form', [
            'title' => 'Edit Plan',
            'plan'  => $plan,
            'admin' => Auth::user('admin'),
        ]);
    }

    public function delete(Request $request, array $params): void
    {
        $this->requireAuth('admin');
        if (!Csrf::validateRequest($request)) {
            $this->flash('error', 'Invalid CSRF token.');
            $this->redirect('/admin/plans');
        }
        $planModel = new PlanModel();
        $planModel->delete((int)$params['id']);
        $this->flash('success', 'Plan deleted.');
        $this->redirect('/admin/plans');
    }
}
