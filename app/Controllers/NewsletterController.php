<?php
declare(strict_types=1);

namespace App\Controllers;

use App\Core\Controller;
use App\Core\Request;
use App\Core\Csrf;
use App\Models\NewsletterGuestModel;

class NewsletterController extends Controller
{
    public function subscribe(Request $request): void
    {
        if ($request->isPost()) {
            if (!Csrf::validateRequest($request)) {
                $this->flash('error', 'Invalid request. Please try again.');
                $this->redirect('/newsletter/subscribe');
            }

            $email    = trim((string)$request->post('email', ''));
            $whatsapp = trim((string)$request->post('whatsapp', '')) ?: null;

            if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
                $this->flash('error', 'Please enter a valid email address.');
                $this->redirect('/newsletter/subscribe');
            }

            $result = (new NewsletterGuestModel())->subscribe($email, $whatsapp);
            if ($result === 'already_subscribed') {
                $this->flash('info', 'You are already subscribed.');
            } else {
                $this->flash('success', 'You have been subscribed successfully!');
            }
            $this->redirect('/newsletter/subscribe');
        }

        $this->view('newsletter/subscribe', [
            'title'      => 'Newsletter Subscribe',
            'subscribed' => false,
        ]);
    }

    public function unsubscribe(Request $request): void
    {
        $token   = trim((string)$request->get('token', ''));
        $success = false;

        if ($token !== '') {
            $success = (new NewsletterGuestModel())->unsubscribeByToken($token);
        }

        $this->view('newsletter/unsubscribe', [
            'title'   => 'Unsubscribe',
            'success' => $success,
        ]);
    }
}
