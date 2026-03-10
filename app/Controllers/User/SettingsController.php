<?php
declare(strict_types=1);

namespace App\Controllers\User;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\UserModel;

class SettingsController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('user');
        $userId    = (int)Auth::id('user');
        $userModel = new UserModel();
        $user      = $userModel->find($userId);

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/user/settings');
            }
            $userModel->update($userId, [
                'first_name'          => trim($request->post('first_name', '')),
                'last_name'           => trim($request->post('last_name', '')),
                'phone'               => trim($request->post('phone', '')),
                'whatsapp_number'     => trim($request->post('whatsapp_number', '')),
                'facebook_url'        => trim($request->post('facebook_url', '')) ?: null,
                'country'             => trim($request->post('country', '')),
                'preferred_currency'  => strtoupper(trim($request->post('preferred_currency', 'USD'))),
                'payout_details'      => trim($request->post('payout_details', '')) ?: null,
                'communication_prefs' => trim($request->post('communication_prefs', 'email')),
                'updated_at'          => date('Y-m-d H:i:s'),
            ]);
            (new AuditLog())->log('profile_updated', 'User updated profile', $userId, $request->ip());
            $this->flash('success', 'Profile updated successfully.');
            $this->redirect('/user/settings');
        }

        $this->view('user/settings', [
            'title' => 'Account Settings',
            'user'  => $user,
        ]);
    }
}
