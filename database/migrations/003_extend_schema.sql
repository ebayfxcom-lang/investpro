-- Migration 003: Extend schema with currency history, spin system, and extra user/deposit/withdrawal fields

-- Alter users table
ALTER TABLE `users`
  ADD COLUMN IF NOT EXISTS `whatsapp_number` VARCHAR(30) DEFAULT NULL AFTER `phone`,
  ADD COLUMN IF NOT EXISTS `facebook_url` VARCHAR(255) DEFAULT NULL AFTER `whatsapp_number`,
  ADD COLUMN IF NOT EXISTS `preferred_currency` VARCHAR(10) DEFAULT 'USD' AFTER `facebook_url`,
  ADD COLUMN IF NOT EXISTS `payout_details` TEXT DEFAULT NULL AFTER `preferred_currency`,
  ADD COLUMN IF NOT EXISTS `communication_prefs` VARCHAR(100) DEFAULT 'email' AFTER `payout_details`;

-- Alter deposits table
ALTER TABLE `deposits`
  ADD COLUMN IF NOT EXISTS `usd_amount` DECIMAL(20,8) DEFAULT NULL AFTER `currency`,
  ADD COLUMN IF NOT EXISTS `eur_amount` DECIMAL(20,8) DEFAULT NULL AFTER `usd_amount`,
  ADD COLUMN IF NOT EXISTS `rate_snapshot` JSON DEFAULT NULL AFTER `eur_amount`;

-- Alter withdrawals table
ALTER TABLE `withdrawals`
  ADD COLUMN IF NOT EXISTS `usd_amount` DECIMAL(20,8) DEFAULT NULL AFTER `currency`,
  ADD COLUMN IF NOT EXISTS `eur_amount` DECIMAL(20,8) DEFAULT NULL AFTER `usd_amount`,
  ADD COLUMN IF NOT EXISTS `rate_snapshot` JSON DEFAULT NULL AFTER `eur_amount`;

-- Create currency_price_history table
CREATE TABLE IF NOT EXISTS `currency_price_history` (
  `id`           INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  `currency_code` VARCHAR(10)   NOT NULL,
  `price_usd`    DECIMAL(20,8)  NOT NULL,
  `price_eur`    DECIMAL(20,8)  DEFAULT NULL,
  `source`       VARCHAR(50)    NOT NULL DEFAULT 'api',
  `recorded_at`  DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_cph_code` (`currency_code`),
  KEY `idx_cph_recorded` (`recorded_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create exchange_rate_snapshots table
CREATE TABLE IF NOT EXISTS `exchange_rate_snapshots` (
  `id`             INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `ref_type`       VARCHAR(20)   NOT NULL COMMENT 'deposit or withdrawal',
  `ref_id`         INT UNSIGNED  NOT NULL,
  `from_currency`  VARCHAR(10)   NOT NULL,
  `to_currency`    VARCHAR(10)   NOT NULL,
  `rate`           DECIMAL(20,8) NOT NULL,
  `amount_original` DECIMAL(20,8) NOT NULL,
  `amount_converted` DECIMAL(20,8) NOT NULL,
  `created_at`     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ers_ref` (`ref_type`, `ref_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create spin_settings table
CREATE TABLE IF NOT EXISTS `spin_settings` (
  `id`                INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `enabled`           TINYINT(1)   NOT NULL DEFAULT 1,
  `spin_price`        DECIMAL(10,4) NOT NULL DEFAULT 1.0000 COMMENT 'Price per purchased spin in USD',
  `daily_free_spins`  INT          NOT NULL DEFAULT 1,
  `updated_at`        DATETIME     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT IGNORE INTO `spin_settings` (`id`, `enabled`, `spin_price`, `daily_free_spins`) VALUES (1, 1, 1.0000, 1);

-- Create spin_rewards table
CREATE TABLE IF NOT EXISTS `spin_rewards` (
  `id`           INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `slot`         TINYINT       NOT NULL COMMENT '1-12 slot number',
  `label`        VARCHAR(100)  NOT NULL,
  `reward_type`  ENUM('points','usd','eur','bonus','spin_credits','percent_bonus','no_reward') NOT NULL DEFAULT 'no_reward',
  `reward_value` DECIMAL(20,8) NOT NULL DEFAULT 0.00000000,
  `probability`  DECIMAL(10,6) NOT NULL DEFAULT 8.333333 COMMENT 'Winning probability percent',
  `color`        VARCHAR(20)   NOT NULL DEFAULT '#1e40af',
  `status`       ENUM('active','inactive') NOT NULL DEFAULT 'active',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_spin_slot` (`slot`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create user_spins table
CREATE TABLE IF NOT EXISTS `user_spins` (
  `id`            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`       INT UNSIGNED NOT NULL,
  `free_spins`    INT          NOT NULL DEFAULT 0,
  `paid_spins`    INT          NOT NULL DEFAULT 0,
  `last_free_spin_date` DATE   DEFAULT NULL,
  `updated_at`    DATETIME     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_user_spins_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create spin_history table
CREATE TABLE IF NOT EXISTS `spin_history` (
  `id`           INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`      INT UNSIGNED  NOT NULL,
  `reward_id`    INT UNSIGNED  DEFAULT NULL,
  `spin_type`    ENUM('free','paid') NOT NULL DEFAULT 'free',
  `reward_type`  VARCHAR(30)   NOT NULL,
  `reward_value` DECIMAL(20,8) NOT NULL DEFAULT 0.00000000,
  `reward_label` VARCHAR(100)  NOT NULL,
  `created_at`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_sh_user_id` (`user_id`),
  KEY `idx_sh_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default spin reward slots (12 slots)
INSERT IGNORE INTO `spin_rewards` (`slot`, `label`, `reward_type`, `reward_value`, `probability`, `color`) VALUES
(1,  'Try Again',    'no_reward',    0.00,  20.000000, '#6b7280'),
(2,  '$5 Bonus',     'usd',          5.00,   5.000000, '#059669'),
(3,  '10 Points',    'points',      10.00,  15.000000, '#1e40af'),
(4,  '$1 Credit',    'usd',          1.00,  15.000000, '#0891b2'),
(5,  '1 Free Spin',  'spin_credits', 1.00,  10.000000, '#7c3aed'),
(6,  'Try Again',    'no_reward',    0.00,  10.000000, '#6b7280'),
(7,  '$10 Bonus',    'usd',         10.00,   3.000000, '#dc2626'),
(8,  '50 Points',    'points',      50.00,   5.000000, '#1e40af'),
(9,  '5% Bonus',     'percent_bonus',5.00,   4.000000, '#d97706'),
(10, '$2 Credit',    'usd',          2.00,  10.000000, '#0891b2'),
(11, '2 Free Spins', 'spin_credits', 2.00,   2.000000, '#7c3aed'),
(12, '$50 Jackpot',  'usd',         50.00,   1.000000, '#b91c1c');
