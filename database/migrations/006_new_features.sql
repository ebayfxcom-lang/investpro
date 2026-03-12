-- Migration 006: New features – deposits network/crypto, withdrawals tx hash,
--                 2FA backup codes, KYC, community feed, rewards hub,
--                 withdrawal_methods, deposit improvements

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 1. DEPOSITS: add network, deposit address, crypto amount fields
-- ============================================================
ALTER TABLE `deposits`
  ADD COLUMN IF NOT EXISTS `network`               VARCHAR(50)    DEFAULT NULL    COMMENT 'Blockchain network e.g. TRC20, ERC20'  AFTER `currency`,
  ADD COLUMN IF NOT EXISTS `deposit_address`       VARCHAR(255)   DEFAULT NULL    COMMENT 'Assigned deposit wallet address'       AFTER `network`,
  ADD COLUMN IF NOT EXISTS `actual_crypto_amount`  DECIMAL(20,8)  DEFAULT NULL    COMMENT 'Exact crypto amount user must send'    AFTER `deposit_address`,
  ADD COLUMN IF NOT EXISTS `fiat_amount`           DECIMAL(20,8)  DEFAULT NULL    COMMENT 'Requested amount in base fiat'         AFTER `actual_crypto_amount`,
  ADD COLUMN IF NOT EXISTS `rate_snapshot`         TEXT           DEFAULT NULL    COMMENT 'JSON rate snapshot at deposit time'    AFTER `fiat_amount`,
  ADD COLUMN IF NOT EXISTS `usd_amount`            DECIMAL(20,8)  DEFAULT NULL    COMMENT 'USD equivalent at deposit time'        AFTER `rate_snapshot`,
  ADD COLUMN IF NOT EXISTS `eur_amount`            DECIMAL(20,8)  DEFAULT NULL    COMMENT 'EUR equivalent at deposit time'        AFTER `usd_amount`,
  ADD COLUMN IF NOT EXISTS `detected_amount`       DECIMAL(20,8)  DEFAULT NULL    COMMENT 'Amount detected by blockchain watcher' AFTER `eur_amount`,
  ADD COLUMN IF NOT EXISTS `detected_tx_hash`      VARCHAR(255)   DEFAULT NULL    COMMENT 'Transaction hash detected by watcher'  AFTER `detected_amount`,
  ADD COLUMN IF NOT EXISTS `confirmations_count`   TINYINT        NOT NULL DEFAULT 0 COMMENT 'Number of confirmations detected' AFTER `detected_tx_hash`,
  ADD COLUMN IF NOT EXISTS `confirmed_at`          DATETIME       DEFAULT NULL    COMMENT 'When deposit was confirmed'            AFTER `confirmations_count`,
  ADD COLUMN IF NOT EXISTS `memo`                  VARCHAR(100)   DEFAULT NULL    COMMENT 'Memo/tag if required by network'       AFTER `confirmed_at`,
  ADD COLUMN IF NOT EXISTS `expiry_at`             DATETIME       DEFAULT NULL    COMMENT 'Deposit address reservation expiry'    AFTER `memo`;

-- ============================================================
-- 2. WITHDRAWALS: add network, tx hash, crypto amounts
-- ============================================================
ALTER TABLE `withdrawals`
  ADD COLUMN IF NOT EXISTS `network`               VARCHAR(50)    DEFAULT NULL    COMMENT 'Blockchain network'                   AFTER `currency`,
  ADD COLUMN IF NOT EXISTS `actual_crypto_amount`  DECIMAL(20,8)  DEFAULT NULL    COMMENT 'Exact crypto amount to send'          AFTER `network`,
  ADD COLUMN IF NOT EXISTS `fiat_amount`           DECIMAL(20,8)  DEFAULT NULL    COMMENT 'Fiat equivalent'                      AFTER `actual_crypto_amount`,
  ADD COLUMN IF NOT EXISTS `rate_snapshot`         TEXT           DEFAULT NULL    COMMENT 'JSON rate snapshot'                   AFTER `fiat_amount`,
  ADD COLUMN IF NOT EXISTS `usd_amount`            DECIMAL(20,8)  DEFAULT NULL    COMMENT 'USD equivalent'                       AFTER `rate_snapshot`,
  ADD COLUMN IF NOT EXISTS `eur_amount`            DECIMAL(20,8)  DEFAULT NULL    COMMENT 'EUR equivalent'                       AFTER `usd_amount`,
  ADD COLUMN IF NOT EXISTS `sent_tx_hash`          VARCHAR(255)   DEFAULT NULL    COMMENT 'TX hash after admin sends crypto'     AFTER `eur_amount`,
  ADD COLUMN IF NOT EXISTS `admin_note`            TEXT           DEFAULT NULL    COMMENT 'Admin note on withdrawal'             AFTER `sent_tx_hash`,
  ADD COLUMN IF NOT EXISTS `processed_at`          DATETIME       DEFAULT NULL    COMMENT 'When admin processed the withdrawal'  AFTER `admin_note`,
  ADD COLUMN IF NOT EXISTS `processed_by`          INT UNSIGNED   DEFAULT NULL    COMMENT 'Admin user ID who processed it'       AFTER `processed_at`;

