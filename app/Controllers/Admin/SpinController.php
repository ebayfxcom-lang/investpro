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

            if ($action === 'grant_spins') {
                $targetUserId = (int)$request->post('target_user_id', 0);
                $spinCount    = max(1, (int)$request->post('spin_count', 1));
                $spinType     = $request->post('spin_type', 'free');
                if ($targetUserId > 0) {
                    $userSpinModel = new \App\Models\UserSpinModel();
                    $userSpinModel->getOrCreate($targetUserId);
                    if ($spinType === 'paid') {
                        $userSpinModel->addPaidSpins($targetUserId, $spinCount);
                    } else {
                        $this->grantFreeSpins($targetUserId, $spinCount);
                    }
                    // Log to spin_history with admin grant marker
                    $historyModel->create([
                        'user_id'          => $targetUserId,
                        'reward_id'        => null,
                        'spin_type'        => $spinType,
                        'reward_type'      => 'spin_credits',
                        'reward_value'     => $spinCount,
                        'reward_label'     => "Admin grant: {$spinCount} {$spinType} spin(s)",
                        'granted_by_admin' => Auth::id('admin'),
                        'created_at'       => date('Y-m-d H:i:s'),
                    ]);
                    (new AuditLog())->log('spin_grant', "Admin granted {$spinCount} {$spinType} spin(s) to user #{$targetUserId}", Auth::id('admin'), $request->ip());
                    $this->flash('success', "Granted {$spinCount} {$spinType} spin(s) to user #{$targetUserId}.");
                }
                $this->redirect('/admin/spin');
            }

            if ($action === 'update_reward') {
                $slotId = (int)$request->post('reward_id', 0);
                if ($slotId > 0) {
                    $rewardModel->update($slotId, [
                        'label'        => trim($request->post('label', '')),
                        'spin_mode'    => in_array($request->post('spin_mode'), ['free','paid','both']) ? $request->post('spin_mode') : 'both',
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

    private function grantFreeSpins(int $userId, int $count): void
    {
        \App\Core\Database::getInstance()->query(
            "UPDATE user_spins SET free_spins = free_spins + ?, updated_at = NOW() WHERE user_id = ?",
            [$count, $userId]
        );
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
