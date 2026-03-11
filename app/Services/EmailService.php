<?php
declare(strict_types=1);

namespace App\Services;

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;
use App\Models\EmailTemplateModel;

class EmailService
{
    private PHPMailer $mailer;
    private array $config;

    public function __construct()
    {
        $this->config = require dirname(__DIR__, 2) . '/config/mail.php';
        $this->mailer = $this->createMailer();
    }

    private function createMailer(): PHPMailer
    {
        $mail = new PHPMailer(true);
        $mail->isSMTP();
        $mail->Host       = $this->config['host'];
        $mail->SMTPAuth   = true;
        $mail->Username   = $this->config['username'];
        $mail->Password   = $this->config['password'];
        $mail->SMTPSecure = $this->config['encryption'] === 'ssl' ? PHPMailer::ENCRYPTION_SMTPS : PHPMailer::ENCRYPTION_STARTTLS;
        $mail->Port       = $this->config['port'];
        $mail->CharSet    = 'UTF-8';
        $mail->isHTML(true);
        $mail->setFrom($this->config['from_email'], $this->config['from_name']);
        return $mail;
    }

    public function send(string $to, string $subject, string $body, string $toName = ''): bool
    {
        try {
            $this->mailer->clearAddresses();
            $this->mailer->addAddress($to, $toName);
            $this->mailer->Subject = $subject;
            $this->mailer->Body    = $body;
            $this->mailer->AltBody = strip_tags($body);
            return $this->mailer->send();
        } catch (\Throwable $e) {
            error_log('EmailService error: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Send an email using a template slug.
     *
     * $vars may include: username, full_name, balance, active_balance,
     * total_deposits, total_withdrawals, total_earnings, referral_earnings,
     * whatsapp, email, date, site_name — and any custom template placeholders.
     */
    public function sendTemplate(string $slug, string $to, array $vars = [], string $toName = ''): bool
    {
        $templateModel = new EmailTemplateModel();
        $rendered = $templateModel->render($slug, $vars);
        if (!$rendered) {
            return false;
        }
        return $this->send($to, $rendered['subject'], $rendered['body'], $toName);
    }

    /**
     * Build common user vars for email templates.
     */
    public static function buildUserVars(array $user, array $stats = []): array
    {
        return array_merge([
            'username'          => $user['username']       ?? '',
            'full_name'         => trim(($user['first_name'] ?? '') . ' ' . ($user['last_name'] ?? '')),
            'email'             => $user['email']           ?? '',
            'whatsapp'          => $user['whatsapp_number'] ?? '',
            'balance'           => $stats['balance']           ?? '0.00',
            'active_balance'    => $stats['active_balance']    ?? '0.00',
            'total_deposits'    => $stats['total_deposits']    ?? '0.00',
            'total_withdrawals' => $stats['total_withdrawals'] ?? '0.00',
            'total_earnings'    => $stats['total_earnings']    ?? '0.00',
            'referral_earnings' => $stats['referral_earnings'] ?? '0.00',
        ], $stats);
    }
}
