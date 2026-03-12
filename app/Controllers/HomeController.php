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
