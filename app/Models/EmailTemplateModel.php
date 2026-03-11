<?php
declare(strict_types=1);

namespace App\Models;

use App\Core\Model;

class EmailTemplateModel extends Model
{
    protected string $table = 'email_templates';

    public function findBySlug(string $slug): ?array
    {
        return $this->db->fetchOne("SELECT * FROM email_templates WHERE slug = ?", [$slug]);
    }

    public function render(string $slug, array $vars = []): ?array
    {
        $template = $this->findBySlug($slug);
        if (!$template || $template['status'] !== 'active') {
            return null;
        }

        $subject = $template['subject'];
        $body    = $template['body'];

        // Add default vars
        $vars['date']      = $vars['date']      ?? date('Y-m-d H:i:s');
        if (!isset($vars['site_name'])) {
            static $siteName = null;
            $siteName ??= (require dirname(__DIR__, 2) . '/config/app.php')['name'] ?? 'InvestPro';
            $vars['site_name'] = $siteName;
        }

        foreach ($vars as $key => $value) {
            $placeholder = '{' . $key . '}';
            $subject = str_replace($placeholder, (string)$value, $subject);
            $body    = str_replace($placeholder, (string)$value, $body);
        }

        return ['subject' => $subject, 'body' => $body];
    }
}
