<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\SpinSettingsModel;
use App\Models\SpinRewardModel;
use App\Models\SpinHistoryModel;

class SpinController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');

        $settingsModel = new SpinSettingsModel();
        $rewardModel   = new SpinRewardModel();
        $historyModel  = new SpinHistoryModel();

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/admin/spin');
            }

            $action = $request->post('action', '');

            if ($action === 'update_settings') {
                $settingsModel->saveSettings([
                    'enabled'          => (int)($request->post('enabled', 0)),
                    'spin_price'       => max(0.01, (float)$request->post('spin_price', 1.0)),
                    'daily_free_spins' => max(0, (int)$request->post('daily_free_spins', 1)),
                    'updated_at'       => date('Y-m-d H:i:s'),
                ]);
                (new AuditLog())->log('spin_settings_updated', 'Spin settings updated', Auth::id('admin'), $request->ip());
                $this->flash('success', 'Spin settings updated.');
                $this->redirect('/admin/spin');
            }

            if ($action === 'update_reward') {
                $slotId = (int)$request->post('reward_id', 0);
                if ($slotId > 0) {
                    $rewardModel->update($slotId, [
                        'label'        => trim($request->post('label', '')),
                        'reward_type'  => $request->post('reward_type', 'no_reward'),
                        'reward_value' => max(0, (float)$request->post('reward_value', 0)),
                        'probability'  => max(0.0001, (float)$request->post('probability', 8.333333)),
                        'color'        => trim($request->post('color', '#1e40af')),
                        'status'       => $request->post('status', 'active'),
                    ]);
                    (new AuditLog())->log('spin_reward_updated', "Spin reward #{$slotId} updated", Auth::id('admin'), $request->ip());
                    $this->flash('success', 'Reward slot updated.');
                }
                $this->redirect('/admin/spin');
            }
        }

        $settings = $settingsModel->getSettings();
        $rewards  = $rewardModel->getAllRewards();
        $history  = $historyModel->getRecentHistory(50);

        $this->view('admin/spin/index', [
            'title'    => 'Spin Rewards',
            'settings' => $settings,
            'rewards'  => $rewards,
            'history'  => $history,
            'admin'    => Auth::user('admin'),
        ]);
    }

    public function history(Request $request): void
    {
        $this->requireAuth('admin');

        $historyModel = new SpinHistoryModel();
        $page         = (int)($request->get('page', 1));
        $data         = $historyModel->paginateWithUsers($page, 30);

        $this->view('admin/spin/history', [
            'title'   => 'Spin History',
            'data'    => $data,
            'admin'   => Auth::user('admin'),
        ]);
    }
}
