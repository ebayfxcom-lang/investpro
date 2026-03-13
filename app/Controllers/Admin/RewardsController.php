<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\RewardOfferModel;
use App\Models\RewardClaimModel;

class RewardsController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');

        $offerModel = new RewardOfferModel();

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/admin/rewards');
            }

            $action = $request->post('action', '');

            if ($action === 'create_offer') {
                $offerModel->create([
                    'title'            => trim($request->post('title', '')),
                    'description'      => trim($request->post('description', '')),
                    'reward_type'      => $request->post('reward_type', 'balance_credit'),
                    'reward_value'     => max(0, (float)$request->post('reward_value', 0)),
                    'eligibility_rule' => $request->post('eligibility_rule', 'first_deposit'),
                    'rule_value'       => max(0, (float)$request->post('rule_value', 1)),
                    'start_at'         => $request->post('start_at') ? date('Y-m-d H:i:s', (int)strtotime((string)$request->post('start_at'))) : null,
                    'end_at'           => $request->post('end_at') ? date('Y-m-d H:i:s', (int)strtotime((string)$request->post('end_at'))) : null,
                    'max_claims'       => max(0, (int)$request->post('max_claims', 0)),
                    'status'           => $request->post('status', 'active'),
                    'sort_order'       => (int)$request->post('sort_order', 0),
                    'created_at'       => date('Y-m-d H:i:s'),
                ]);
                (new AuditLog())->log('reward_offer_created', 'Reward offer created', Auth::id('admin'), $request->ip());
                $this->flash('success', 'Offer created.');
                $this->redirect('/admin/rewards');
            }

            if ($action === 'delete_offer') {
                $offerId = (int)$request->post('offer_id', 0);
                if ($offerId > 0) {
                    $offerModel->delete($offerId);
                    (new AuditLog())->log('reward_offer_deleted', "Offer #{$offerId} deleted", Auth::id('admin'), $request->ip());
                    $this->flash('success', 'Offer deleted.');
                }
                $this->redirect('/admin/rewards');
            }

            if ($action === 'toggle_offer') {
                $offerId = (int)$request->post('offer_id', 0);
                $offer   = $offerModel->find($offerId);
                if ($offer) {
                    $newStatus = $offer['status'] === 'active' ? 'inactive' : 'active';
                    $offerModel->update($offerId, ['status' => $newStatus]);
                    $this->flash('success', "Offer {$newStatus}.");
                }
                $this->redirect('/admin/rewards');
            }
        }

        $page = (int)($request->get('page', 1));
        $data = $offerModel->adminPaginate($page, 20);

        // Attach claim counts to each offer
        $claimModel = new RewardClaimModel();
        foreach ($data['items'] as &$offer) {
            $offer['claim_count'] = $offerModel->getClaimCount((int)$offer['id']);
        }
        unset($offer);

        $this->view('admin/rewards/index', [
            'title' => 'Rewards Hub',
            'data'  => $data,
            'admin' => Auth::user('admin'),
        ]);
    }
}
