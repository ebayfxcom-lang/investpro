-- Migration 010: MySQL 8.0-compatible schema catch-up
--
-- Purpose
-- -------
-- Migrations 003-009 use ALTER TABLE … ADD COLUMN IF NOT EXISTS, which is a
-- MariaDB extension that does NOT exist in standard MySQL 8.0.  On a MySQL
-- 8.0.45 (InnoDB, utf8mb4, utf8mb4_unicode_ci) database every one of those
-- statements fails with ERROR 1064, so columns they were supposed to add are
-- absent.  This file is the MySQL-only replacement: it uses a temporary
-- stored procedure that checks information_schema before issuing each
-- ALTER TABLE, making every operation fully idempotent regardless of the
-- prior migration state (001-only through 009-complete).
--
-- Compatibility
-- -------------
-- • MySQL 8.0+ (no MariaDB-specific syntax; tested on MySQL 8.0.45)
-- • ENGINE=InnoDB, DEFAULT CHARSET=utf8mb4, COLLATE=utf8mb4_unicode_ci
-- • Safe to re-run: CREATE TABLE IF NOT EXISTS / INSERT IGNORE / _ip_add_col
--
-- Summary of changes
-- ------------------
-- A) Helper stored procedure _ip_add_col (dropped at the end)
-- B) New tables: currency_price_history (correct schema), exchange_rate_snapshots,
--    spin_settings, spin_rewards, user_spins, spin_history, newsletters,
--    scam_reports, faq_categories, deposit_wallets, withdrawal_methods,
--    kyc_submissions, community_posts, community_comments, community_likes,
--    bot_profiles, reward_offers, reward_claims, reward_progress,
--    newsletter_guests, user_notices, user_notice_reads, ticket_departments,
--    support_tickets, ticket_replies, seo_pages, team_roles, permissions,
--    role_permissions, ip_checks
-- C) Added columns to: users, deposits, withdrawals, plans, faq, news,
--    custom_pages, newsletters, spin_rewards, spin_history, currency_price_history
-- D) FK constraint: users.fk_users_team_role → team_roles.id
-- E) Seed data and data back-fills (all INSERT IGNORE / safe UPDATE)

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- A. Helper: _ip_add_col
--    Adds a column only when it does not already exist.
--    Usage: CALL _ip_add_col('table', 'column', 'SQL definition');
-- ============================================================

DROP PROCEDURE IF EXISTS `_ip_add_col`;

DELIMITER //
CREATE PROCEDURE `_ip_add_col`(
    IN p_tbl  VARCHAR(100),
    IN p_col  VARCHAR(100),
    IN p_def  TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM   information_schema.COLUMNS
        WHERE  TABLE_SCHEMA = DATABASE()
          AND  TABLE_NAME   = p_tbl
          AND  COLUMN_NAME  = p_col
    ) THEN
        SET @_sql = CONCAT('ALTER TABLE `', p_tbl, '` ADD COLUMN `', p_col, '` ', p_def);
        PREPARE _s FROM @_sql;
        EXECUTE _s;
        DEALLOCATE PREPARE _s;
    END IF;
END //
DELIMITER ;

-- ============================================================
-- B. New tables (CREATE TABLE IF NOT EXISTS is native MySQL)
-- ============================================================

