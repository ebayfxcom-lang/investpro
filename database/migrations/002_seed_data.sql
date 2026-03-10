-- InvestPro Seed Data
-- Migration 002: Default data

-- Default currencies
INSERT IGNORE INTO `currencies` (`code`, `name`, `symbol`, `type`, `rate_to_usd`, `status`, `sort_order`) VALUES
('USD', 'US Dollar',     '$',   'fiat',   1.00000000, 'active', 1),
('EUR', 'Euro',          '€',   'fiat',   0.92000000, 'active', 2),
('BTC', 'Bitcoin',       '₿',   'crypto', 0.00002500, 'active', 3),
('ETH', 'Ethereum',      'Ξ',   'crypto', 0.00040000, 'active', 4),
('USDT','Tether',        '₮',   'crypto', 1.00000000, 'active', 5);

-- Default investment plans
INSERT IGNORE INTO `plans` (`name`, `description`, `min_amount`, `max_amount`, `roi_percent`, `roi_period`, `duration_days`, `principal_return`, `currency`, `status`, `sort_order`) VALUES
('Starter',    'Ideal for new investors. Low risk, steady returns.',     10.00,    999.99,   1.50, 'daily', 30,  1, 'USD', 'active', 1),
('Growth',     'Balanced plan for moderate investors.',                  1000.00,  4999.99,  2.00, 'daily', 60,  1, 'USD', 'active', 2),
('Premium',    'Higher returns for serious investors.',                  5000.00,  24999.99, 2.50, 'daily', 90,  1, 'USD', 'active', 3),
('Elite',      'Maximum returns for large capital investments.',         25000.00, 0.00,     3.00, 'daily', 120, 1, 'USD', 'active', 4);

-- Default settings
INSERT IGNORE INTO `settings` (`key`, `value`) VALUES
('site_name',             'InvestPro'),
('site_email',            'admin@investpro.com'),
('site_url',              'http://localhost'),
('currency',              'USD'),
('referral_percent',      '5'),
('referral_levels',       '1'),
('referral_level2',       '0'),
('referral_level3',       '0'),
('referral_on_deposit',   '1'),
('min_deposit',           '10'),
('max_deposit',           '0'),
('min_withdrawal',        '10'),
('max_withdrawal',        '100000'),
('withdrawal_fee',        '0'),
('maintenance_mode',      '0'),
('maintenance_message',   'We are currently under maintenance. Please check back soon.'),
('registration_enabled',  '1'),
('email_verification',    '0'),
('two_factor_enabled',    '0');

-- Default email templates
INSERT IGNORE INTO `email_templates` (`slug`, `name`, `subject`, `body`, `variables`) VALUES
('welcome', 'Welcome Email',
 'Welcome to {site_name}!',
 '<h2>Welcome {username}!</h2><p>Thank you for joining {site_name}. Your account has been created successfully.</p><p>Start investing today and grow your wealth!</p>',
 'site_name,username,email'),

('deposit_confirmed', 'Deposit Confirmed',
 'Your deposit has been confirmed - {site_name}',
 '<h2>Deposit Confirmed</h2><p>Dear {username},</p><p>Your deposit of <strong>{amount} {currency}</strong> on plan <strong>{plan_name}</strong> has been confirmed.</p><p>Expected returns: {roi_percent}% {roi_period}</p>',
 'username,amount,currency,plan_name,roi_percent,roi_period'),

('withdrawal_approved', 'Withdrawal Approved',
 'Your withdrawal has been approved - {site_name}',
 '<h2>Withdrawal Approved</h2><p>Dear {username},</p><p>Your withdrawal of <strong>{amount} {currency}</strong> has been approved and is being processed.</p>',
 'username,amount,currency'),

('password_changed', 'Password Changed',
 'Your password has been changed - {site_name}',
 '<h2>Password Changed</h2><p>Dear {username},</p><p>Your account password has been successfully changed.</p><p>If you did not make this change, please contact support immediately.</p>',
 'username,site_name');

-- Default FAQ
INSERT IGNORE INTO `faq` (`question`, `answer`, `sort_order`, `status`) VALUES
('How do I get started?',
 'Simply register an account, fund your wallet, and choose an investment plan that suits your goals.',
 1, 'active'),
('What are the minimum and maximum deposit amounts?',
 'The minimum deposit starts from $10. Maximum varies by plan. Check our Plans page for details.',
 2, 'active'),
('When do I receive my earnings?',
 'Earnings are calculated and credited to your wallet daily, weekly, or monthly depending on your chosen plan.',
 3, 'active'),
('How do I withdraw my funds?',
 'Go to Withdraw Funds in your dashboard, enter the amount and your payment details. Withdrawals are processed within 24-48 hours.',
 4, 'active'),
('Is my investment secure?',
 'We use bank-grade security including 256-bit SSL encryption, two-factor authentication, and cold storage for crypto assets.',
 5, 'active');

-- Default admin user
-- ⚠️  SECURITY: password is Admin@123456 hashed with Argon2id.
--     This hash uses a fixed salt for portability in seed data only.
--     You MUST change the admin password immediately after first login
--     via the admin panel so a properly salted hash is stored.
--     NEVER reuse this hash value in production.
INSERT IGNORE INTO `users` (`username`, `email`, `password`, `role`, `status`, `referral_code`, `email_verified`, `created_at`) VALUES
('admin',
 'admin@investpro.com',
 '$argon2id$v=19$m=65536,t=4,p=3$c29tZXNhbHQ$FmLbIeqyP/PxMy5Bn/OwelZWsGvJAEZ8FBkGKSz7l88',
 'superadmin',
 'active',
 'ADMIN001',
 1,
 NOW());
