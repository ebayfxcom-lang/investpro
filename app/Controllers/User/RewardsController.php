<?php
declare(strict_types=1);

namespace App\Controllers\User;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\RewardOfferModel;
use App\Models\RewardClaimModel;
use App\Models\SettingsModel;
use App\Models\WalletModel;
use App\Models\UserSpinModel;

class RewardsController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('user');

        $settingsModel = new SettingsModel();
        if (!$settingsModel->get('rewards_hub_enabled', '0')) {
            $this->flash('error', 'Rewards Hub is not currently available.');
            $this->redirect('/user/dashboard');
        }

        $userId     = (int)Auth::id('user');
        $offerModel = new RewardOfferModel();
        $claimModel = new RewardClaimModel();

        $activeOffers  = $offerModel->getActiveOffers();
        $expiredOffers = $offerModel->getExpiredOffers();
        $userClaims    = $claimModel->getUserClaims($userId);
        $claimedIds    = array_flip(array_column($userClaims, 'offer_id'));

        // Track impressions
        foreach ($activeOffers as $offer) {
            $offerModel->incrementImpressions((int)$offer['id']);
        }

        $this->view('user/rewards/index', [
            'title'          => 'Rewards Hub',
            'active_offers'  => $activeOffers,
            'expired_offers' => $expiredOffers,
            'claimed_ids'    => $claimedIds,
            'user_claims'    => $userClaims,
        ]);
    }

    public function claim(Request $request): void
    {
        $this->requireAuth('user');

        $settingsModel = new SettingsModel();
        if (!$settingsModel->get('rewards_hub_enabled', '0')) {
            $this->flash('error', 'Rewards Hub is not currently available.');
            $this->redirect('/user/dashboard');
        }

        if (!Csrf::validateRequest($request)) {
            $this->flash('error', 'Invalid CSRF token.');
            $this->redirect('/user/rewards');
        }

        $userId     = (int)Auth::id('user');
        $offerId    = (int)$request->post('offer_id', 0);
        $offerModel = new RewardOfferModel();
        $claimModel = new RewardClaimModel();

        $offer = $offerModel->find($offerId);
        if (!$offer || $offer['status'] !== 'active') {
            $this->flash('error', 'Offer not found or no longer active.');
            $this->redirect('/user/rewards');
        }

        if ($claimModel->hasClaimed($offerId, $userId)) {
            $this->flash('error', 'You have already claimed this offer.');
            $this->redirect('/user/rewards');
        }

        // Check max claims
        if ((int)$offer['max_claims'] > 0 && $offerModel->getClaimCount($offerId) >= (int)$offer['max_claims']) {
            $this->flash('error', 'This offer has reached its maximum number of claims.');
            $this->redirect('/user/rewards');
        }

        // Apply reward
        $walletModel   = new WalletModel();
        $userSpinModel = new UserSpinModel();

        match ($offer['reward_type']) {
            'balance_credit' => $walletModel->credit($userId, 'USD', (float)$offer['reward_value']),
            'spin_credits'   => $userSpinModel->addPaidSpins($userId, (int)$offer['reward_value']),
            default          => null,
        };

        $claimModel->claim($offerId, $userId);
        (new AuditLog())->log('reward_claimed', "Reward offer #{$offerId} claimed", $userId, $request->ip());
        $this->flash('success', 'Reward claimed successfully!');
        $this->redirect('/user/rewards');
    }
}
