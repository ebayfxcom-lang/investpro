-- Migration 007: Team roles, user notices, support tickets, SEO meta, newsletter guests, conditional plans

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 1. TEAM ROLES
-- ============================================================
CREATE TABLE IF NOT EXISTS `team_roles` (
  `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`        VARCHAR(80)  NOT NULL COMMENT 'e.g. founder, superadmin, ceo, security_manager, financial_manager, support, moderator',
  `label`       VARCHAR(120) NOT NULL COMMENT 'Human-readable label',
  `description` TEXT         DEFAULT NULL,
  `is_system`   TINYINT(1)   NOT NULL DEFAULT 0 COMMENT '1 = built-in, cannot be deleted',
  `sort_order`  INT          NOT NULL DEFAULT 0,
  `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_role_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 2. PERMISSIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS `permissions` (
  `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`        VARCHAR(120) NOT NULL COMMENT 'Slug e.g. users.view, finance.approve',
  `label`       VARCHAR(200) NOT NULL,
  `module`      VARCHAR(80)  NOT NULL DEFAULT 'general',
  `sort_order`  INT          NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_perm_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 3. ROLE PERMISSIONS
-- ============================================================
CREATE TABLE IF NOT EXISTS `role_permissions` (
  `role_id`       INT UNSIGNED NOT NULL,
  `permission_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`role_id`, `permission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 4. USER TEAM ASSIGNMENTS
-- ============================================================
ALTER TABLE `users`
  ADD COLUMN IF NOT EXISTS `team_role_id`  INT UNSIGNED  DEFAULT NULL COMMENT 'Assigned team role (for staff)' AFTER `role`,
  ADD COLUMN IF NOT EXISTS `account_type`  ENUM('normal','representative','team_leader') NOT NULL DEFAULT 'normal' AFTER `team_role_id`,
  ADD COLUMN IF NOT EXISTS `preferred_currency` VARCHAR(10) NOT NULL DEFAULT 'USD' AFTER `account_type`;

-- ============================================================
-- 5. USER NOTICES
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
  `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `notice_id`  INT UNSIGNED NOT NULL,
  `user_id`    INT UNSIGNED NOT NULL,
  `read_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_notice_user` (`notice_id`, `user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 6. SUPPORT TICKET DEPARTMENTS
-- ============================================================
CREATE TABLE IF NOT EXISTS `ticket_departments` (
  `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`       VARCHAR(100) NOT NULL,
  `slug`       VARCHAR(100) NOT NULL,
  `description` VARCHAR(300) DEFAULT NULL,
  `sort_order` INT          NOT NULL DEFAULT 0,
  `status`     ENUM('active','inactive') NOT NULL DEFAULT 'active',
  `created_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_dept_slug` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 7. SUPPORT TICKETS
-- ============================================================
CREATE TABLE IF NOT EXISTS `support_tickets` (
  `id`              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `reference`       VARCHAR(20)  NOT NULL COMMENT 'Human-readable ticket ref e.g. TKT-00001',
  `user_id`         INT UNSIGNED DEFAULT NULL COMMENT 'NULL for guest tickets',
  `guest_email`     VARCHAR(150) DEFAULT NULL,
  `guest_token`     VARCHAR(80)  DEFAULT NULL COMMENT 'Secure token for guest access',
  `department_id`   INT UNSIGNED NOT NULL,
  `subject`         VARCHAR(300) NOT NULL,
  `priority`        ENUM('low','normal','high','urgent') NOT NULL DEFAULT 'normal',
  `status`          ENUM('open','in_progress','waiting','resolved','closed') NOT NULL DEFAULT 'open',
  `assigned_to`     INT UNSIGNED DEFAULT NULL COMMENT 'Staff user_id',
  `last_reply_at`   DATETIME     DEFAULT NULL,
  `closed_at`       DATETIME     DEFAULT NULL,
  `created_at`      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      DATETIME     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_ticket_ref` (`reference`),
  KEY `idx_ticket_user` (`user_id`),
  KEY `idx_ticket_status` (`status`),
  KEY `idx_ticket_dept` (`department_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 8. SUPPORT TICKET REPLIES
-- ============================================================
CREATE TABLE IF NOT EXISTS `ticket_replies` (
  `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `ticket_id`  INT UNSIGNED NOT NULL,
  `user_id`    INT UNSIGNED DEFAULT NULL COMMENT 'NULL for guest replies',
  `is_staff`   TINYINT(1)   NOT NULL DEFAULT 0,
  `is_internal_note` TINYINT(1) NOT NULL DEFAULT 0 COMMENT '1 = internal note only staff can see',
  `body`       TEXT         NOT NULL,
  `attachment` VARCHAR(500) DEFAULT NULL,
  `created_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_reply_ticket` (`ticket_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 9. SEO / META PAGES
-- ============================================================
CREATE TABLE IF NOT EXISTS `seo_pages` (
  `id`           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `page_key`     VARCHAR(100) NOT NULL COMMENT 'Unique slug e.g. homepage, login, dashboard, news',
  `page_label`   VARCHAR(200) NOT NULL,
  `meta_title`   VARCHAR(300) DEFAULT NULL,
  `meta_desc`    TEXT         DEFAULT NULL,
  `meta_keywords` TEXT        DEFAULT NULL,
  `og_title`     VARCHAR(300) DEFAULT NULL,
  `og_desc`      TEXT         DEFAULT NULL,
  `og_image`     VARCHAR(500) DEFAULT NULL,
  `canonical_url` VARCHAR(500) DEFAULT NULL,
  `schema_json`  TEXT         DEFAULT NULL COMMENT 'JSON-LD schema markup',
  `admin_guide`  TEXT         DEFAULT NULL COMMENT 'Help text shown to admin on this page',
  `user_guide`   TEXT         DEFAULT NULL COMMENT 'Help text shown to users on this page',
  `updated_at`   DATETIME     DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_seo_key` (`page_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 10. NEWSLETTER GUEST SUBSCRIBERS
-- ============================================================
CREATE TABLE IF NOT EXISTS `newsletter_guests` (
  `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `email`      VARCHAR(150) NOT NULL,
  `whatsapp`   VARCHAR(30)  DEFAULT NULL,
  `status`     ENUM('subscribed','unsubscribed') NOT NULL DEFAULT 'subscribed',
  `token`      VARCHAR(80)  NOT NULL COMMENT 'Unsubscribe token',
  `consented_at` DATETIME   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_ng_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 11. CONDITIONAL PLAN PREREQUISITES
-- ============================================================
ALTER TABLE `plans`
  ADD COLUMN IF NOT EXISTS `requires_plan_ids` TEXT DEFAULT NULL COMMENT 'JSON array of plan IDs user must have deposited in' AFTER `sort_order`,
  ADD COLUMN IF NOT EXISTS `prereq_min_deposits` INT NOT NULL DEFAULT 0 COMMENT 'Minimum number of deposits in prerequisite plans' AFTER `requires_plan_ids`,
  ADD COLUMN IF NOT EXISTS `prereq_min_amount` DECIMAL(20,8) NOT NULL DEFAULT 0 COMMENT 'Minimum total deposited amount in prerequisite plans' AFTER `prereq_min_deposits`,
  ADD COLUMN IF NOT EXISTS `prereq_deposit_status` ENUM('any','active','completed') NOT NULL DEFAULT 'any' COMMENT 'Required status of prerequisite deposits' AFTER `prereq_min_amount`;

-- ============================================================
-- 12. SEED DEFAULT DATA
-- ============================================================

-- Seed team roles
INSERT IGNORE INTO `team_roles` (`name`, `label`, `is_system`, `sort_order`) VALUES
('founder',            'Founder',            1, 1),
('superadmin',         'Super Admin',        1, 2),
('ceo',                'CEO',                1, 3),
('security_manager',   'Security Manager',   1, 4),
('financial_manager',  'Financial Manager',  1, 5),
('support',            'Support',            1, 6),
('moderator',          'Moderator / Team Staff', 1, 7);

-- Seed permissions (grouped by module)
INSERT IGNORE INTO `permissions` (`name`, `label`, `module`, `sort_order`) VALUES
-- Dashboard & Overview
('dashboard.view',          'View Dashboard',             'dashboard',   1),
('dashboard.analytics',     'View Analytics',             'dashboard',   2),
-- Users
('users.view',              'View Users',                 'users',       10),
('users.edit',              'Edit Users',                 'users',       11),
('users.suspend',           'Suspend/Ban Users',          'users',       12),
('users.delete',            'Delete Users',               'users',       13),
('users.add_funds',         'Add Funds to Users',         'users',       14),
-- Finance
('finance.deposits.view',   'View Deposits',              'finance',     20),
('finance.deposits.approve','Approve/Reject Deposits',    'finance',     21),
('finance.withdrawals.view','View Withdrawals',           'finance',     22),
('finance.withdrawals.approve','Approve/Reject Withdrawals','finance',   23),
('finance.transactions.view','View Transactions',         'finance',     24),
('finance.earnings.view',   'View Earnings',              'finance',     25),
('finance.plans.manage',    'Manage Investment Plans',    'finance',     26),
('finance.exchange.manage', 'Manage Exchange Rates',      'finance',     27),
-- Security
('security.audit.view',     'View Audit Logs',            'security',    30),
('security.ip.manage',      'Manage IP Checks/Blacklist', 'security',    31),
('security.kyc.manage',     'Manage KYC',                 'security',    32),
('security.settings',       'Manage Security Settings',   'security',    33),
-- Content
('content.news.manage',     'Manage News',                'content',     40),
('content.faq.manage',      'Manage FAQ',                 'content',     41),
('content.pages.manage',    'Manage Custom Pages',        'content',     42),
('content.newsletter.send', 'Send Newsletter',            'content',     43),
('content.seo.manage',      'Manage SEO/Meta',            'content',     44),
-- Support
('support.tickets.view',    'View Support Tickets',       'support',     50),
('support.tickets.reply',   'Reply to Tickets',           'support',     51),
('support.notices.manage',  'Manage User Notices',        'support',     52),
-- Community
('community.posts.view',    'View Community Posts',       'community',   60),
('community.posts.delete',  'Delete Community Posts',     'community',   61),
('community.bots.manage',   'Manage Community Bots',      'community',   62),
-- Team
('team.roles.manage',       'Manage Team Roles',          'team',        70),
('team.members.manage',     'Manage Team Members',        'team',        71),
-- Settings
('settings.general',        'General Settings',           'settings',    80),
('settings.referral',       'Referral Settings',          'settings',    81),
('settings.currencies',     'Currency Settings',          'settings',    82);

-- Seed default ticket departments
INSERT IGNORE INTO `ticket_departments` (`name`, `slug`, `sort_order`) VALUES
('General Support',   'general',     1),
('Financial',         'financial',   2),
('Technical',         'technical',   3),
('Security',          'security',    4),
('KYC / Verification','kyc',         5),
('Partnership',       'partnership', 6);

-- Seed SEO page defaults
INSERT IGNORE INTO `seo_pages` (`page_key`, `page_label`) VALUES
('homepage',    'Homepage'),
('login',       'Login Page'),
('register',    'Register Page'),
('dashboard',   'User Dashboard'),
('news',        'News'),
('faq',         'FAQ'),
('plans',       'Investment Plans'),
('support',     'Support / Contact'),
('community',   'Community'),
('about',       'About Us');

SET FOREIGN_KEY_CHECKS = 1;