-- ============================================================
-- 3. WITHDRAWAL METHODS (enabled/disabled by admin)
-- ============================================================
CREATE TABLE IF NOT EXISTS `withdrawal_methods` (
  `id`           INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `name`         VARCHAR(100)  NOT NULL             COMMENT 'Display name e.g. Bitcoin BTC',
  `currency`     VARCHAR(10)   NOT NULL             COMMENT 'Currency code',
  `network`      VARCHAR(50)   NOT NULL DEFAULT ''  COMMENT 'Network e.g. BTC, ERC20, TRC20',
  `min_amount`   DECIMAL(20,8) NOT NULL DEFAULT 10  COMMENT 'Minimum withdrawal amount',
  `fee`          DECIMAL(20,8) NOT NULL DEFAULT 0   COMMENT 'Fixed fee in USD',
  `fee_percent`  DECIMAL(5,2)  NOT NULL DEFAULT 0   COMMENT 'Percentage fee',
  `address_regex` VARCHAR(500) DEFAULT NULL         COMMENT 'Regex for address validation',
  `requires_memo` TINYINT(1)   NOT NULL DEFAULT 0   COMMENT 'Whether memo/tag is required',
  `instructions` TEXT          DEFAULT NULL         COMMENT 'User-facing instructions',
  `status`       ENUM('active','inactive') NOT NULL DEFAULT 'active',
  `sort_order`   INT           NOT NULL DEFAULT 0,
  `created_at`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`   DATETIME      DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_wm_status` (`status`),
  KEY `idx_wm_currency` (`currency`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Seed default withdrawal methods (status = 'inactive' so admins must explicitly enable each one)
INSERT IGNORE INTO `withdrawal_methods` (`id`, `name`, `currency`, `network`, `min_amount`, `fee`, `fee_percent`, `status`, `sort_order`) VALUES
(1, 'Bitcoin (BTC)',         'BTC',  'BTC',   0.0001,  0.00002000, 0.00, 'inactive', 1),
(2, 'Ethereum (ERC20)',      'ETH',  'ERC20', 0.01,    0.00050000, 0.00, 'inactive', 2),
(3, 'USDT (TRC20)',          'USDT', 'TRC20', 10.00,   1.00000000, 0.00, 'inactive', 3),
(4, 'USDT (ERC20)',          'USDT', 'ERC20', 20.00,   5.00000000, 0.00, 'inactive', 4),
(5, 'BNB (BEP20)',           'BNB',  'BEP20', 0.1,     0.00050000, 0.00, 'inactive', 5);

-- ============================================================
-- 4. USERS: 2FA backup codes column
-- ============================================================
ALTER TABLE `users`
  ADD COLUMN IF NOT EXISTS `two_factor_backup_codes` TEXT DEFAULT NULL
    COMMENT 'JSON array of hashed backup codes' AFTER `two_factor_secret`,
  ADD COLUMN IF NOT EXISTS `two_factor_confirmed_at`  DATETIME DEFAULT NULL
    COMMENT 'When 2FA was confirmed/enabled' AFTER `two_factor_backup_codes`,
  ADD COLUMN IF NOT EXISTS `theme_preference`          VARCHAR(10) NOT NULL DEFAULT 'dark'
    COMMENT 'User preferred theme: light or dark' AFTER `two_factor_confirmed_at`;

-- ============================================================
-- 5. KYC (Know Your Customer) submissions
-- ============================================================
CREATE TABLE IF NOT EXISTS `kyc_submissions` (
  `id`              INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`         INT UNSIGNED  NOT NULL,
  `document_type`   ENUM('passport','national_id','drivers_license','residence_permit') NOT NULL DEFAULT 'national_id',
  `document_number` VARCHAR(100)  NOT NULL,
  `front_image`     VARCHAR(500)  DEFAULT NULL  COMMENT 'File path or storage URL',
  `back_image`      VARCHAR(500)  DEFAULT NULL  COMMENT 'File path or storage URL',
  `selfie_image`    VARCHAR(500)  DEFAULT NULL  COMMENT 'Selfie or live selfie image',
  `status`          ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `review_note`     TEXT          DEFAULT NULL,
  `reviewed_by`     INT UNSIGNED  DEFAULT NULL  COMMENT 'Admin user ID',
  `reviewed_at`     DATETIME      DEFAULT NULL,
  `created_at`      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      DATETIME      DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_kyc_user` (`user_id`),
  KEY `idx_kyc_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 6. COMMUNITY FEED: posts, comments, likes, bot profiles
-- ============================================================
CREATE TABLE IF NOT EXISTS `community_posts` (
  `id`          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`     INT UNSIGNED  NOT NULL,
  `content`     TEXT          NOT NULL,
  `is_bot`      TINYINT(1)    NOT NULL DEFAULT 0  COMMENT '1 if posted by a bot profile',
  `bot_profile_id` INT UNSIGNED DEFAULT NULL,
  `likes_count` INT UNSIGNED  NOT NULL DEFAULT 0,
  `status`      ENUM('active','hidden','deleted') NOT NULL DEFAULT 'active',
  `created_at`  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  DATETIME      DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
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
  `id`               INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `display_name`     VARCHAR(80)   NOT NULL,
  `avatar_url`       VARCHAR(500)  DEFAULT NULL,
  `bio`              TEXT          DEFAULT NULL,
  `tone_category`    ENUM('paying_status','platform_performance','investment_excitement','support_praise','withdrawal_received','general') NOT NULL DEFAULT 'general',
  `keywords`         TEXT          DEFAULT NULL  COMMENT 'JSON array of keywords/topics',
  `post_frequency`   INT           NOT NULL DEFAULT 60  COMMENT 'Minutes between posts',
  `status`           ENUM('active','inactive') NOT NULL DEFAULT 'active',
  `last_posted_at`   DATETIME      DEFAULT NULL,
  `created_at`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`       DATETIME      DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 7. REWARDS HUB (Season offers)
-- ============================================================
CREATE TABLE IF NOT EXISTS `reward_offers` (
  `id`               INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `title`            VARCHAR(200)  NOT NULL,
  `description`      TEXT          DEFAULT NULL,
  `banner_url`       VARCHAR(500)  DEFAULT NULL,
  `reward_type`      ENUM('balance_credit','spin_credits','bonus_percent','custom') NOT NULL DEFAULT 'balance_credit',
  `reward_value`     DECIMAL(20,8) NOT NULL DEFAULT 0,
  `eligibility_rule` ENUM('first_deposit','invest_plan','complete_deposits','refer_users','buy_spins','daily_login','earn_spin_rewards','custom') NOT NULL DEFAULT 'first_deposit',
  `rule_value`       DECIMAL(20,8) NOT NULL DEFAULT 1  COMMENT 'e.g. deposit 3 times = 3',
  `start_at`         DATETIME      DEFAULT NULL,
  `end_at`           DATETIME      DEFAULT NULL,
  `max_claims`       INT           NOT NULL DEFAULT 0  COMMENT '0 = unlimited',
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
  `id`          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `offer_id`    INT UNSIGNED  NOT NULL,
  `user_id`     INT UNSIGNED  NOT NULL,
  `progress`    DECIMAL(20,8) NOT NULL DEFAULT 0,
  `updated_at`  DATETIME      DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_rp_offer_user` (`offer_id`, `user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 8. SETTINGS: new feature toggles
-- ============================================================
INSERT IGNORE INTO `settings` (`key`, `value`) VALUES
('kyc_enabled',           '0'),
('community_enabled',     '0'),
('rewards_hub_enabled',   '0'),
('dark_mode_default',     '1'),
('site_theme',            'dark'),
('deposit_qr_enabled',    '1'),
('auto_credit_enabled',   '1'),
('min_deposit_confirmations', '3');

-- ============================================================
-- 9. SPIN: add admin grant log (for audit)
-- ============================================================
ALTER TABLE `spin_history`
  ADD COLUMN IF NOT EXISTS `granted_by_admin` INT UNSIGNED DEFAULT NULL
    COMMENT 'Admin user ID if manually granted' AFTER `reward_label`;

-- ============================================================
-- 10. AUDIT LOGS: ensure table exists
-- ============================================================
CREATE TABLE IF NOT EXISTS `audit_logs` (
  `id`         INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `action`     VARCHAR(100)  NOT NULL,
  `details`    TEXT          DEFAULT NULL,
  `user_id`    INT UNSIGNED  DEFAULT NULL,
  `ip_address` VARCHAR(45)   DEFAULT NULL,
  `created_at` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_al_action` (`action`),
  KEY `idx_al_user` (`user_id`),
  KEY `idx_al_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
