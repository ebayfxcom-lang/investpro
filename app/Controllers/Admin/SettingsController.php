<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\SettingsModel;

class SettingsController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');
        $settingsModel = new SettingsModel();
        $settings = $settingsModel->getAll();

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/admin/settings');
            }
            $allowed = ['site_name','site_email','site_url','currency','referral_percent',
                        'min_deposit','max_deposit','min_withdrawal','max_withdrawal',
                        'withdrawal_fee','maintenance_mode','maintenance_message',
                        'registration_enabled','email_verification','two_factor_enabled'];
            $data = [];
            foreach ($allowed as $key) {
                $val = $request->post($key);
                if ($val !== null) {
                    $data[$key] = $val;
                }
            }
            $settingsModel->setMany($data);
            (new AuditLog())->log('settings_updated', 'Site settings updated', Auth::id('admin'), $request->ip());
            $this->flash('success', 'Settings saved.');
            $this->redirect('/admin/settings');
        }

        $this->view('admin/settings/index', [
            'title'    => 'Settings',
            'settings' => $settings,
            'admin'    => Auth::user('admin'),
        ]);
    }

    public function referral(Request $request): void
    {
        $this->requireAuth('admin');
        $settingsModel = new SettingsModel();
        $settings = $settingsModel->getGroup('referral_');

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/admin/settings/referral');
            }
            $settingsModel->setMany([
                'referral_percent'    => (float)$request->post('referral_percent', 5),
                'referral_levels'     => (int)$request->post('referral_levels', 1),
                'referral_level2'     => (float)$request->post('referral_level2', 0),
                'referral_level3'     => (float)$request->post('referral_level3', 0),
                'referral_on_deposit' => (int)$request->post('referral_on_deposit', 1),
            ]);
            $this->flash('success', 'Referral settings saved.');
            $this->redirect('/admin/settings/referral');
        }

        $this->view('admin/settings/referral', [
            'title'    => 'Referral Settings',
            'settings' => $settings,
            'admin'    => Auth::user('admin'),
        ]);
    }

    public function currencies(Request $request): void
    {
        $this->requireAuth('admin');
        $this->view('admin/settings/currencies', [
            'title' => 'Currencies',
            'admin' => Auth::user('admin'),
        ]);
    }

    public function emailTemplates(Request $request): void
    {
        $this->requireAuth('admin');
        $this->view('admin/settings/email-templates', [
            'title' => 'Email Templates',
            'admin' => Auth::user('admin'),
        ]);
    }

    public function security(Request $request): void
    {
        $this->requireAuth('admin');
        $this->view('admin/settings/security', [
            'title' => 'Security Settings',
            'admin' => Auth::user('admin'),
        ]);
    }
}
