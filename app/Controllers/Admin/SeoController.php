<?php
declare(strict_types=1);

namespace App\Controllers\Admin;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Auth;
use App\Core\Csrf;
use App\Core\AuditLog;
use App\Models\SeoPageModel;

class SeoController extends Controller
{
    public function index(Request $request): void
    {
        $this->requireAuth('admin');
        $model = new SeoPageModel();

        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid CSRF token.');
                $this->redirect('/admin/seo');
            }

            $pageKey = trim($request->post('page_key', ''));
            if ($pageKey) {
                try {
                    $model->upsert($pageKey, [
                        'page_label'    => trim($request->post('page_label', $pageKey)),
                        'meta_title'    => trim($request->post('meta_title', '')) ?: null,
                        'meta_desc'     => trim($request->post('meta_desc', '')) ?: null,
                        'meta_keywords' => trim($request->post('meta_keywords', '')) ?: null,
                        'og_title'      => trim($request->post('og_title', '')) ?: null,
                        'og_desc'       => trim($request->post('og_desc', '')) ?: null,
                        'og_image'      => trim($request->post('og_image', '')) ?: null,
                        'canonical_url' => trim($request->post('canonical_url', '')) ?: null,
                        'schema_json'   => trim($request->post('schema_json', '')) ?: null,
                        'admin_guide'   => trim($request->post('admin_guide', '')) ?: null,
                        'user_guide'    => trim($request->post('user_guide', '')) ?: null,
                    ]);
                    (new AuditLog())->log('seo_updated', "SEO page '{$pageKey}' updated", Auth::id('admin'), $request->ip());
                    $this->flash('success', 'SEO settings saved.');
                } catch (\Throwable $e) {
                    error_log('SeoController upsert error: ' . $e->getMessage());
                    $this->flash('error', 'Could not save SEO settings. Please run the latest migration first.');
                }
            }
            $this->redirect('/admin/seo');
        }

        $pages = $model->getAllPages();

        $this->view('admin/seo/index', [
            'title' => 'SEO & Meta Manager',
            'pages' => $pages,
            'admin' => Auth::user('admin'),
        ]);
    }
}
