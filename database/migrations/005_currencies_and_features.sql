-- Migration 005: Full 100-currency list, newsletter sender name,
--                news publisher/hashtags, FAQ custom category table,
--                spin free/paid reward separation, deposit wallets

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 1. Ensure spin tables exist (safety re-create if migration 003 was skipped)
-- ============================================================
CREATE TABLE IF NOT EXISTS `spin_settings` (
  `id`                INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `enabled`           TINYINT(1)    NOT NULL DEFAULT 1,
  `spin_price`        DECIMAL(10,4) NOT NULL DEFAULT 1.0000,
  `daily_free_spins`  INT           NOT NULL DEFAULT 1,
  `updated_at`        DATETIME      DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `spin_settings` (`id`, `enabled`, `spin_price`, `daily_free_spins`) VALUES (1, 1, 1.0000, 1);

CREATE TABLE IF NOT EXISTS `spin_rewards` (
  `id`           INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `slot`         TINYINT       NOT NULL COMMENT '1-12 slot number',
  `spin_mode`    ENUM('free','paid','both') NOT NULL DEFAULT 'both' COMMENT 'Which type of spin uses this slot',
  `label`        VARCHAR(100)  NOT NULL,
  `reward_type`  ENUM('points','usd','eur','bonus','spin_credits','percent_bonus','no_reward') NOT NULL DEFAULT 'no_reward',
  `reward_value` DECIMAL(20,8) NOT NULL DEFAULT 0.00000000,
  `probability`  DECIMAL(10,6) NOT NULL DEFAULT 8.333333,
  `color`        VARCHAR(20)   NOT NULL DEFAULT '#1e40af',
  `status`       ENUM('active','inactive') NOT NULL DEFAULT 'active',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_spin_slot_mode` (`slot`, `spin_mode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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

-- Add spin_mode column to spin_rewards if it already existed without it
ALTER TABLE `spin_rewards`
  ADD COLUMN IF NOT EXISTS `spin_mode`
    ENUM('free','paid','both') NOT NULL DEFAULT 'both'
    COMMENT 'Which type of spin uses this slot'
    AFTER `slot`;

-- Re-seed default reward slots if table is empty
INSERT IGNORE INTO `spin_rewards` (`slot`, `spin_mode`, `label`, `reward_type`, `reward_value`, `probability`, `color`) VALUES
(1,  'both', 'Try Again',    'no_reward',    0.00,  20.000000, '#6b7280'),
(2,  'both', '$5 Bonus',     'usd',          5.00,   5.000000, '#059669'),
(3,  'both', '10 Points',    'points',      10.00,  15.000000, '#1e40af'),
(4,  'both', '$1 Credit',    'usd',          1.00,  15.000000, '#0891b2'),
(5,  'both', '1 Free Spin',  'spin_credits', 1.00,  10.000000, '#7c3aed'),
(6,  'both', 'Try Again',    'no_reward',    0.00,  10.000000, '#6b7280'),
(7,  'both', '$10 Bonus',    'usd',         10.00,   3.000000, '#dc2626'),
(8,  'both', '50 Points',    'points',      50.00,   5.000000, '#1e40af'),
(9,  'both', '5% Bonus',     'percent_bonus',5.00,   4.000000, '#d97706'),
(10, 'both', '$2 Credit',    'usd',          2.00,  10.000000, '#0891b2'),
(11, 'both', '2 Free Spins', 'spin_credits', 2.00,   2.000000, '#7c3aed'),
(12, 'both', '$50 Jackpot',  'usd',         50.00,   1.000000, '#b91c1c');

-- ============================================================
-- 2. Ensure newsletters table exists
-- ============================================================
CREATE TABLE IF NOT EXISTS `newsletters` (
  `id`           INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `subject`      VARCHAR(255)  NOT NULL,
  `content`      LONGTEXT      NOT NULL,
  `sender_name`  VARCHAR(100)  DEFAULT NULL COMMENT 'Name of the admin who sent this',
  `sent_by`      INT UNSIGNED  DEFAULT NULL COMMENT 'Admin user ID who sent',
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

-- Add sender_name and sent_by columns to existing newsletters table
ALTER TABLE `newsletters`
  ADD COLUMN IF NOT EXISTS `sender_name` VARCHAR(100) DEFAULT NULL
    COMMENT 'Name of the admin who sent this' AFTER `content`,
  ADD COLUMN IF NOT EXISTS `sent_by` INT UNSIGNED DEFAULT NULL
    COMMENT 'Admin user ID who sent' AFTER `sender_name`;

-- ============================================================
-- 3. News: add publisher_name and hashtags columns
-- ============================================================
ALTER TABLE `news`
  ADD COLUMN IF NOT EXISTS `publisher_name` VARCHAR(100) DEFAULT NULL
    COMMENT 'Name of the admin who published this' AFTER `status`,
  ADD COLUMN IF NOT EXISTS `hashtags` VARCHAR(500) DEFAULT NULL
    COMMENT 'Comma-separated hashtags for SEO' AFTER `publisher_name`;

-- ============================================================
-- 4. FAQ custom categories table
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

-- Seed default FAQ categories
INSERT IGNORE INTO `faq_categories` (`name`, `slug`, `status`, `sort_order`) VALUES
('General',      'general',      'active', 1),
('Account',      'account',      'active', 2),
('Deposits',     'deposits',     'active', 3),
('Withdrawals',  'withdrawals',  'active', 4),
('Referral',     'referral',     'active', 5),
('Investments',  'investments',  'active', 6),
('Security',     'security',     'active', 7);

-- Add category_id column to faq table for custom categories
ALTER TABLE `faq`
  ADD COLUMN IF NOT EXISTS `category_id` INT UNSIGNED DEFAULT NULL
    COMMENT 'FK to faq_categories' AFTER `sort_order`,
  ADD COLUMN IF NOT EXISTS `category`
    ENUM('general','account','deposits','withdrawals','referral','investments','security')
    NOT NULL DEFAULT 'general' AFTER `category_id`,
  ADD COLUMN IF NOT EXISTS `status`
    ENUM('active','inactive') NOT NULL DEFAULT 'active' AFTER `category`;

-- ============================================================
-- 5. Deposit wallets table (admin-managed crypto addresses)
-- ============================================================
CREATE TABLE IF NOT EXISTS `deposit_wallets` (
  `id`             INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `currency_code`  VARCHAR(10)   NOT NULL,
  `network`        VARCHAR(50)   NOT NULL DEFAULT '' COMMENT 'e.g. ERC20, TRC20, BEP20',
  `wallet_address` VARCHAR(255)  NOT NULL,
  `memo`           VARCHAR(100)  DEFAULT NULL COMMENT 'Optional memo/tag',
  `instructions`   TEXT          DEFAULT NULL COMMENT 'User-facing instructions',
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
-- 6. Currency price history (safety re-create)
-- ============================================================
CREATE TABLE IF NOT EXISTS `currency_price_history` (
  `id`            INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `currency_code` VARCHAR(10)   NOT NULL,
  `price_usd`     DECIMAL(20,8) NOT NULL,
  `price_eur`     DECIMAL(20,8) DEFAULT NULL,
  `source`        VARCHAR(50)   NOT NULL DEFAULT 'api',
  `recorded_at`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_cph_code` (`currency_code`),
  KEY `idx_cph_recorded` (`recorded_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 7. Scam reports table (safety re-create)
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
  KEY `idx_sr_status` (`status`),
  KEY `idx_sr_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 8. All 100 crypto currencies
-- ============================================================
INSERT IGNORE INTO `currencies` (`code`, `name`, `symbol`, `type`, `rate_to_usd`, `status`, `sort_order`) VALUES
('BTC',     'Bitcoin',                              'BTC',    'crypto', 0.000015000, 'active',  1),
('ETH',     'Ethereum',                             'ETH',    'crypto', 0.000270000, 'active',  2),
('USDT',    'Tether',                               'USDT',   'crypto', 1.000000000, 'active',  3),
('BNB',     'BNB',                                  'BNB',    'crypto', 0.001670000, 'active',  4),
('XRP',     'XRP',                                  'XRP',    'crypto', 1.750000000, 'active',  5),
('USDC',    'USDC',                                 'USDC',   'crypto', 1.000000000, 'active',  6),
('SOL',     'Solana',                               'SOL',    'crypto', 0.006320000, 'active',  7),
('TRX',     'TRON',                                 'TRX',    'crypto', 9.090000000, 'active',  8),
('DOGE',    'Dogecoin',                             'DOGE',   'crypto', 6.290000000, 'active',  9),
('WBT',     'WhiteBIT Coin',                        'WBT',    'crypto', 0.039000000, 'active', 10),
('ADA',     'Cardano',                              'ADA',    'crypto', 2.220000000, 'active', 11),
('BCH',     'Bitcoin Cash',                         'BCH',    'crypto', 0.002100000, 'active', 12),
('HYPE',    'Hyperliquid',                          'HYPE',   'crypto', 0.050000000, 'active', 13),
('LEO',     'LEO Token',                            'LEO',    'crypto', 0.135000000, 'active', 14),
('XMR',     'Monero',                               'XMR',    'crypto', 0.005600000, 'active', 15),
('LINK',    'Chainlink',                            'LINK',   'crypto', 0.074000000, 'active', 16),
('XLM',     'Stellar',                              'XLM',    'crypto', 7.140000000, 'active', 17),
('DAI',     'Dai',                                  'DAI',    'crypto', 1.000000000, 'active', 18),
('LTC',     'Litecoin',                             'LTC',    'crypto', 0.012400000, 'active', 19),
('AVAX',    'Avalanche',                            'AVAX',   'crypto', 0.028000000, 'active', 20),
('HBAR',    'Hedera',                               'HBAR',   'crypto', 6.250000000, 'active', 21),
('PYUSD',   'PayPal USD',                           'PYUSD',  'crypto', 1.000000000, 'active', 22),
('SUI',     'Sui',                                  'SUI',    'crypto', 0.590000000, 'active', 23),
('ZEC',     'Zcash',                                'ZEC',    'crypto', 0.020000000, 'active', 24),
('SHIB',    'Shiba Inu',                            'SHIB',   'crypto', 59000.00000, 'active', 25),
('TON',     'Toncoin',                              'TON',    'crypto', 0.193000000, 'active', 26),
('CRO',     'Cronos',                               'CRO',    'crypto', 8.620000000, 'active', 27),
('PAXG',    'PAX Gold',                             'PAXG',   'crypto', 0.000450000, 'active', 28),
('DOT',     'Polkadot',                             'DOT',    'crypto', 0.128000000, 'active', 29),
('UNI',     'Uniswap',                              'UNI',    'crypto', 0.143000000, 'active', 30),
('MNT',     'Mantle',                               'MNT',    'crypto', 0.870000000, 'active', 31),
('PI',      'Pi Network',                           'PI',     'crypto', 1.500000000, 'active', 32),
('OKB',     'OKB',                                  'OKB',    'crypto', 0.023000000, 'active', 33),
('TAO',     'Bittensor',                            'TAO',    'crypto', 0.002100000, 'active', 34),
('ASTER',   'Aster',                                'ASTER',  'crypto', 1.000000000, 'active', 35),
('AAVE',    'Aave',                                 'AAVE',   'crypto', 0.004600000, 'active', 36),
('NEAR',    'NEAR Protocol',                        'NEAR',   'crypto', 0.212000000, 'active', 37),
('BGB',     'Bitget Token',                         'BGB',    'crypto', 0.116000000, 'active', 38),
('ICP',     'Internet Computer',                    'ICP',    'crypto', 0.112000000, 'active', 39),
('ETC',     'Ethereum Classic',                     'ETC',    'crypto', 0.038000000, 'active', 40),
('ONDO',    'Ondo',                                 'ONDO',   'crypto', 0.840000000, 'active', 41),
('PUMP',    'Pump.fun',                             'PUMP',   'crypto', 1.000000000, 'active', 42),
('KCS',     'KuCoin',                               'KCS',    'crypto', 0.093000000, 'active', 43),
('WLD',     'Worldcoin',                            'WLD',    'crypto', 0.430000000, 'active', 44),
('QNT',     'Quant',                                'QNT',    'crypto', 0.008300000, 'active', 45),
('ENA',     'Ethena',                               'ENA',    'crypto', 1.090000000, 'active', 46),
('KAS',     'Kaspa',                                'KAS',    'crypto', 7.690000000, 'active', 47),
('RENDER',  'Render',                               'RENDER', 'crypto', 0.145000000, 'active', 48),
('ALGO',    'Algorand',                             'ALGO',   'crypto', 5.880000000, 'active', 49),
('FLR',     'Flare',                                'FLR',    'crypto', 29.41000000, 'active', 50),
('APT',     'Aptos',                                'APT',    'crypto', 0.125000000, 'active', 51),
('TRUMP',   'Official Trump',                       'TRUMP',  'crypto', 0.055000000, 'active', 52),
('FIL',     'Filecoin',                             'FIL',    'crypto', 0.213000000, 'active', 53),
('VET',     'VeChain',                              'VET',    'crypto', 29.41000000, 'active', 54),
('ARB',     'Arbitrum',                             'ARB',    'crypto', 1.280000000, 'active', 55),
('JUP',     'Jupiter',                              'JUP',    'crypto', 0.813000000, 'active', 56),
('BONK',    'Bonk',                                 'BONK',   'crypto', 101000.0000, 'active', 57),
('TUSD',    'TrueUSD',                              'TUSD',   'crypto', 1.000000000, 'active', 58),
('DCR',     'Decred',                               'DCR',    'crypto', 0.047000000, 'active', 59),
('STX',     'Stacks',                               'STX',    'crypto', 0.476000000, 'active', 60),
('VIRTUAL', 'Virtuals Protocol',                    'VIRTUAL','crypto', 0.500000000, 'active', 61),
('CAKE',    'PancakeSwap',                          'CAKE',   'crypto', 0.400000000, 'active', 62),
('ZRO',     'LayerZero',                            'ZRO',    'crypto', 0.250000000, 'active', 63),
('SEI',     'Sei',                                  'SEI',    'crypto', 1.180000000, 'active', 64),
('DASH',    'Dash',                                 'DASH',   'crypto', 0.028000000, 'active', 65),
('CHZ',     'Chiliz',                               'CHZ',    'crypto', 9.090000000, 'active', 66),
('XTZ',     'Tezos',                                'XTZ',    'crypto', 0.510000000, 'active', 67),
('FET',     'Artificial Superintelligence Alliance','FET',    'crypto', 0.660000000, 'active', 68),
('CRV',     'Curve DAO',                            'CRV',    'crypto', 2.040000000, 'active', 69),
('BTT',     'BitTorrent',                           'BTT',    'crypto', 1250000.000, 'active', 70),
('SUN',     'Sun Token',                            'SUN',    'crypto', 51.000000000,'active', 71),
('BSV',     'Bitcoin SV',                           'BSV',    'crypto', 0.016900000, 'active', 72),
('INJ',     'Injective',                            'INJ',    'crypto', 0.034800000, 'active', 73),
('TIA',     'Celestia',                             'TIA',    'crypto', 0.167000000, 'active', 74),
('FLOKI',   'FLOKI',                                'FLOKI',  'crypto', 22727.00000, 'active', 75),
('RIVER',   'River',                                'RIVER',  'crypto', 1.000000000, 'active', 76),
('JASMY',   'JasmyCoin',                            'JASMY',  'crypto', 105.260000,  'active', 77),
('GRT',     'The Graph',                            'GRT',    'crypto', 4.880000000, 'active', 78),
('IOTA',    'IOTA',                                 'IOTA',   'crypto', 3.570000000, 'active', 79),
('PYTH',    'Pyth Network',                         'PYTH',   'crypto', 3.030000000, 'active', 80),
('OP',      'Optimism',                             'OP',     'crypto', 0.500000000, 'active', 81),
('LDO',     'Lido DAO',                             'LDO',    'crypto', 0.680000000, 'active', 82),
('BARD',    'Lombard',                              'BARD',   'crypto', 1.000000000, 'active', 83),
('ENS',     'Ethereum Name Service',                'ENS',    'crypto', 0.033000000, 'active', 84),
('LUNC',    'Terra Luna Classic',                   'LUNC',   'crypto', 833333.0000, 'active', 85),
('SAND',    'The Sandbox',                          'SAND',   'crypto', 2.040000000, 'active', 86),
('HNT',     'Helium',                               'HNT',    'crypto', 0.167000000, 'active', 87),
('PENDLE',  'Pendle',                               'PENDLE', 'crypto', 0.200000000, 'active', 88),
('TWT',     'Trust Wallet',                         'TWT',    'crypto', 0.400000000, 'active', 89),
('DEXE',    'DeXe',                                 'DEXE',   'crypto', 0.083000000, 'active', 90),
('AXS',     'Axie Infinity',                        'AXS',    'crypto', 0.143000000, 'active', 91),
('COMP',    'Compound',                             'COMP',   'crypto', 0.011900000, 'active', 92),
('THETA',   'Theta Network',                        'THETA',  'crypto', 0.500000000, 'active', 93),
('NEO',     'NEO',                                  'NEO',    'crypto', 0.059500000, 'active', 94),
('REAL',    'RealLink',                             'REAL',   'crypto', 1.000000000, 'active', 95),
('MANA',    'Decentraland',                         'MANA',   'crypto', 2.500000000, 'active', 96),
('ZK',      'ZKsync',                               'ZK',     'crypto', 5.000000000, 'active', 97),
('MX',      'MX',                                   'MX',     'crypto', 0.250000000, 'active', 98),
('GALA',    'GALA',                                 'GALA',   'crypto', 50.000000000,'active', 99),
('AR',      'Arweave',                              'AR',     'crypto', 0.023000000, 'active',100);

-- ============================================================
-- 9. Referral threshold settings (safety)
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

SET FOREIGN_KEY_CHECKS = 1;
