-- Migration 011: Fix registration, login, and dashboard 500 errors on MySQL 8.0
--
-- Purpose
-- -------
-- Ensures that all columns required for user registration, login, and the user
-- dashboard exist in the database.  Migration 009 used ADD COLUMN IF NOT EXISTS
-- (MariaDB-only) which silently fails on MySQL 8.0.  Migration 010 introduced a
-- stored-procedure workaround but may not have been executed on all deployments.
-- This migration is a standalone, idempotent catch-up for MySQL 8.0.45+.
--
-- Compatibility
-- -------------
-- MySQL 8.0+ (no MariaDB syntax); safe to re-run.
--
-- What this migration does
-- ------------------------
-- A) Adds all columns used in user registration to the users table
-- B) Adds columns accessed by auth/dashboard that use ?? null-safe fallbacks
-- C) Ensures all tables used during login/registration exist
-- D) Seeds required settings rows

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- A. Helper stored procedure (same pattern as migration 010)
-- ============================================================
DROP PROCEDURE IF EXISTS `_ip_add_col_011`;

DELIMITER //
CREATE PROCEDURE `_ip_add_col_011`(
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
-- B. Critical users table columns for registration & auth
-- ============================================================

-- Required by AuthController::register() INSERT
CALL _ip_add_col_011('users', 'whatsapp_number',        'VARCHAR(30) DEFAULT NULL');
CALL _ip_add_col_011('users', 'facebook_url',           'VARCHAR(255) DEFAULT NULL');
CALL _ip_add_col_011('users', 'preferred_currency',     'VARCHAR(10) NOT NULL DEFAULT ''USD''');

-- Required by 2FA / security features
CALL _ip_add_col_011('users', 'two_factor_backup_codes','TEXT DEFAULT NULL');
CALL _ip_add_col_011('users', 'two_factor_confirmed_at','DATETIME DEFAULT NULL');

-- Required by DashboardController (accessed with ?? fallback but column must exist
-- in MySQL strict mode for INSERT/UPDATE calls that reference it)
CALL _ip_add_col_011('users', 'account_type',           'ENUM(''normal'',''representative'',''team_leader'') NOT NULL DEFAULT ''normal''');
CALL _ip_add_col_011('users', 'team_role_id',           'INT UNSIGNED DEFAULT NULL');

-- Additional user profile columns
CALL _ip_add_col_011('users', 'avatar',                 'VARCHAR(255) DEFAULT NULL');
CALL _ip_add_col_011('users', 'bio',                    'TEXT DEFAULT NULL');
CALL _ip_add_col_011('users', 'address',                'TEXT DEFAULT NULL');
CALL _ip_add_col_011('users', 'city',                   'VARCHAR(80) DEFAULT NULL');
CALL _ip_add_col_011('users', 'zip',                    'VARCHAR(20) DEFAULT NULL');
CALL _ip_add_col_011('users', 'date_of_birth',          'DATE DEFAULT NULL');
CALL _ip_add_col_011('users', 'id_verified',            'TINYINT(1) NOT NULL DEFAULT 0');
CALL _ip_add_col_011('users', 'totp_secret',            'VARCHAR(100) DEFAULT NULL');
CALL _ip_add_col_011('users', 'last_active_at',         'DATETIME DEFAULT NULL');

-- ============================================================
-- C. Tables required during login / registration flow
-- ============================================================

-- spin_settings: required by SpinService::grantDailyFreeSpins() called on login
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

-- user_spins: required by SpinService / UserSpinModel
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

-- audit_logs: required by AuditLog::log() called on every login/register
CREATE TABLE IF NOT EXISTS `audit_logs` (
  `id`          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`     INT UNSIGNED  DEFAULT NULL,
  `action`      VARCHAR(100)  NOT NULL,
  `description` TEXT          DEFAULT NULL,
  `ip_address`  VARCHAR(45)   NOT NULL DEFAULT '0.0.0.0',
  `created_at`  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_audit_user`    (`user_id`),
  KEY `idx_audit_action`  (`action`),
  KEY `idx_audit_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- settings: required by SettingsModel (called in Controller::initSmarty)
CREATE TABLE IF NOT EXISTS `settings` (
  `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `key`        VARCHAR(100) NOT NULL,
  `value`      TEXT         DEFAULT NULL,
  `updated_at` DATETIME     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_settings_key` (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Ensure critical settings keys exist
INSERT IGNORE INTO `settings` (`key`, `value`) VALUES
('kyc_enabled',        '0'),
('community_enabled',  '0'),
('rewards_hub_enabled','0'),
('site_theme',         'dark'),
('deposit_qr_enabled', '1');

-- wallets: required by DashboardController / WalletModel
CREATE TABLE IF NOT EXISTS `wallets` (
  `id`         INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`    INT UNSIGNED  NOT NULL,
  `currency`   VARCHAR(10)   NOT NULL DEFAULT 'USD',
  `balance`    DECIMAL(20,8) NOT NULL DEFAULT 0.00000000,
  `locked`     DECIMAL(20,8) NOT NULL DEFAULT 0.00000000,
  `created_at` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME      DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_wallets_user_currency` (`user_id`, `currency`),
  KEY `idx_wallets_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- transactions: required by DashboardController
CREATE TABLE IF NOT EXISTS `transactions` (
  `id`          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`     INT UNSIGNED  NOT NULL,
  `type`        VARCHAR(50)   NOT NULL,
  `amount`      DECIMAL(20,8) NOT NULL,
  `currency`    VARCHAR(10)   NOT NULL DEFAULT 'USD',
  `description` TEXT          DEFAULT NULL,
  `status`      ENUM('pending','completed','failed','cancelled') NOT NULL DEFAULT 'completed',
  `ref_id`      INT UNSIGNED  DEFAULT NULL,
  `created_at`  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_trans_user` (`user_id`),
  KEY `idx_trans_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- deposits: required by DashboardController
CREATE TABLE IF NOT EXISTS `deposits` (
  `id`          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`     INT UNSIGNED  NOT NULL,
  `plan_id`     INT UNSIGNED  NOT NULL DEFAULT 0,
  `amount`      DECIMAL(20,8) NOT NULL,
  `currency`    VARCHAR(10)   NOT NULL DEFAULT 'USD',
  `status`      ENUM('pending','active','completed','expired','rejected','cancelled') NOT NULL DEFAULT 'pending',
  `tx_hash`     VARCHAR(255)  DEFAULT NULL,
  `expires_at`  DATETIME      DEFAULT NULL,
  `created_at`  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  DATETIME      DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_deposits_user_id` (`user_id`),
  KEY `idx_deposits_status`  (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- earnings: required by DashboardController
CREATE TABLE IF NOT EXISTS `earnings` (
  `id`          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`     INT UNSIGNED  NOT NULL,
  `deposit_id`  INT UNSIGNED  NOT NULL DEFAULT 0,
  `amount`      DECIMAL(20,8) NOT NULL,
  `currency`    VARCHAR(10)   NOT NULL DEFAULT 'USD',
  `type`        ENUM('roi','bonus','referral') NOT NULL DEFAULT 'roi',
  `status`      ENUM('pending','paid','cancelled') NOT NULL DEFAULT 'paid',
  `created_at`  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_earnings_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- referral_earnings: required by ReferralModel in DashboardController
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
  KEY `idx_ref_earnings_referrer` (`referrer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- user_notices / user_notice_reads: required by UserNoticeModel
CREATE TABLE IF NOT EXISTS `user_notices` (
  `id`         INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `title`      VARCHAR(200)  NOT NULL,
  `content`    TEXT          NOT NULL,
  `type`       ENUM('info','warning','success','danger') NOT NULL DEFAULT 'info',
  `target`     ENUM('all','deposited','free','representatives','leaders','team') NOT NULL DEFAULT 'all',
  `status`     ENUM('published','draft') NOT NULL DEFAULT 'draft',
  `starts_at`  DATETIME      DEFAULT NULL,
  `ends_at`    DATETIME      DEFAULT NULL,
  `created_at` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_notices_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `user_notice_reads` (
  `notice_id` INT UNSIGNED NOT NULL,
  `user_id`   INT UNSIGNED NOT NULL,
  `read_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`notice_id`, `user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- plans: needed by deposit flow and public plans page
CREATE TABLE IF NOT EXISTS `plans` (
  `id`           INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `name`         VARCHAR(100)  NOT NULL,
  `description`  TEXT          DEFAULT NULL,
  `roi_percent`  DECIMAL(10,4) NOT NULL DEFAULT 0.0000,
  `min_amount`   DECIMAL(20,8) NOT NULL DEFAULT 0.00000000,
  `max_amount`   DECIMAL(20,8) NOT NULL DEFAULT 0.00000000,
  `duration`     INT           NOT NULL DEFAULT 30 COMMENT 'duration in days (original field; use duration_value+duration_unit for flexible scheduling)',
  `status`       ENUM('active','inactive') NOT NULL DEFAULT 'active',
  `created_at`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`   DATETIME      DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_plans_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- D. Cleanup
-- ============================================================
DROP PROCEDURE IF EXISTS `_ip_add_col_011`;

SET FOREIGN_KEY_CHECKS = 1;
