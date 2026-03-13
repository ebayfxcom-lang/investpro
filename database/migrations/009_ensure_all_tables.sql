-- Migration 009: Ensure all tables and columns exist (catch-up migration)
-- This migration is safe to run on any database state (001-only up to 008-complete).
-- All statements use IF NOT EXISTS / ADD COLUMN IF NOT EXISTS so they are idempotent.

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 1. FAQ: ensure category_id, category, status, updated_at columns
-- ============================================================
ALTER TABLE `faq`
  ADD COLUMN IF NOT EXISTS `category_id`  INT UNSIGNED DEFAULT NULL
    COMMENT 'FK to faq_categories' AFTER `sort_order`,
  ADD COLUMN IF NOT EXISTS `category`
    ENUM('general','account','deposits','withdrawals','referral','investments','security')
    NOT NULL DEFAULT 'general' COMMENT 'FAQ category slug' AFTER `category_id`,
  ADD COLUMN IF NOT EXISTS `status`
    ENUM('active','inactive') NOT NULL DEFAULT 'active'
    COMMENT 'Visibility status' AFTER `category`,
  ADD COLUMN IF NOT EXISTS `updated_at` DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
    AFTER `created_at`;

-- ============================================================
-- 2. FAQ categories table
-- ============================================================
CREATE TABLE IF NOT EXISTS `faq_categories` (
  `id`         INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `name`       VARCHAR(100)  NOT NULL,
  `slug`       VARCHAR(100)  NOT NULL,
  `status`     ENUM('active','inactive') NOT NULL DEFAULT 'active',
  `sort_order` INT           NOT NULL DEFAULT 0,
  `created_at` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME      DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_faq_cat_slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `faq_categories` (`name`, `slug`, `status`, `sort_order`) VALUES
('General',      'general',      'active', 1),
('Account',      'account',      'active', 2),
('Deposits',     'deposits',     'active', 3),
('Withdrawals',  'withdrawals',  'active', 4),
('Referral',     'referral',     'active', 5),
('Investments',  'investments',  'active', 6),
('Security',     'security',     'active', 7);

-- ============================================================
-- 3. Deposit wallets table
-- ============================================================
CREATE TABLE IF NOT EXISTS `deposit_wallets` (
  `id`             INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `currency_code`  VARCHAR(10)   NOT NULL,
  `network`        VARCHAR(50)   NOT NULL DEFAULT '' COMMENT 'e.g. ERC20, TRC20, BEP20',
  `wallet_address` VARCHAR(255)  NOT NULL,
  `memo`           VARCHAR(100)  DEFAULT NULL,
  `instructions`   TEXT          DEFAULT NULL,
  `min_deposit`    DECIMAL(20,8) NOT NULL DEFAULT 0.00000000,
  `confirmations`  TINYINT       NOT NULL DEFAULT 3,
  `status`         ENUM('active','inactive') NOT NULL DEFAULT 'active',
  `created_at`     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`     DATETIME      DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_dw_currency` (`currency_code`),
  KEY `idx_dw_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 4. Deposits: add extended columns from migration 006
-- ============================================================
ALTER TABLE `deposits`
  ADD COLUMN IF NOT EXISTS `network`               VARCHAR(50)    DEFAULT NULL    AFTER `currency`,
  ADD COLUMN IF NOT EXISTS `deposit_address`       VARCHAR(255)   DEFAULT NULL    AFTER `network`,
  ADD COLUMN IF NOT EXISTS `actual_crypto_amount`  DECIMAL(20,8)  DEFAULT NULL    AFTER `deposit_address`,
  ADD COLUMN IF NOT EXISTS `fiat_amount`           DECIMAL(20,8)  DEFAULT NULL    AFTER `actual_crypto_amount`,
  ADD COLUMN IF NOT EXISTS `rate_snapshot`         TEXT           DEFAULT NULL    AFTER `fiat_amount`,
  ADD COLUMN IF NOT EXISTS `usd_amount`            DECIMAL(20,8)  DEFAULT NULL    AFTER `rate_snapshot`,
  ADD COLUMN IF NOT EXISTS `eur_amount`            DECIMAL(20,8)  DEFAULT NULL    AFTER `usd_amount`,
  ADD COLUMN IF NOT EXISTS `detected_amount`       DECIMAL(20,8)  DEFAULT NULL    AFTER `eur_amount`,
  ADD COLUMN IF NOT EXISTS `detected_tx_hash`      VARCHAR(255)   DEFAULT NULL    AFTER `detected_amount`,
  ADD COLUMN IF NOT EXISTS `confirmations_count`   TINYINT        NOT NULL DEFAULT 0 AFTER `detected_tx_hash`,
  ADD COLUMN IF NOT EXISTS `confirmed_at`          DATETIME       DEFAULT NULL    AFTER `confirmations_count`,
  ADD COLUMN IF NOT EXISTS `memo`                  VARCHAR(100)   DEFAULT NULL    AFTER `confirmed_at`,
  ADD COLUMN IF NOT EXISTS `expiry_at`             DATETIME       DEFAULT NULL    AFTER `memo`;

-- ============================================================
-- 5. Withdrawals: add extended columns from migration 006
-- ============================================================
ALTER TABLE `withdrawals`
  ADD COLUMN IF NOT EXISTS `network`               VARCHAR(50)    DEFAULT NULL    AFTER `currency`,
  ADD COLUMN IF NOT EXISTS `actual_crypto_amount`  DECIMAL(20,8)  DEFAULT NULL    AFTER `network`,
  ADD COLUMN IF NOT EXISTS `fiat_amount`           DECIMAL(20,8)  DEFAULT NULL    AFTER `actual_crypto_amount`,
  ADD COLUMN IF NOT EXISTS `rate_snapshot`         TEXT           DEFAULT NULL    AFTER `fiat_amount`,
  ADD COLUMN IF NOT EXISTS `usd_amount`            DECIMAL(20,8)  DEFAULT NULL    AFTER `rate_snapshot`,
  ADD COLUMN IF NOT EXISTS `eur_amount`            DECIMAL(20,8)  DEFAULT NULL    AFTER `usd_amount`,
  ADD COLUMN IF NOT EXISTS `sent_tx_hash`          VARCHAR(255)   DEFAULT NULL    AFTER `eur_amount`,
  ADD COLUMN IF NOT EXISTS `admin_note`            TEXT           DEFAULT NULL    AFTER `sent_tx_hash`,
  ADD COLUMN IF NOT EXISTS `processed_at`          DATETIME       DEFAULT NULL    AFTER `admin_note`,
  ADD COLUMN IF NOT EXISTS `processed_by`          INT UNSIGNED   DEFAULT NULL    AFTER `processed_at`;

-- ============================================================
-- 6. Withdrawal methods table
-- ============================================================
CREATE TABLE IF NOT EXISTS `withdrawal_methods` (
  `id`            INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `name`          VARCHAR(100)  NOT NULL,
  `currency`      VARCHAR(10)   NOT NULL,
  `network`       VARCHAR(50)   NOT NULL DEFAULT '',
  `min_amount`    DECIMAL(20,8) NOT NULL DEFAULT 10,
  `fee`           DECIMAL(20,8) NOT NULL DEFAULT 0,
  `fee_percent`   DECIMAL(5,2)  NOT NULL DEFAULT 0,
  `address_regex` VARCHAR(500)  DEFAULT NULL,
  `requires_memo` TINYINT(1)    NOT NULL DEFAULT 0,
  `instructions`  TEXT          DEFAULT NULL,
  `status`        ENUM('active','inactive') NOT NULL DEFAULT 'active',
  `sort_order`    INT           NOT NULL DEFAULT 0,
  `created_at`    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    DATETIME      DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_wm_status` (`status`),
  KEY `idx_wm_currency` (`currency`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `withdrawal_methods` (`id`, `name`, `currency`, `network`, `min_amount`, `fee`, `fee_percent`, `status`, `sort_order`) VALUES
(1, 'Bitcoin (BTC)',         'BTC',  'BTC',   0.0001,  0.00002000, 0.00, 'inactive', 1),
(2, 'Ethereum (ERC20)',      'ETH',  'ERC20', 0.01,    0.00050000, 0.00, 'inactive', 2),
(3, 'USDT (TRC20)',          'USDT', 'TRC20', 10.00,   1.00000000, 0.00, 'inactive', 3),
(4, 'USDT (ERC20)',          'USDT', 'ERC20', 20.00,   5.00000000, 0.00, 'inactive', 4),
(5, 'BNB (BEP20)',           'BNB',  'BEP20', 0.1,     0.00050000, 0.00, 'inactive', 5);

-- ============================================================
-- 7. Users: add columns from migrations 006, 007
-- ============================================================
ALTER TABLE `users`
  ADD COLUMN IF NOT EXISTS `two_factor_backup_codes`  TEXT        DEFAULT NULL  AFTER `two_factor_secret`,
  ADD COLUMN IF NOT EXISTS `two_factor_confirmed_at`  DATETIME    DEFAULT NULL  AFTER `two_factor_backup_codes`,
  ADD COLUMN IF NOT EXISTS `theme_preference`         VARCHAR(10) NOT NULL DEFAULT 'dark' AFTER `two_factor_confirmed_at`,
  ADD COLUMN IF NOT EXISTS `team_role_id`             INT UNSIGNED DEFAULT NULL AFTER `role`,
  ADD COLUMN IF NOT EXISTS `account_type`             ENUM('normal','representative','team_leader') NOT NULL DEFAULT 'normal' AFTER `team_role_id`,
  ADD COLUMN IF NOT EXISTS `preferred_currency`       VARCHAR(10) NOT NULL DEFAULT 'USD' AFTER `account_type`;

-- ============================================================
-- 8. Plans: add conditional prerequisite columns (migration 007)
-- ============================================================
ALTER TABLE `plans`
  ADD COLUMN IF NOT EXISTS `requires_plan_ids`      TEXT          DEFAULT NULL AFTER `sort_order`,
  ADD COLUMN IF NOT EXISTS `prereq_min_deposits`    INT           NOT NULL DEFAULT 0 AFTER `requires_plan_ids`,
  ADD COLUMN IF NOT EXISTS `prereq_min_amount`      DECIMAL(20,8) NOT NULL DEFAULT 0 AFTER `prereq_min_deposits`,
  ADD COLUMN IF NOT EXISTS `prereq_deposit_status`  ENUM('any','active','completed') NOT NULL DEFAULT 'any' AFTER `prereq_min_amount`;

-- ============================================================
-- 9. Plans: flexible duration columns (migration 004)
-- ============================================================
ALTER TABLE `plans`
  ADD COLUMN IF NOT EXISTS `duration_value` INT UNSIGNED NOT NULL DEFAULT 30 AFTER `roi_period`,
  ADD COLUMN IF NOT EXISTS `duration_unit`  ENUM('hour','day','week','month','year') NOT NULL DEFAULT 'day' AFTER `duration_value`;

-- Back-fill duration_value from duration_days where still at default
UPDATE `plans` SET `duration_value` = `duration_days`, `duration_unit` = 'day'
  WHERE `duration_value` = 30 AND `duration_unit` = 'day' AND `duration_days` != 30;

-- ============================================================
-- 10. KYC submissions table
-- ============================================================
CREATE TABLE IF NOT EXISTS `kyc_submissions` (
  `id`              INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`         INT UNSIGNED  NOT NULL,
  `document_type`   ENUM('passport','national_id','drivers_license','residence_permit') NOT NULL DEFAULT 'national_id',
  `document_number` VARCHAR(100)  NOT NULL,
  `front_image`     VARCHAR(500)  DEFAULT NULL,
  `back_image`      VARCHAR(500)  DEFAULT NULL,
  `selfie_image`    VARCHAR(500)  DEFAULT NULL,
  `status`          ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `review_note`     TEXT          DEFAULT NULL,
  `reviewed_by`     INT UNSIGNED  DEFAULT NULL,
  `reviewed_at`     DATETIME      DEFAULT NULL,
  `created_at`      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      DATETIME      DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_kyc_user` (`user_id`),
  KEY `idx_kyc_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 11. Community tables
-- ============================================================
CREATE TABLE IF NOT EXISTS `community_posts` (
  `id`             INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`        INT UNSIGNED  NOT NULL,
  `content`        TEXT          NOT NULL,
  `is_bot`         TINYINT(1)    NOT NULL DEFAULT 0,
  `bot_profile_id` INT UNSIGNED  DEFAULT NULL,
  `likes_count`    INT UNSIGNED  NOT NULL DEFAULT 0,
  `status`         ENUM('active','hidden','deleted') NOT NULL DEFAULT 'active',
  `created_at`     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`     DATETIME      DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_cp_user` (`user_id`),
  KEY `idx_cp_status` (`status`),
  KEY `idx_cp_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `community_comments` (
  `id`         INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `post_id`    INT UNSIGNED  NOT NULL,
  `user_id`    INT UNSIGNED  NOT NULL,
  `content`    TEXT          NOT NULL,
  `status`     ENUM('active','hidden','deleted') NOT NULL DEFAULT 'active',
  `created_at` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_cc_post` (`post_id`),
  KEY `idx_cc_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `community_likes` (
  `id`         INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `post_id`    INT UNSIGNED  NOT NULL,
  `user_id`    INT UNSIGNED  NOT NULL,
  `created_at` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_cl_post_user` (`post_id`, `user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `bot_profiles` (
  `id`             INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `display_name`   VARCHAR(80)   NOT NULL,
  `avatar_url`     VARCHAR(500)  DEFAULT NULL,
  `bio`            TEXT          DEFAULT NULL,
  `tone_category`  ENUM('paying_status','platform_performance','investment_excitement','support_praise','withdrawal_received','general') NOT NULL DEFAULT 'general',
  `keywords`       TEXT          DEFAULT NULL,
  `post_frequency` INT           NOT NULL DEFAULT 60,
  `status`         ENUM('active','inactive') NOT NULL DEFAULT 'active',
  `last_posted_at` DATETIME      DEFAULT NULL,
  `created_at`     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`     DATETIME      DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 12. Reward hub tables
-- ============================================================
CREATE TABLE IF NOT EXISTS `reward_offers` (
  `id`               INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `title`            VARCHAR(200)  NOT NULL,
  `description`      TEXT          DEFAULT NULL,
  `banner_url`       VARCHAR(500)  DEFAULT NULL,
  `reward_type`      ENUM('balance_credit','spin_credits','bonus_percent','custom') NOT NULL DEFAULT 'balance_credit',
  `reward_value`     DECIMAL(20,8) NOT NULL DEFAULT 0,
  `eligibility_rule` ENUM('first_deposit','invest_plan','complete_deposits','refer_users','buy_spins','daily_login','earn_spin_rewards','custom') NOT NULL DEFAULT 'first_deposit',
  `rule_value`       DECIMAL(20,8) NOT NULL DEFAULT 1,
  `start_at`         DATETIME      DEFAULT NULL,
  `end_at`           DATETIME      DEFAULT NULL,
  `max_claims`       INT           NOT NULL DEFAULT 0,
  `status`           ENUM('active','inactive','expired') NOT NULL DEFAULT 'active',
  `sort_order`       INT           NOT NULL DEFAULT 0,
  `impressions`      INT UNSIGNED  NOT NULL DEFAULT 0,
  `created_at`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`       DATETIME      DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ro_status` (`status`),
  KEY `idx_ro_start_end` (`start_at`, `end_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `reward_claims` (
  `id`         INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `offer_id`   INT UNSIGNED  NOT NULL,
  `user_id`    INT UNSIGNED  NOT NULL,
  `status`     ENUM('pending','completed','rejected') NOT NULL DEFAULT 'completed',
  `claimed_at` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_rc_offer_user` (`offer_id`, `user_id`),
  KEY `idx_rc_user` (`user_id`),
  KEY `idx_rc_offer` (`offer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `reward_progress` (
  `id`         INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `offer_id`   INT UNSIGNED  NOT NULL,
  `user_id`    INT UNSIGNED  NOT NULL,
  `progress`   DECIMAL(20,8) NOT NULL DEFAULT 0,
  `updated_at` DATETIME      DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_rp_offer_user` (`offer_id`, `user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 13. Newsletters table (migration 004)
-- ============================================================
CREATE TABLE IF NOT EXISTS `newsletters` (
  `id`           INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `subject`      VARCHAR(255)  NOT NULL,
  `content`      LONGTEXT      NOT NULL,
  `recipients`   ENUM('all','active','segment') NOT NULL DEFAULT 'all',
  `segment_data` TEXT          DEFAULT NULL,
  `status`       ENUM('draft','sent','scheduled') NOT NULL DEFAULT 'draft',
  `sent_at`      DATETIME      DEFAULT NULL,
  `sent_count`   INT UNSIGNED  NOT NULL DEFAULT 0,
  `created_by`   INT UNSIGNED  DEFAULT NULL,
  `created_at`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`   DATETIME      DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_newsletters_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 14. Newsletter guests table (migration 007)
-- ============================================================
CREATE TABLE IF NOT EXISTS `newsletter_guests` (
  `id`           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `email`        VARCHAR(150) NOT NULL,
  `whatsapp`     VARCHAR(30)  DEFAULT NULL,
  `status`       ENUM('subscribed','unsubscribed') NOT NULL DEFAULT 'subscribed',
  `token`        VARCHAR(80)  NOT NULL,
  `consented_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_ng_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 15. Scam reports table (migration 004)
-- ============================================================
CREATE TABLE IF NOT EXISTS `scam_reports` (
  `id`             INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `website_url`    VARCHAR(500)  NOT NULL,
  `description`    TEXT          NOT NULL,
  `scam_date`      DATE          DEFAULT NULL,
  `evidence_note`  TEXT          DEFAULT NULL,
  `reporter_name`  VARCHAR(100)  DEFAULT NULL,
  `reporter_email` VARCHAR(150)  DEFAULT NULL,
  `reporter_phone` VARCHAR(30)   DEFAULT NULL,
  `status`         ENUM('pending','reviewed','confirmed','dismissed') NOT NULL DEFAULT 'pending',
  `admin_notes`    TEXT          DEFAULT NULL,
  `ip_address`     VARCHAR(45)   DEFAULT NULL,
  `created_at`     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`     DATETIME      DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_sr_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 16. User notices and reads (migration 007)
-- ============================================================
CREATE TABLE IF NOT EXISTS `user_notices` (
  `id`           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `title`        VARCHAR(200) NOT NULL,
  `body`         TEXT         NOT NULL,
  `notice_type`  ENUM('info','success','warning','danger') NOT NULL DEFAULT 'info',
  `display_type` ENUM('banner','popup','both') NOT NULL DEFAULT 'banner',
  `target`       ENUM('all','deposited','free','team','representatives','leaders') NOT NULL DEFAULT 'all',
  `status`       ENUM('draft','published','expired') NOT NULL DEFAULT 'draft',
  `starts_at`    DATETIME     DEFAULT NULL,
  `ends_at`      DATETIME     DEFAULT NULL,
  `created_by`   INT UNSIGNED DEFAULT NULL,
  `created_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`   DATETIME     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_notices_status` (`status`),
  KEY `idx_notices_target` (`target`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `user_notice_reads` (
  `id`        INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `notice_id` INT UNSIGNED NOT NULL,
  `user_id`   INT UNSIGNED NOT NULL,
  `read_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_notice_user` (`notice_id`, `user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 17. Support tickets and departments (migration 007)
-- ============================================================
CREATE TABLE IF NOT EXISTS `ticket_departments` (
  `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`        VARCHAR(100) NOT NULL,
  `slug`        VARCHAR(100) NOT NULL,
  `description` VARCHAR(300) DEFAULT NULL,
  `sort_order`  INT          NOT NULL DEFAULT 0,
  `status`      ENUM('active','inactive') NOT NULL DEFAULT 'active',
  `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_dept_slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `ticket_departments` (`name`, `slug`, `sort_order`) VALUES
('General Support',    'general',     1),
('Financial',          'financial',   2),
('Technical',          'technical',   3),
('Security',           'security',    4),
('KYC / Verification', 'kyc',         5),
('Partnership',        'partnership', 6);

CREATE TABLE IF NOT EXISTS `support_tickets` (
  `id`            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `reference`     VARCHAR(20)  NOT NULL,
  `user_id`       INT UNSIGNED DEFAULT NULL,
  `guest_email`   VARCHAR(150) DEFAULT NULL,
  `guest_token`   VARCHAR(80)  DEFAULT NULL,
  `department_id` INT UNSIGNED NOT NULL,
  `subject`       VARCHAR(300) NOT NULL,
  `priority`      ENUM('low','normal','high','urgent') NOT NULL DEFAULT 'normal',
  `status`        ENUM('open','in_progress','waiting','resolved','closed') NOT NULL DEFAULT 'open',
  `assigned_to`   INT UNSIGNED DEFAULT NULL,
  `last_reply_at` DATETIME     DEFAULT NULL,
  `closed_at`     DATETIME     DEFAULT NULL,
  `created_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    DATETIME     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_ticket_ref` (`reference`),
  KEY `idx_ticket_user` (`user_id`),
  KEY `idx_ticket_status` (`status`),
  KEY `idx_ticket_dept` (`department_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ticket_replies` (
  `id`               INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `ticket_id`        INT UNSIGNED NOT NULL,
  `user_id`          INT UNSIGNED DEFAULT NULL,
  `is_staff`         TINYINT(1)   NOT NULL DEFAULT 0,
  `is_internal_note` TINYINT(1)   NOT NULL DEFAULT 0,
  `body`             TEXT         NOT NULL,
  `attachment`       VARCHAR(500) DEFAULT NULL,
  `created_at`       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_reply_ticket` (`ticket_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 18. SEO pages table (migration 007)
-- ============================================================
CREATE TABLE IF NOT EXISTS `seo_pages` (
  `id`            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `page_key`      VARCHAR(100) NOT NULL,
  `page_label`    VARCHAR(200) NOT NULL,
  `meta_title`    VARCHAR(300) DEFAULT NULL,
  `meta_desc`     TEXT         DEFAULT NULL,
  `meta_keywords` TEXT         DEFAULT NULL,
  `og_title`      VARCHAR(300) DEFAULT NULL,
  `og_desc`       TEXT         DEFAULT NULL,
  `og_image`      VARCHAR(500) DEFAULT NULL,
  `canonical_url` VARCHAR(500) DEFAULT NULL,
  `schema_json`   TEXT         DEFAULT NULL,
  `admin_guide`   TEXT         DEFAULT NULL,
  `user_guide`    TEXT         DEFAULT NULL,
  `updated_at`    DATETIME     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_seo_key` (`page_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `seo_pages` (`page_key`, `page_label`) VALUES
('homepage',   'Homepage'),
('login',      'Login Page'),
('register',   'Register Page'),
('dashboard',  'User Dashboard'),
('news',       'News'),
('faq',        'FAQ'),
('plans',      'Investment Plans'),
('support',    'Support / Contact'),
('community',  'Community'),
('about',      'About Us');

-- ============================================================
-- 19. Team roles and permissions (migration 007)
-- ============================================================
CREATE TABLE IF NOT EXISTS `team_roles` (
  `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`        VARCHAR(80)  NOT NULL,
  `label`       VARCHAR(120) NOT NULL,
  `description` TEXT         DEFAULT NULL,
  `is_system`   TINYINT(1)   NOT NULL DEFAULT 0,
  `sort_order`  INT          NOT NULL DEFAULT 0,
  `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_role_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `team_roles` (`name`, `label`, `is_system`, `sort_order`) VALUES
('founder',           'Founder',                1, 1),
('superadmin',        'Super Admin',            1, 2),
('ceo',               'CEO',                   1, 3),
('security_manager',  'Security Manager',       1, 4),
('financial_manager', 'Financial Manager',      1, 5),
('support',           'Support',               1, 6),
('moderator',         'Moderator / Team Staff', 1, 7);

CREATE TABLE IF NOT EXISTS `permissions` (
  `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`       VARCHAR(120) NOT NULL,
  `label`      VARCHAR(200) NOT NULL,
  `module`     VARCHAR(80)  NOT NULL DEFAULT 'general',
  `sort_order` INT          NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_perm_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `role_permissions` (
  `role_id`       INT UNSIGNED NOT NULL,
  `permission_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`role_id`, `permission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 20. News: ensure status and published_at columns (migration 004)
-- ============================================================
ALTER TABLE `news`
  ADD COLUMN IF NOT EXISTS `status`       ENUM('draft','published') NOT NULL DEFAULT 'draft' AFTER `content`,
  ADD COLUMN IF NOT EXISTS `published_at` DATETIME DEFAULT NULL AFTER `status`;

-- ============================================================
-- 21. Custom pages: ensure meta_description column (migration 004)
-- ============================================================
ALTER TABLE `custom_pages`
  ADD COLUMN IF NOT EXISTS `meta_description` VARCHAR(255) DEFAULT NULL AFTER `content`;

-- ============================================================
-- 22. Audit logs: ensure table uses correct schema
--     (migration 006 adds 'details' column; 001 uses 'description')
-- ============================================================
ALTER TABLE `audit_logs`
  ADD COLUMN IF NOT EXISTS `details` TEXT DEFAULT NULL AFTER `action`;

-- ============================================================
-- 23. Spin: ensure granted_by_admin column (migration 006)
-- ============================================================
ALTER TABLE `spin_history`
  ADD COLUMN IF NOT EXISTS `granted_by_admin` INT UNSIGNED DEFAULT NULL AFTER `reward_label`;

-- ============================================================
-- 24. Withdrawals: ensure memo column (migration 008)
-- ============================================================
ALTER TABLE `withdrawals`
  ADD COLUMN IF NOT EXISTS `memo` VARCHAR(100) DEFAULT NULL
    COMMENT 'Memo/tag if required by the network' AFTER `address`;

-- ============================================================
-- 25. Settings: insert any missing feature flag defaults
-- ============================================================
INSERT IGNORE INTO `settings` (`key`, `value`) VALUES
('kyc_enabled',               '0'),
('community_enabled',         '0'),
('rewards_hub_enabled',       '0'),
('dark_mode_default',         '1'),
('site_theme',                'dark'),
('deposit_qr_enabled',        '1'),
('auto_credit_enabled',       '1'),
('min_deposit_confirmations', '3'),
('referral_threshold_mode',   'flat'),
('referral_min_downlines',    '0'),
('referral_min_deposit',      '0');

-- ============================================================
-- 26. Currencies: ensure price history table exists
-- ============================================================
CREATE TABLE IF NOT EXISTS `currency_price_history` (
  `id`          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `currency_id` INT UNSIGNED  NOT NULL,
  `price_usd`   DECIMAL(20,8) NOT NULL,
  `recorded_at` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_cph_currency` (`currency_id`),
  KEY `idx_cph_recorded` (`recorded_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 27. IP checks table (if not already created)
-- ============================================================
CREATE TABLE IF NOT EXISTS `ip_checks` (
  `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `ip_address` VARCHAR(45)  NOT NULL,
  `action`     VARCHAR(50)  NOT NULL DEFAULT 'blocked',
  `reason`     VARCHAR(255) DEFAULT NULL,
  `expires_at` DATETIME     DEFAULT NULL,
  `created_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ic_ip` (`ip_address`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
