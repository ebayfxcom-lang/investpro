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
        $planModel = new PlanModel();
        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/admin/plans/create');
            }
            $prereqIds = array_filter(array_map('intval', (array)$request->post('requires_plan_ids', [])));
            $planModel->create([
                'name'                  => $request->post('name'),
                'description'           => $request->post('description', ''),
                'min_amount'            => (float)$request->post('min_amount'),
                'max_amount'            => (float)$request->post('max_amount'),
                'roi_percent'           => (float)$request->post('roi_percent'),
                'roi_period'            => $request->post('roi_period', 'daily'),
                'duration_value'        => max(1, (int)$request->post('duration_value', 30)),
                'duration_unit'         => $request->post('duration_unit', 'day'),
                'duration_days'         => $this->toDays((int)$request->post('duration_value', 30), $request->post('duration_unit', 'day')),
                'principal_return'      => (int)$request->post('principal_return', 1),
                'currency'              => strtoupper($request->post('currency', 'USD')),
                'status'                => $request->post('status', 'active'),
                'sort_order'            => (int)$request->post('sort_order', 0),
                'requires_plan_ids'     => !empty($prereqIds) ? json_encode(array_values($prereqIds)) : null,
                'prereq_min_deposits'   => max(0, (int)$request->post('prereq_min_deposits', 0)),
                'prereq_min_amount'     => max(0.0, (float)$request->post('prereq_min_amount', 0)),
                'prereq_deposit_status' => $request->post('prereq_deposit_status', 'any'),
                'created_at'            => date('Y-m-d H:i:s'),
            ]);
            (new AuditLog())->log('plan_created', 'New plan created: ' . $request->post('name'), Auth::id('admin'), $request->ip());
            $this->flash('success', 'Plan created successfully.');
            $this->redirect('/admin/plans');
        }
        $this->view('admin/plans/form', [
            'title'     => 'Create Plan',
            'plan'      => null,
            'all_plans' => $planModel->findAll('', [], 'sort_order ASC, id ASC'),
            'admin'     => Auth::user('admin'),
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
            $prereqIds = array_filter(array_map('intval', (array)$request->post('requires_plan_ids', [])));
            $planModel->update((int)$params['id'], [
                'name'                  => $request->post('name'),
                'description'           => $request->post('description', ''),
                'min_amount'            => (float)$request->post('min_amount'),
                'max_amount'            => (float)$request->post('max_amount'),
                'roi_percent'           => (float)$request->post('roi_percent'),
                'roi_period'            => $request->post('roi_period', 'daily'),
                'duration_value'        => max(1, (int)$request->post('duration_value', 30)),
                'duration_unit'         => $request->post('duration_unit', 'day'),
                'duration_days'         => $this->toDays((int)$request->post('duration_value', 30), $request->post('duration_unit', 'day')),
                'principal_return'      => (int)$request->post('principal_return', 1),
                'currency'              => strtoupper($request->post('currency', 'USD')),
                'status'                => $request->post('status', 'active'),
                'sort_order'            => (int)$request->post('sort_order', 0),
                'requires_plan_ids'     => !empty($prereqIds) ? json_encode(array_values($prereqIds)) : null,
                'prereq_min_deposits'   => max(0, (int)$request->post('prereq_min_deposits', 0)),
                'prereq_min_amount'     => max(0.0, (float)$request->post('prereq_min_amount', 0)),
                'prereq_deposit_status' => $request->post('prereq_deposit_status', 'any'),
                'updated_at'            => date('Y-m-d H:i:s'),
            ]);
            $this->flash('success', 'Plan updated successfully.');
            $this->redirect('/admin/plans');
        }
        $allPlans = $planModel->findAll('id != ?', [(int)$params['id']], 'sort_order ASC, id ASC');
        $this->view('admin/plans/form', [
            'title'     => 'Edit Plan',
            'plan'      => $plan,
            'all_plans' => $allPlans,
            'admin'     => Auth::user('admin'),
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

    /**
     * Convert duration_value + duration_unit to approximate days for legacy compatibility.
     * Used to keep duration_days column consistent with the actual plan duration.
     */
    private function toDays(int $value, string $unit): int
    {
        return match ($unit) {
            'hour'  => (int)ceil($value / 24),
            'day'   => $value,
            'week'  => $value * 7,
            'month' => $value * 30,
            'year'  => $value * 365,
            default => $value,
        };
    }
}
