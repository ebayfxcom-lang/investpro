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
                // Threshold mode: 'flat' = fixed rate, 'count' = based on downline count, 'deposit' = based on deposit volume
                'referral_threshold_mode'    => $request->post('referral_threshold_mode', 'flat'),
                'referral_min_downlines'     => (int)$request->post('referral_min_downlines', 0),
                'referral_min_deposit'       => (float)$request->post('referral_min_deposit', 0),
                // Level 1 threshold tiers (count-based)
                'referral_l1_threshold1_count' => (int)$request->post('referral_l1_threshold1_count', 0),
                'referral_l1_threshold1_rate'  => (float)$request->post('referral_l1_threshold1_rate', 5),
                'referral_l1_threshold2_count' => (int)$request->post('referral_l1_threshold2_count', 10),
                'referral_l1_threshold2_rate'  => (float)$request->post('referral_l1_threshold2_rate', 7),
                'referral_l1_threshold3_count' => (int)$request->post('referral_l1_threshold3_count', 25),
                'referral_l1_threshold3_rate'  => (float)$request->post('referral_l1_threshold3_rate', 10),
                // Level 2 threshold tiers
                'referral_l2_threshold1_rate'  => (float)$request->post('referral_l2_threshold1_rate', 2),
                'referral_l2_threshold2_rate'  => (float)$request->post('referral_l2_threshold2_rate', 3),
                'referral_l2_threshold3_rate'  => (float)$request->post('referral_l2_threshold3_rate', 5),
                // Level 3 threshold tiers
                'referral_l3_threshold1_rate'  => (float)$request->post('referral_l3_threshold1_rate', 1),
                'referral_l3_threshold2_rate'  => (float)$request->post('referral_l3_threshold2_rate', 1.5),
                'referral_l3_threshold3_rate'  => (float)$request->post('referral_l3_threshold3_rate', 2),
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
        $currencyModel = new \App\Models\CurrencyModel();
        $this->view('admin/settings/currencies', [
            'title'      => 'Currencies',
            'currencies' => $currencyModel->findAll('', [], 'sort_order ASC, code ASC'),
            'admin'      => Auth::user('admin'),
        ]);
    }

    public function emailTemplates(Request $request): void
    {
        $this->requireAuth('admin');
        $emailTemplateModel = new \App\Models\EmailTemplateModel();
        $this->view('admin/settings/email-templates', [
            'title'     => 'Email Templates',
            'templates' => $emailTemplateModel->findAll('', [], 'name ASC'),
            'admin'     => Auth::user('admin'),
        ]);
    }

    public function security(Request $request): void
    {
        $this->requireAuth('admin');
        $settingsModel = new SettingsModel();
        $settings = $settingsModel->getAll();

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/admin/settings/security');
            }
            $allowed = ['two_factor_enabled', 'email_verification', 'registration_enabled',
                        'maintenance_mode', 'maintenance_message'];
            $data = [];
            foreach ($allowed as $key) {
                $val = $request->post($key);
                if ($val !== null) {
                    $data[$key] = $val;
                }
            }
            $settingsModel->setMany($data);
            (new AuditLog())->log('security_settings_updated', 'Security settings updated', Auth::id('admin'), $request->ip());
            $this->flash('success', 'Security settings saved.');
            $this->redirect('/admin/settings/security');
        }

        $this->view('admin/settings/security', [
            'title'    => 'Security Settings',
            'settings' => $settings,
            'admin'    => Auth::user('admin'),
        ]);
    }
}
