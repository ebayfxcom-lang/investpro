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
        if (!$template) return null;

        $subject = $template['subject'];
        $body    = $template['body'];

        foreach ($vars as $key => $value) {
            $subject = str_replace('{' . $key . '}', $value, $subject);
            $body    = str_replace('{' . $key . '}', $value, $body);
        }

        return ['subject' => $subject, 'body' => $body];
    }
}
