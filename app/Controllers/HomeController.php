<?php
declare(strict_types=1);

namespace App\Controllers;

use App\Core\Controller;
use App\Core\Request;
use App\Models\PlanModel;
use App\Models\SeoPageModel;

class HomeController extends Controller
{
    public function index(Request $request): void
    {
        $planModel = new PlanModel();
        $plans     = $planModel->getActivePlans();
        $seo       = $this->getSeo('homepage');
        $news      = $this->getLatestNews(3);

        $this->view('public/home', [
            'title' => 'Welcome',
            'plans' => $plans,
            'news'  => $news,
            'seo'   => $seo,
        ]);
    }

    public function about(Request $request): void
    {
        $this->view('public/about', [
            'title' => 'About Us',
            'seo'   => $this->getSeo('about'),
        ]);
    }

    public function faq(Request $request): void
    {
        $items = [];
        try {
            $db    = \App\Core\Database::getInstance();
            $items = $db->fetchAll("SELECT * FROM faqs WHERE status = 'active' ORDER BY sort_order, id");
        } catch (\Throwable $e) {}

        $this->view('public/faq', [
            'title' => 'FAQ',
            'items' => $items,
            'seo'   => $this->getSeo('faq'),
        ]);
    }

    public function plans(Request $request): void
    {
        $planModel = new PlanModel();
        $plans     = $planModel->getActivePlans();

        $this->view('public/plans', [
            'title' => 'Investment Plans',
            'plans' => $plans,
            'seo'   => $this->getSeo('plans'),
        ]);
    }

    public function news(Request $request): void
    {
        $items = [];
        try {
            $db    = \App\Core\Database::getInstance();
            $items = $db->fetchAll("SELECT * FROM news WHERE status = 'published' ORDER BY created_at DESC LIMIT 20");
        } catch (\Throwable $e) {}

        $this->view('public/news', [
            'title' => 'News',
            'items' => $items,
            'seo'   => $this->getSeo('news'),
        ]);
    }

    public function contact(Request $request): void
    {
        $this->view('public/contact', [
            'title' => 'Contact Us',
            'seo'   => $this->getSeo('support'),
        ]);
    }

    public function community(Request $request): void
    {
        $page      = (int)($request->get('page', 1));
        $postModel = new \App\Models\CommunityPostModel();
        $feed      = $postModel->getFeed($page, 20);

        $this->view('public/community', [
            'title' => 'Community',
            'feed'  => $feed,
            'seo'   => $this->getSeo('community'),
        ]);
    }

    public function payoutProofs(Request $request): void
    {
        $proofs = [];
        try {
            $db     = \App\Core\Database::getInstance();
            $proofs = $db->fetchAll(
                "SELECT w.id, w.amount, w.currency, w.status, w.created_at, w.proof_image,
                        u.username
                 FROM withdrawals w
                 LEFT JOIN users u ON u.id = w.user_id
                 WHERE w.status = 'approved' AND w.proof_image IS NOT NULL AND w.proof_image != ''
                 ORDER BY w.created_at DESC LIMIT 50"
            );
        } catch (\Throwable $e) {}

        $this->view('public/payout-proofs', [
            'title'  => 'Payout Proofs',
            'proofs' => $proofs,
            'seo'    => $this->getSeo('payout-proofs'),
        ]);
    }

    private function getSeo(string $key): ?array
    {
        try {
            $model = new SeoPageModel();
            return $model->getByKey($key);
        } catch (\Throwable $e) {
            return null;
        }
    }

    private function getLatestNews(int $limit): array
    {
        try {
            $db = \App\Core\Database::getInstance();
            return $db->fetchAll(
                "SELECT * FROM news WHERE status = 'published' ORDER BY created_at DESC LIMIT " . $limit
            );
        } catch (\Throwable $e) {
            return [];
        }
    }
}
