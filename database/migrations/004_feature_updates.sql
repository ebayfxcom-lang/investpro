-- Migration 004: Feature updates – flexible plan duration, newsletters, scam reports, referral thresholds, fiat currencies

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 1. Plans: flexible duration (value + unit)
-- ============================================================
ALTER TABLE `plans`
  ADD COLUMN IF NOT EXISTS `duration_value` INT UNSIGNED NOT NULL DEFAULT 30
    COMMENT 'Numeric duration value' AFTER `roi_period`,
  ADD COLUMN IF NOT EXISTS `duration_unit`
    ENUM('hour','day','week','month','year') NOT NULL DEFAULT 'day'
    COMMENT 'Unit for duration_value' AFTER `duration_value`;

-- Back-fill from legacy duration_days (value=days, unit=day)
UPDATE `plans`
  SET `duration_value` = `duration_days`,
      `duration_unit`  = 'day'
  WHERE `duration_value` = 30 AND `duration_days` != 30;

-- ============================================================
-- 2. Newsletters table
-- ============================================================
CREATE TABLE IF NOT EXISTS `newsletters` (
  `id`           INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `subject`      VARCHAR(255)  NOT NULL,
  `content`      LONGTEXT      NOT NULL,
  `recipients`   ENUM('all','active','segment') NOT NULL DEFAULT 'all',
  `segment_data` TEXT          DEFAULT NULL COMMENT 'JSON criteria for segment targeting',
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
-- 3. Scam reports table
-- ============================================================
CREATE TABLE IF NOT EXISTS `scam_reports` (
  `id`              INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `website_url`     VARCHAR(500)  NOT NULL,
  `description`     TEXT          NOT NULL,
  `scam_date`       DATE          DEFAULT NULL,
  `evidence_note`   TEXT          DEFAULT NULL,
  `reporter_name`   VARCHAR(100)  DEFAULT NULL,
  `reporter_email`  VARCHAR(150)  DEFAULT NULL,
  `reporter_phone`  VARCHAR(30)   DEFAULT NULL,
  `status`          ENUM('pending','reviewed','confirmed','dismissed') NOT NULL DEFAULT 'pending',
  `admin_notes`     TEXT          DEFAULT NULL,
  `ip_address`      VARCHAR(45)   DEFAULT NULL,
  `created_at`      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      DATETIME      DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_sr_status` (`status`),
  KEY `idx_sr_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 4. FAQ: add category and status columns if missing
-- ============================================================
ALTER TABLE `faq`
  ADD COLUMN IF NOT EXISTS `category`
    ENUM('general','account','deposits','withdrawals','referral','investments','security')
    NOT NULL DEFAULT 'general'
    COMMENT 'FAQ category' AFTER `sort_order`,
  ADD COLUMN IF NOT EXISTS `status`
    ENUM('active','inactive') NOT NULL DEFAULT 'active'
    COMMENT 'Visibility status' AFTER `category`;

-- ============================================================
-- 5. News: add published_at and status columns if missing
-- ============================================================
ALTER TABLE `news`
  ADD COLUMN IF NOT EXISTS `status`
    ENUM('draft','published') NOT NULL DEFAULT 'draft'
    COMMENT 'Publication status' AFTER `content`,
  ADD COLUMN IF NOT EXISTS `published_at`
    DATETIME DEFAULT NULL
    COMMENT 'When the post was published' AFTER `status`;

-- ============================================================
-- 6. Custom pages: ensure required columns
-- ============================================================
ALTER TABLE `custom_pages`
  ADD COLUMN IF NOT EXISTS `meta_description` VARCHAR(255) DEFAULT NULL AFTER `content`;

-- ============================================================
-- 7. Referral threshold settings
-- ============================================================
INSERT IGNORE INTO `settings` (`key`, `value`) VALUES
('referral_threshold_mode',    'flat'),
('referral_min_downlines',     '0'),
('referral_min_deposit',       '0'),
('referral_l1_threshold1_count',  '0'),
('referral_l1_threshold1_rate',   '5'),
('referral_l1_threshold2_count',  '10'),
('referral_l1_threshold2_rate',   '7'),
('referral_l1_threshold3_count',  '25'),
('referral_l1_threshold3_rate',   '10'),
('referral_l2_threshold1_rate',   '2'),
('referral_l2_threshold2_rate',   '3'),
('referral_l2_threshold3_rate',   '5'),
('referral_l3_threshold1_rate',   '1'),
('referral_l3_threshold2_rate',   '1.5'),
('referral_l3_threshold3_rate',   '2');

-- ============================================================
-- 8. Top 20 fiat currencies seed (for internal calculation)
-- ============================================================
INSERT IGNORE INTO `currencies` (`code`, `name`, `symbol`, `type`, `rate_to_usd`, `status`, `sort_order`) VALUES
('GBP', 'British Pound Sterling', '£',  'fiat', 0.78000000, 'active',  3),
('JPY', 'Japanese Yen',           '¥',  'fiat', 149.500000, 'active',  4),
('CHF', 'Swiss Franc',            'Fr', 'fiat', 0.90000000, 'active',  5),
('AUD', 'Australian Dollar',      'A$', 'fiat', 1.55000000, 'active',  6),
('CAD', 'Canadian Dollar',        'C$', 'fiat', 1.36000000, 'active',  7),
('NZD', 'New Zealand Dollar',     'NZ$','fiat', 1.63000000, 'active',  8),
('SGD', 'Singapore Dollar',       'S$', 'fiat', 1.35000000, 'active',  9),
('HKD', 'Hong Kong Dollar',       'HK$','fiat', 7.82000000, 'active', 10),
('AED', 'UAE Dirham',             'د.إ','fiat', 3.67300000, 'active', 11),
('SAR', 'Saudi Riyal',            '﷼',  'fiat', 3.75000000, 'active', 12),
('CNY', 'Chinese Yuan',           '¥',  'fiat', 7.24000000, 'active', 13),
('INR', 'Indian Rupee',           '₹',  'fiat', 83.10000000,'active', 14),
('MXN', 'Mexican Peso',           '$',  'fiat', 17.20000000,'active', 15),
('BRL', 'Brazilian Real',         'R$', 'fiat', 4.97000000, 'active', 16),
('ZAR', 'South African Rand',     'R',  'fiat', 18.60000000,'active', 17),
('TRY', 'Turkish Lira',           '₺',  'fiat', 32.50000000,'active', 18),
('SEK', 'Swedish Krona',          'kr', 'fiat', 10.50000000,'active', 19),
('NOK', 'Norwegian Krone',        'kr', 'fiat', 10.80000000,'active', 20),
('DKK', 'Danish Krone',           'kr', 'fiat', 6.89000000, 'active', 21),
('PLN', 'Polish Zloty',           'zł', 'fiat', 4.03000000, 'active', 22);

-- ============================================================
-- 9. Top crypto currencies seed
-- ============================================================
INSERT IGNORE INTO `currencies` (`code`, `name`, `symbol`, `type`, `rate_to_usd`, `status`, `sort_order`) VALUES
('BNB',   'Binance Coin',  'BNB',  'crypto', 0.00167000, 'active', 30),
('XRP',   'XRP',           'XRP',  'crypto', 1.75000000, 'active', 31),
('ADA',   'Cardano',       'ADA',  'crypto', 2.22000000, 'active', 32),
('SOL',   'Solana',        'SOL',  'crypto', 0.00632000, 'active', 33),
('DOGE',  'Dogecoin',      'DOGE', 'crypto', 6.29000000, 'active', 34),
('TRX',   'TRON',          'TRX',  'crypto', 9.09000000, 'active', 35),
('DOT',   'Polkadot',      'DOT',  'crypto', 0.12800000, 'active', 36),
('LTC',   'Litecoin',      'Ł',    'crypto', 0.01240000, 'active', 37),
('SHIB',  'Shiba Inu',     'SHIB', 'crypto', 59000.00000,'active', 38),
('AVAX',  'Avalanche',     'AVAX', 'crypto', 0.02800000, 'active', 39),
('LINK',  'Chainlink',     'LINK', 'crypto', 0.07400000, 'active', 40),
('UNI',   'Uniswap',       'UNI',  'crypto', 0.14300000, 'active', 41),
('ATOM',  'Cosmos',        'ATOM', 'crypto', 0.11100000, 'active', 42),
('XLM',   'Stellar',       'XLM',  'crypto', 7.14000000, 'active', 43),
('USDC',  'USD Coin',      'USDC', 'crypto', 1.00000000, 'active', 44);

SET FOREIGN_KEY_CHECKS = 1;
