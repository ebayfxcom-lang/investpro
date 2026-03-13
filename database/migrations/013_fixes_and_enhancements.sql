-- Migration 013: Bug fixes, missing columns, reward progress, and feature enhancements
-- Safe to run on any database state 001–012.
-- All operations use IF NOT EXISTS, helper procedures, or guarded INSERT IGNORE.

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- Helper: _m013_add_col – idempotent column addition (MySQL 8+)
-- ============================================================
DROP PROCEDURE IF EXISTS `_m013_add_col`;
DELIMITER //
CREATE PROCEDURE `_m013_add_col`(
    IN p_tbl  VARCHAR(100),
    IN p_col  VARCHAR(100),
    IN p_def  TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME   = p_tbl
          AND COLUMN_NAME  = p_col
    ) THEN
        SET @_sql = CONCAT('ALTER TABLE `', p_tbl, '` ADD COLUMN `', p_col, '` ', p_def);
        PREPARE _ps FROM @_sql;
        EXECUTE _ps;
        DEALLOCATE PREPARE _ps;
    END IF;
END //
DELIMITER ;

-- ============================================================
-- 1. restricted_keywords: ensure table exists (migration 012 catch-up)
-- ============================================================
CREATE TABLE IF NOT EXISTS `restricted_keywords` (
  `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `keyword`    VARCHAR(200) NOT NULL,
  `created_by` INT UNSIGNED DEFAULT NULL,
  `created_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_keyword` (`keyword`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 2. seo_pages: ensure table exists (migration 007 catch-up)
-- ============================================================
CREATE TABLE IF NOT EXISTS `seo_pages` (
  `id`           INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `page_key`     VARCHAR(100)  NOT NULL,
  `page_label`   VARCHAR(200)  NOT NULL DEFAULT '',
  `meta_title`   VARCHAR(300)  DEFAULT NULL,
  `meta_desc`    TEXT          DEFAULT NULL,
  `meta_keywords`VARCHAR(500)  DEFAULT NULL,
  `og_title`     VARCHAR(300)  DEFAULT NULL,
  `og_desc`      TEXT          DEFAULT NULL,
  `og_image`     VARCHAR(500)  DEFAULT NULL,
  `canonical_url`VARCHAR(500)  DEFAULT NULL,
  `schema_json`  TEXT          DEFAULT NULL,
  `admin_guide`  TEXT          DEFAULT NULL,
  `user_guide`   TEXT          DEFAULT NULL,
  `created_at`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`   DATETIME      DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_seo_page_key` (`page_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 3. community_posts: ensure bot/moderation columns
-- ============================================================
CALL `_m013_add_col`('community_posts', 'bot_id',      'INT UNSIGNED DEFAULT NULL AFTER `user_id`');
CALL `_m013_add_col`('community_posts', 'is_featured', 'TINYINT(1) NOT NULL DEFAULT 0 AFTER `is_bot`');
CALL `_m013_add_col`('community_posts', 'is_hidden',   'TINYINT(1) NOT NULL DEFAULT 0 AFTER `is_featured`');
CALL `_m013_add_col`('community_posts', 'likes_count', 'INT NOT NULL DEFAULT 0');

-- ============================================================
-- 4. community_comments: ensure bot_id column
-- ============================================================
CALL `_m013_add_col`('community_comments', 'bot_id', 'INT UNSIGNED DEFAULT NULL AFTER `user_id`');

-- ============================================================
-- 5. community_likes: ensure bot_id column
-- ============================================================
CALL `_m013_add_col`('community_likes', 'bot_id', 'INT UNSIGNED DEFAULT NULL AFTER `user_id`');

-- ============================================================
-- 6. users: ensure team_role_id and updated_at columns
-- ============================================================
CALL `_m013_add_col`('users', 'team_role_id', 'INT UNSIGNED DEFAULT NULL');
CALL `_m013_add_col`('users', 'updated_at',   'DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP');
CALL `_m013_add_col`('users', 'phone',        'VARCHAR(30) DEFAULT NULL');
CALL `_m013_add_col`('users', 'country',      'VARCHAR(80) DEFAULT NULL');

-- ============================================================
-- 7. deposit_wallets: ensure min_deposit column
-- ============================================================
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
  KEY `idx_dw_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CALL `_m013_add_col`('deposit_wallets', 'min_deposit', 'DECIMAL(20,8) NOT NULL DEFAULT 0.00000000');

-- ============================================================
-- 8. reward_progress: ensure table exists
-- ============================================================
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
-- 9. reward_offers: ensure impressions column
-- ============================================================
CALL `_m013_add_col`('reward_offers', 'impressions', 'INT UNSIGNED NOT NULL DEFAULT 0');
CALL `_m013_add_col`('reward_offers', 'banner_url',  'VARCHAR(500) DEFAULT NULL');

-- ============================================================
-- 10. newsletter_guests: ensure table exists (migration 006 catch-up)
-- ============================================================
CREATE TABLE IF NOT EXISTS `newsletter_guests` (
  `id`         INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `email`      VARCHAR(200)  NOT NULL,
  `whatsapp`   VARCHAR(30)   DEFAULT NULL,
  `status`     ENUM('subscribed','unsubscribed') NOT NULL DEFAULT 'subscribed',
  `token`      VARCHAR(64)   NOT NULL,
  `created_at` DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_ng_email` (`email`),
  KEY `idx_ng_token` (`token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 11. kyc_submissions: ensure table exists
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
  KEY `idx_kyc_user` (`user_id`),
  KEY `idx_kyc_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 12. withdrawal_methods: ensure updated_at column
-- ============================================================
CALL `_m013_add_col`('withdrawal_methods', 'updated_at', 'DATETIME DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP');

-- ============================================================
-- 13. newsletters: ensure recipients column supports new values
-- ============================================================
CALL `_m013_add_col`('newsletters', 'recipients', "VARCHAR(50) NOT NULL DEFAULT 'all'");

-- ============================================================
-- 14. bot_profiles: ensure table exists
-- ============================================================
CREATE TABLE IF NOT EXISTS `bot_profiles` (
  `id`             INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `display_name`   VARCHAR(100)  NOT NULL,
  `avatar_url`     VARCHAR(500)  DEFAULT NULL,
  `tone_category`  VARCHAR(50)   NOT NULL DEFAULT 'general',
  `keywords`       JSON          DEFAULT NULL,
  `post_frequency` INT           NOT NULL DEFAULT 60 COMMENT 'Minutes between posts',
  `last_posted_at` DATETIME      DEFAULT NULL,
  `status`         ENUM('active','inactive') NOT NULL DEFAULT 'active',
  `created_at`     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Cleanup helper procedure
-- ============================================================
DROP PROCEDURE IF EXISTS `_m013_add_col`;

SET FOREIGN_KEY_CHECKS = 1;