-- currency_price_history: correct schema (migration 009 used wrong
-- `currency_id` column; the app uses `currency_code` everywhere)
CREATE TABLE IF NOT EXISTS `currency_price_history` (
  `id`            INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `currency_code` VARCHAR(10)   NOT NULL,
  `price_usd`     DECIMAL(20,8) NOT NULL,
  `price_eur`     DECIMAL(20,8) DEFAULT NULL,
  `source`        VARCHAR(50)   NOT NULL DEFAULT 'api',
  `recorded_at`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_cph_code`     (`currency_code`),
  KEY `idx_cph_recorded` (`recorded_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `exchange_rate_snapshots` (
  `id`               INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `ref_type`         VARCHAR(20)   NOT NULL,
  `ref_id`           INT UNSIGNED  NOT NULL,
  `from_currency`    VARCHAR(10)   NOT NULL,
  `to_currency`      VARCHAR(10)   NOT NULL,
  `rate`             DECIMAL(20,8) NOT NULL,
  `amount_original`  DECIMAL(20,8) NOT NULL,
  `amount_converted` DECIMAL(20,8) NOT NULL,
  `created_at`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ers_ref` (`ref_type`, `ref_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `spin_settings` (
  `id`               INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `enabled`          TINYINT(1)    NOT NULL DEFAULT 1,
  `spin_price`       DECIMAL(10,4) NOT NULL DEFAULT 1.0000,
  `daily_free_spins` INT           NOT NULL DEFAULT 1,
  `updated_at`       DATETIME      DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `spin_settings` (`id`, `enabled`, `spin_price`, `daily_free_spins`)
  VALUES (1, 1, 1.0000, 1);

CREATE TABLE IF NOT EXISTS `spin_rewards` (
  `id`           INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `slot`         TINYINT       NOT NULL,
  `spin_mode`    ENUM('free','paid','both') NOT NULL DEFAULT 'both',
  `label`        VARCHAR(100)  NOT NULL,
  `reward_type`  ENUM('points','usd','eur','bonus','spin_credits','percent_bonus','no_reward') NOT NULL DEFAULT 'no_reward',
  `reward_value` DECIMAL(20,8) NOT NULL DEFAULT 0.00000000,
  `probability`  DECIMAL(10,6) NOT NULL DEFAULT 8.333333,
  `color`        VARCHAR(20)   NOT NULL DEFAULT '#1e40af',
  `status`       ENUM('active','inactive') NOT NULL DEFAULT 'active',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_spin_slot_mode` (`slot`, `spin_mode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `spin_rewards` (`slot`, `spin_mode`, `label`, `reward_type`, `reward_value`, `probability`, `color`) VALUES
(1,  'both', 'Try Again',    'no_reward',     0.00,  20.000000, '#6b7280'),
(2,  'both', '$5 Bonus',     'usd',           5.00,   5.000000, '#059669'),
(3,  'both', '10 Points',    'points',       10.00,  15.000000, '#1e40af'),
(4,  'both', '$1 Credit',    'usd',           1.00,  15.000000, '#0891b2'),
(5,  'both', '1 Free Spin',  'spin_credits',  1.00,  10.000000, '#7c3aed'),
(6,  'both', 'Try Again',    'no_reward',     0.00,  10.000000, '#6b7280'),
(7,  'both', '$10 Bonus',    'usd',          10.00,   3.000000, '#dc2626'),
(8,  'both', '50 Points',    'points',       50.00,   5.000000, '#1e40af'),
(9,  'both', '5% Bonus',     'percent_bonus', 5.00,   4.000000, '#d97706'),
(10, 'both', '$2 Credit',    'usd',           2.00,  10.000000, '#0891b2'),
(11, 'both', '2 Free Spins', 'spin_credits',  2.00,   2.000000, '#7c3aed'),
(12, 'both', '$50 Jackpot',  'usd',          50.00,   1.000000, '#b91c1c');

CREATE TABLE IF NOT EXISTS `user_spins` (
  `id`                  INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`             INT UNSIGNED NOT NULL,
  `free_spins`          INT          NOT NULL DEFAULT 0,
  `paid_spins`          INT          NOT NULL DEFAULT 0,
  `last_free_spin_date` DATE         DEFAULT NULL,
  `updated_at`          DATETIME     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_user_spins_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `spin_history` (
  `id`               INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`          INT UNSIGNED  NOT NULL,
  `reward_id`        INT UNSIGNED  DEFAULT NULL,
  `spin_type`        ENUM('free','paid') NOT NULL DEFAULT 'free',
  `reward_type`      VARCHAR(30)   NOT NULL,
  `reward_value`     DECIMAL(20,8) NOT NULL DEFAULT 0.00000000,
  `reward_label`     VARCHAR(100)  NOT NULL,
  `granted_by_admin` INT UNSIGNED  DEFAULT NULL,
  `created_at`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_sh_user_id` (`user_id`),
  KEY `idx_sh_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `newsletters` (
  `id`           INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `subject`      VARCHAR(255)  NOT NULL,
  `content`      LONGTEXT      NOT NULL,
  `sender_name`  VARCHAR(100)  DEFAULT NULL,
  `sent_by`      INT UNSIGNED  DEFAULT NULL,
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
  KEY `idx_sr_status`  (`status`),
  KEY `idx_sr_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
('General',     'general',     'active', 1),
('Account',     'account',     'active', 2),
('Deposits',    'deposits',    'active', 3),
('Withdrawals', 'withdrawals', 'active', 4),
('Referral',    'referral',    'active', 5),
('Investments', 'investments', 'active', 6),
('Security',    'security',    'active', 7);

CREATE TABLE IF NOT EXISTS `deposit_wallets` (
  `id`             INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `currency_code`  VARCHAR(10)   NOT NULL,
  `network`        VARCHAR(50)   NOT NULL DEFAULT '',
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
  KEY `idx_dw_status`   (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
  KEY `idx_wm_status`   (`status`),
  KEY `idx_wm_currency` (`currency`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `withdrawal_methods`
  (`id`, `name`, `currency`, `network`, `min_amount`, `fee`, `fee_percent`, `status`, `sort_order`)
VALUES
  (1, 'Bitcoin (BTC)',    'BTC',  'BTC',   0.0001, 0.00002000, 0.00, 'inactive', 1),
  (2, 'Ethereum (ERC20)','ETH',  'ERC20', 0.01,   0.00050000, 0.00, 'inactive', 2),
  (3, 'USDT (TRC20)',    'USDT', 'TRC20', 10.00,  1.00000000, 0.00, 'inactive', 3),
  (4, 'USDT (ERC20)',    'USDT', 'ERC20', 20.00,  5.00000000, 0.00, 'inactive', 4),
  (5, 'BNB (BEP20)',     'BNB',  'BEP20', 0.1,    0.00050000, 0.00, 'inactive', 5);

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
  KEY `idx_kyc_status`   (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
  KEY `idx_cp_user`    (`user_id`),
  KEY `idx_cp_status`  (`status`),
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
  KEY `idx_ro_status`    (`status`),
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
  KEY `idx_rc_user`  (`user_id`),
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
  UNIQUE KEY `uq_ticket_ref`  (`reference`),
  KEY `idx_ticket_user`   (`user_id`),
  KEY `idx_ticket_status` (`status`),
  KEY `idx_ticket_dept`   (`department_id`)
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
('homepage',  'Homepage'),
('login',     'Login Page'),
('register',  'Register Page'),
('dashboard', 'User Dashboard'),
('news',      'News'),
('faq',       'FAQ'),
('plans',     'Investment Plans'),
('support',   'Support / Contact'),
('community', 'Community'),
('about',     'About Us');

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
('ceo',               'CEO',                    1, 3),
('security_manager',  'Security Manager',       1, 4),
('financial_manager', 'Financial Manager',      1, 5),
('support',           'Support',                1, 6),
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

INSERT IGNORE INTO `permissions` (`name`, `label`, `module`, `sort_order`) VALUES
('dashboard.view',              'View Dashboard',               'dashboard',  1),
('dashboard.analytics',         'View Analytics',               'dashboard',  2),
('users.view',                  'View Users',                   'users',     10),
('users.edit',                  'Edit Users',                   'users',     11),
('users.suspend',               'Suspend/Ban Users',            'users',     12),
('users.delete',                'Delete Users',                 'users',     13),
('users.add_funds',             'Add Funds to Users',           'users',     14),
('finance.deposits.view',       'View Deposits',                'finance',   20),
('finance.deposits.approve',    'Approve/Reject Deposits',      'finance',   21),
('finance.withdrawals.view',    'View Withdrawals',             'finance',   22),
('finance.withdrawals.approve', 'Approve/Reject Withdrawals',   'finance',   23),
('finance.transactions.view',   'View Transactions',            'finance',   24),
('finance.earnings.view',       'View Earnings',                'finance',   25),
('finance.plans.manage',        'Manage Investment Plans',      'finance',   26),
('finance.exchange.manage',     'Manage Exchange Rates',        'finance',   27),
('security.audit.view',         'View Audit Logs',              'security',  30),
('security.ip.manage',          'Manage IP Checks/Blacklist',   'security',  31),
('security.kyc.manage',         'Manage KYC',                   'security',  32),
('security.settings',           'Manage Security Settings',     'security',  33),
('content.news.manage',         'Manage News',                  'content',   40),
('content.faq.manage',          'Manage FAQ',                   'content',   41),
('content.pages.manage',        'Manage Custom Pages',          'content',   42),
('content.newsletter.send',     'Send Newsletter',              'content',   43),
('content.seo.manage',          'Manage SEO/Meta',              'content',   44),
('support.tickets.view',        'View Support Tickets',         'support',   50),
('support.tickets.reply',       'Reply to Tickets',             'support',   51),
('support.notices.manage',      'Manage User Notices',          'support',   52),
('community.posts.view',        'View Community Posts',         'community', 60),
('community.posts.delete',      'Delete Community Posts',       'community', 61),
('community.bots.manage',       'Manage Community Bots',        'community', 62),
('team.roles.manage',           'Manage Team Roles',            'team',      70),
('team.members.manage',         'Manage Team Members',          'team',      71),
('settings.general',            'General Settings',             'settings',  80),
('settings.referral',           'Referral Settings',            'settings',  81),
('settings.currencies',         'Currency Settings',            'settings',  82);

CREATE TABLE IF NOT EXISTS `role_permissions` (
  `role_id`       INT UNSIGNED NOT NULL,
  `permission_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`role_id`, `permission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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

-- ============================================================
-- C. Add columns to existing tables (via helper procedure)
-- ============================================================

-- users (migrations 003, 006, 007)
CALL _ip_add_col('users', 'whatsapp_number',          'VARCHAR(30) DEFAULT NULL');
CALL _ip_add_col('users', 'facebook_url',              'VARCHAR(255) DEFAULT NULL');
CALL _ip_add_col('users', 'preferred_currency',        'VARCHAR(10) NOT NULL DEFAULT ''USD''');
CALL _ip_add_col('users', 'payout_details',            'TEXT DEFAULT NULL');
CALL _ip_add_col('users', 'communication_prefs',       'VARCHAR(100) DEFAULT ''email''');
CALL _ip_add_col('users', 'two_factor_backup_codes',   'TEXT DEFAULT NULL');
CALL _ip_add_col('users', 'two_factor_confirmed_at',   'DATETIME DEFAULT NULL');
CALL _ip_add_col('users', 'theme_preference',          'VARCHAR(10) NOT NULL DEFAULT ''dark''');
CALL _ip_add_col('users', 'team_role_id',              'INT UNSIGNED DEFAULT NULL');
CALL _ip_add_col('users', 'account_type',              'ENUM(''normal'',''representative'',''team_leader'') NOT NULL DEFAULT ''normal''');

-- deposits (migrations 003, 006)
CALL _ip_add_col('deposits', 'usd_amount',            'DECIMAL(20,8) DEFAULT NULL');
CALL _ip_add_col('deposits', 'eur_amount',            'DECIMAL(20,8) DEFAULT NULL');
CALL _ip_add_col('deposits', 'rate_snapshot',         'TEXT DEFAULT NULL');
CALL _ip_add_col('deposits', 'network',               'VARCHAR(50) DEFAULT NULL');
CALL _ip_add_col('deposits', 'deposit_address',       'VARCHAR(255) DEFAULT NULL');
CALL _ip_add_col('deposits', 'actual_crypto_amount',  'DECIMAL(20,8) DEFAULT NULL');
CALL _ip_add_col('deposits', 'fiat_amount',           'DECIMAL(20,8) DEFAULT NULL');
CALL _ip_add_col('deposits', 'detected_amount',       'DECIMAL(20,8) DEFAULT NULL');
CALL _ip_add_col('deposits', 'detected_tx_hash',      'VARCHAR(255) DEFAULT NULL');
CALL _ip_add_col('deposits', 'confirmations_count',   'TINYINT NOT NULL DEFAULT 0');
CALL _ip_add_col('deposits', 'confirmed_at',          'DATETIME DEFAULT NULL');
CALL _ip_add_col('deposits', 'memo',                  'VARCHAR(100) DEFAULT NULL');
CALL _ip_add_col('deposits', 'expiry_at',             'DATETIME DEFAULT NULL');

-- withdrawals (migrations 003, 006, 008)
CALL _ip_add_col('withdrawals', 'usd_amount',           'DECIMAL(20,8) DEFAULT NULL');
CALL _ip_add_col('withdrawals', 'eur_amount',           'DECIMAL(20,8) DEFAULT NULL');
CALL _ip_add_col('withdrawals', 'rate_snapshot',        'TEXT DEFAULT NULL');
CALL _ip_add_col('withdrawals', 'network',              'VARCHAR(50) DEFAULT NULL');
CALL _ip_add_col('withdrawals', 'actual_crypto_amount', 'DECIMAL(20,8) DEFAULT NULL');
CALL _ip_add_col('withdrawals', 'fiat_amount',          'DECIMAL(20,8) DEFAULT NULL');
CALL _ip_add_col('withdrawals', 'sent_tx_hash',         'VARCHAR(255) DEFAULT NULL');
CALL _ip_add_col('withdrawals', 'admin_note',           'TEXT DEFAULT NULL');
CALL _ip_add_col('withdrawals', 'processed_at',         'DATETIME DEFAULT NULL');
CALL _ip_add_col('withdrawals', 'processed_by',         'INT UNSIGNED DEFAULT NULL');
CALL _ip_add_col('withdrawals', 'memo',                 'VARCHAR(100) DEFAULT NULL');

-- plans (migrations 004, 007)
CALL _ip_add_col('plans', 'duration_value',       'INT UNSIGNED NOT NULL DEFAULT 30');
CALL _ip_add_col('plans', 'duration_unit',        'ENUM(''hour'',''day'',''week'',''month'',''year'') NOT NULL DEFAULT ''day''');
CALL _ip_add_col('plans', 'requires_plan_ids',    'TEXT DEFAULT NULL');
CALL _ip_add_col('plans', 'prereq_min_deposits',  'INT NOT NULL DEFAULT 0');
CALL _ip_add_col('plans', 'prereq_min_amount',    'DECIMAL(20,8) NOT NULL DEFAULT 0');
CALL _ip_add_col('plans', 'prereq_deposit_status','ENUM(''any'',''active'',''completed'') NOT NULL DEFAULT ''any''');

-- Back-fill duration_value from duration_days for newly added column
UPDATE `plans`
   SET `duration_value` = `duration_days`,
       `duration_unit`  = 'day'
 WHERE `duration_value` = 30
   AND `duration_unit`  = 'day'
   AND `duration_days` != 30;

-- faq (migrations 004, 005, 009)
-- Note: `status` already exists in faq from migration 001
CALL _ip_add_col('faq', 'category',    'ENUM(''general'',''account'',''deposits'',''withdrawals'',''referral'',''investments'',''security'') NOT NULL DEFAULT ''general''');
CALL _ip_add_col('faq', 'category_id', 'INT UNSIGNED DEFAULT NULL');
CALL _ip_add_col('faq', 'updated_at',  'DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP');

-- news (migrations 004, 005)
-- Note: `status` already exists in news from migration 001
CALL _ip_add_col('news', 'published_at',    'DATETIME DEFAULT NULL');
CALL _ip_add_col('news', 'publisher_name',  'VARCHAR(100) DEFAULT NULL');
CALL _ip_add_col('news', 'hashtags',        'VARCHAR(500) DEFAULT NULL');

-- custom_pages (migration 004)
CALL _ip_add_col('custom_pages', 'meta_description', 'VARCHAR(255) DEFAULT NULL');

-- newsletters (migration 005)
-- Only needed when the table was created by migration 004 (without sender_name/sent_by)
CALL _ip_add_col('newsletters', 'sender_name', 'VARCHAR(100) DEFAULT NULL');
CALL _ip_add_col('newsletters', 'sent_by',     'INT UNSIGNED DEFAULT NULL');

-- spin_rewards (migration 005)
-- Only needed when created by migration 003 (without spin_mode column)
CALL _ip_add_col('spin_rewards', 'spin_mode', 'ENUM(''free'',''paid'',''both'') NOT NULL DEFAULT ''both''');

-- spin_history (migration 006)
CALL _ip_add_col('spin_history', 'granted_by_admin', 'INT UNSIGNED DEFAULT NULL');

-- currency_price_history: fix schema gap from migration 009.
-- Migration 009 created this table with `currency_id` (INT UNSIGNED) instead
-- of `currency_code` (VARCHAR(10)).  On a MySQL 8.0 database where only
-- migration 009 ran, the table is empty (all INSERTs via CurrencyPriceHistoryModel
-- would have failed against the `currency_id NOT NULL` constraint), so adding
-- `currency_code` with NOT NULL DEFAULT '' is safe.  On databases where
-- migration 003 or 005 ran first (correct schema), this call is a no-op.
CALL _ip_add_col('currency_price_history', 'currency_code', 'VARCHAR(10) NOT NULL DEFAULT ''''');
CALL _ip_add_col('currency_price_history', 'price_eur',     'DECIMAL(20,8) DEFAULT NULL');
CALL _ip_add_col('currency_price_history', 'source',        'VARCHAR(50) NOT NULL DEFAULT ''api''');

-- Add idx_cph_code on currency_code only when it does not already exist
SET @_cph_idx = (
  SELECT COUNT(*)
  FROM   information_schema.STATISTICS
  WHERE  TABLE_SCHEMA = DATABASE()
    AND  TABLE_NAME   = 'currency_price_history'
    AND  INDEX_NAME   = 'idx_cph_code'
);
SET @_cph_ddl = IF(
  @_cph_idx = 0,
  'ALTER TABLE `currency_price_history` ADD KEY `idx_cph_code` (`currency_code`)',
  'DO 1'
);
PREPARE _cph_stmt FROM @_cph_ddl;
EXECUTE _cph_stmt;
DEALLOCATE PREPARE _cph_stmt;

-- ============================================================
-- D. FK constraint: users.team_role_id → team_roles.id
--    Standard MySQL 8.0 does not support ADD CONSTRAINT IF NOT EXISTS
--    for foreign keys; use information_schema check instead.
-- ============================================================

SET @_fk_exists = (
  SELECT COUNT(*)
  FROM   information_schema.TABLE_CONSTRAINTS
  WHERE  CONSTRAINT_SCHEMA = DATABASE()
    AND  TABLE_NAME         = 'users'
    AND  CONSTRAINT_NAME    = 'fk_users_team_role'
    AND  CONSTRAINT_TYPE    = 'FOREIGN KEY'
);
SET @_fk_ddl = IF(
  @_fk_exists = 0,
  'ALTER TABLE `users` ADD CONSTRAINT `fk_users_team_role` FOREIGN KEY (`team_role_id`) REFERENCES `team_roles` (`id`) ON DELETE SET NULL ON UPDATE CASCADE',
  'DO 1'
);
PREPARE _fk_stmt FROM @_fk_ddl;
EXECUTE _fk_stmt;
DEALLOCATE PREPARE _fk_stmt;

-- ============================================================
-- E. Settings defaults and seed data
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
('referral_min_deposit',      '0'),
('referral_l1_threshold1_count', '0'),
('referral_l1_threshold1_rate',  '5'),
('referral_l1_threshold2_count', '10'),
('referral_l1_threshold2_rate',  '7'),
('referral_l1_threshold3_count', '25'),
('referral_l1_threshold3_rate',  '10'),
('referral_l2_threshold1_rate',  '2'),
('referral_l2_threshold2_rate',  '3'),
('referral_l2_threshold3_rate',  '5'),
('referral_l3_threshold1_rate',  '1'),
('referral_l3_threshold2_rate',  '1.5'),
('referral_l3_threshold3_rate',  '2');

-- Ensure withdrawal methods seeded as inactive by default
UPDATE `withdrawal_methods`
   SET `status` = 'inactive'
 WHERE `id` IN (1, 2, 3, 4, 5)
   AND `status` = 'active';

-- ============================================================
-- Cleanup: remove the temporary helper procedure
-- ============================================================

DROP PROCEDURE IF EXISTS `_ip_add_col`;

SET FOREIGN_KEY_CHECKS = 1;
