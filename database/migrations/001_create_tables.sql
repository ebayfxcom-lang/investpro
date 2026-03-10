-- InvestPro Database Schema
-- Migration 001: Create all tables

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- USERS
-- ============================================================
CREATE TABLE IF NOT EXISTS `users` (
  `id`             INT UNSIGNED     NOT NULL AUTO_INCREMENT,
  `username`       VARCHAR(50)      NOT NULL,
  `email`          VARCHAR(150)     NOT NULL,
  `password`       VARCHAR(255)     NOT NULL,
  `first_name`     VARCHAR(80)      DEFAULT NULL,
  `last_name`      VARCHAR(80)      DEFAULT NULL,
  `phone`          VARCHAR(30)      DEFAULT NULL,
  `country`        VARCHAR(80)      DEFAULT NULL,
  `role`           ENUM('user','admin','superadmin') NOT NULL DEFAULT 'user',
  `status`         ENUM('active','banned','pending') NOT NULL DEFAULT 'active',
  `referral_code`  VARCHAR(20)      DEFAULT NULL,
  `referred_by`    INT UNSIGNED     DEFAULT NULL,
  `email_verified` TINYINT(1)       NOT NULL DEFAULT 0,
  `two_factor`     TINYINT(1)       NOT NULL DEFAULT 0,
  `two_factor_secret` VARCHAR(100)  DEFAULT NULL,
  `last_login_at`  DATETIME         DEFAULT NULL,
  `last_login_ip`  VARCHAR(45)      DEFAULT NULL,
  `created_at`     DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`     DATETIME         DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_users_email` (`email`),
  UNIQUE KEY `uq_users_username` (`username`),
  UNIQUE KEY `uq_users_referral_code` (`referral_code`),
  KEY `idx_users_referred_by` (`referred_by`),
  KEY `idx_users_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- CURRENCIES
-- ============================================================
CREATE TABLE IF NOT EXISTS `currencies` (
  `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `code`        VARCHAR(10)  NOT NULL,
  `name`        VARCHAR(100) NOT NULL,
  `symbol`      VARCHAR(10)  NOT NULL DEFAULT '$',
  `type`        ENUM('fiat','crypto') NOT NULL DEFAULT 'fiat',
  `rate_to_usd` DECIMAL(20,8) NOT NULL DEFAULT 1.00000000,
  `status`      ENUM('active','inactive') NOT NULL DEFAULT 'active',
  `sort_order`  INT          NOT NULL DEFAULT 0,
  `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  DATETIME     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_currencies_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- WALLETS
-- ============================================================
CREATE TABLE IF NOT EXISTS `wallets` (
  `id`         INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`    INT UNSIGNED  NOT NULL,
  `currency`   VARCHAR(10)   NOT NULL,
  `balance`    DECIMAL(20,8) NOT NULL DEFAULT 0.00000000,
  `locked`     DECIMAL(20,8) NOT NULL DEFAULT 0.00000000,
  `created_at` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME      DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_wallets_user_currency` (`user_id`, `currency`),
  KEY `idx_wallets_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- PLANS
-- ============================================================
CREATE TABLE IF NOT EXISTS `plans` (
  `id`               INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  `name`             VARCHAR(100)   NOT NULL,
  `description`      TEXT           DEFAULT NULL,
  `min_amount`       DECIMAL(20,8)  NOT NULL DEFAULT 10.00000000,
  `max_amount`       DECIMAL(20,8)  NOT NULL DEFAULT 0.00000000 COMMENT '0 = no limit',
  `roi_percent`      DECIMAL(10,4)  NOT NULL DEFAULT 1.0000,
  `roi_period`       ENUM('hourly','daily','weekly','monthly') NOT NULL DEFAULT 'daily',
  `duration_days`    INT UNSIGNED   NOT NULL DEFAULT 30,
  `principal_return` TINYINT(1)     NOT NULL DEFAULT 1 COMMENT 'Return principal at end',
  `currency`         VARCHAR(10)    NOT NULL DEFAULT 'USD',
  `status`           ENUM('active','inactive') NOT NULL DEFAULT 'active',
  `sort_order`       INT            NOT NULL DEFAULT 0,
  `created_at`       DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`       DATETIME       DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_plans_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- DEPOSITS
-- ============================================================
CREATE TABLE IF NOT EXISTS `deposits` (
  `id`          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`     INT UNSIGNED  NOT NULL,
  `plan_id`     INT UNSIGNED  NOT NULL,
  `amount`      DECIMAL(20,8) NOT NULL,
  `currency`    VARCHAR(10)   NOT NULL DEFAULT 'USD',
  `status`      ENUM('pending','active','completed','expired','rejected','cancelled') NOT NULL DEFAULT 'pending',
  `tx_hash`     VARCHAR(255)  DEFAULT NULL,
  `expires_at`  DATETIME      DEFAULT NULL,
  `created_at`  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  DATETIME      DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_deposits_user_id` (`user_id`),
  KEY `idx_deposits_status` (`status`),
  KEY `idx_deposits_expires_at` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- WITHDRAWALS
-- ============================================================
CREATE TABLE IF NOT EXISTS `withdrawals` (
  `id`          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`     INT UNSIGNED  NOT NULL,
  `amount`      DECIMAL(20,8) NOT NULL,
  `fee`         DECIMAL(20,8) NOT NULL DEFAULT 0.00000000,
  `currency`    VARCHAR(10)   NOT NULL DEFAULT 'USD',
  `method`      VARCHAR(50)   NOT NULL DEFAULT 'bank',
  `address`     VARCHAR(500)  NOT NULL,
  `status`      ENUM('pending','approved','rejected','cancelled') NOT NULL DEFAULT 'pending',
  `note`        TEXT          DEFAULT NULL,
  `created_at`  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  DATETIME      DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_withdrawals_user_id` (`user_id`),
  KEY `idx_withdrawals_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TRANSACTIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS `transactions` (
  `id`          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`     INT UNSIGNED  NOT NULL,
  `type`        VARCHAR(50)   NOT NULL COMMENT 'deposit,withdrawal,earning,referral,admin_credit,bonus',
  `amount`      DECIMAL(20,8) NOT NULL,
  `currency`    VARCHAR(10)   NOT NULL DEFAULT 'USD',
  `description` VARCHAR(500)  DEFAULT NULL,
  `status`      ENUM('pending','completed','failed','cancelled') NOT NULL DEFAULT 'completed',
  `ref_id`      INT UNSIGNED  DEFAULT NULL COMMENT 'Reference to deposits.id or withdrawals.id',
  `created_at`  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_transactions_user_id` (`user_id`),
  KEY `idx_transactions_type` (`type`),
  KEY `idx_transactions_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- EARNINGS
-- ============================================================
CREATE TABLE IF NOT EXISTS `earnings` (
  `id`          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`     INT UNSIGNED  NOT NULL,
  `deposit_id`  INT UNSIGNED  NOT NULL,
  `amount`      DECIMAL(20,8) NOT NULL,
  `currency`    VARCHAR(10)   NOT NULL DEFAULT 'USD',
  `type`        ENUM('roi','bonus','referral') NOT NULL DEFAULT 'roi',
  `status`      ENUM('pending','paid','cancelled') NOT NULL DEFAULT 'paid',
  `created_at`  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_earnings_user_id` (`user_id`),
  KEY `idx_earnings_deposit_id` (`deposit_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- REFERRAL EARNINGS
-- ============================================================
CREATE TABLE IF NOT EXISTS `referral_earnings` (
  `id`          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `referrer_id` INT UNSIGNED  NOT NULL,
  `referee_id`  INT UNSIGNED  NOT NULL,
  `deposit_id`  INT UNSIGNED  DEFAULT NULL,
  `amount`      DECIMAL(20,8) NOT NULL,
  `currency`    VARCHAR(10)   NOT NULL DEFAULT 'USD',
  `level`       TINYINT(1)    NOT NULL DEFAULT 1,
  `status`      ENUM('pending','paid','cancelled') NOT NULL DEFAULT 'paid',
  `created_at`  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ref_earnings_referrer` (`referrer_id`),
  KEY `idx_ref_earnings_referee` (`referee_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- SETTINGS
-- ============================================================
CREATE TABLE IF NOT EXISTS `settings` (
  `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `key`        VARCHAR(100) NOT NULL,
  `value`      TEXT         DEFAULT NULL,
  `updated_at` DATETIME     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_settings_key` (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- BLACKLIST
-- ============================================================
CREATE TABLE IF NOT EXISTS `blacklist` (
  `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `type`       ENUM('ip','email','username','country') NOT NULL DEFAULT 'ip',
  `value`      VARCHAR(255) NOT NULL,
  `reason`     VARCHAR(500) DEFAULT NULL,
  `expires_at` DATETIME     DEFAULT NULL,
  `created_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_blacklist_type_value` (`type`, `value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- EMAIL TEMPLATES
-- ============================================================
CREATE TABLE IF NOT EXISTS `email_templates` (
  `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `slug`       VARCHAR(100) NOT NULL,
  `name`       VARCHAR(200) NOT NULL,
  `subject`    VARCHAR(500) NOT NULL,
  `body`       LONGTEXT     NOT NULL,
  `variables`  TEXT         DEFAULT NULL COMMENT 'Comma-separated available vars',
  `status`     ENUM('active','inactive') NOT NULL DEFAULT 'active',
  `created_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_email_templates_slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- AUDIT LOGS
-- ============================================================
CREATE TABLE IF NOT EXISTS `audit_logs` (
  `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`     INT UNSIGNED DEFAULT NULL,
  `action`      VARCHAR(100) NOT NULL,
  `description` TEXT         DEFAULT NULL,
  `ip_address`  VARCHAR(45)  DEFAULT NULL,
  `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_audit_user_id` (`user_id`),
  KEY `idx_audit_action` (`action`),
  KEY `idx_audit_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- NEWS / ANNOUNCEMENTS
-- ============================================================
CREATE TABLE IF NOT EXISTS `news` (
  `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `title`      VARCHAR(500) NOT NULL,
  `content`    LONGTEXT     NOT NULL,
  `status`     ENUM('published','draft') NOT NULL DEFAULT 'published',
  `created_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- FAQ
-- ============================================================
CREATE TABLE IF NOT EXISTS `faq` (
  `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `question`   TEXT         NOT NULL,
  `answer`     LONGTEXT     NOT NULL,
  `sort_order` INT          NOT NULL DEFAULT 0,
  `status`     ENUM('active','inactive') NOT NULL DEFAULT 'active',
  `created_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- CUSTOM PAGES
-- ============================================================
CREATE TABLE IF NOT EXISTS `custom_pages` (
  `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `title`      VARCHAR(500) NOT NULL,
  `slug`       VARCHAR(200) NOT NULL,
  `content`    LONGTEXT     NOT NULL,
  `status`     ENUM('published','draft') NOT NULL DEFAULT 'published',
  `created_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_pages_slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- EXCHANGE RATES
-- ============================================================
CREATE TABLE IF NOT EXISTS `exchange_rates` (
  `id`          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `from_currency` VARCHAR(10) NOT NULL,
  `to_currency`   VARCHAR(10) NOT NULL,
  `rate`          DECIMAL(20,8) NOT NULL,
  `updated_at`    DATETIME     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_exchange_pair` (`from_currency`, `to_currency`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
