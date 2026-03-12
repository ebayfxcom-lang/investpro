-- Migration 008: Fix withdrawal memo column and withdrawal method default status
--   1. Add missing `memo` column to `withdrawals` table (fixes 500 error on submit)
--   2. Set auto-seeded withdrawal methods (IDs 1–5) to inactive by default,
--      so admins must explicitly enable each method before it appears to users

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- 1. WITHDRAWALS: add memo/tag column (was missing, causing 500 on submit)
-- ============================================================
ALTER TABLE `withdrawals`
  ADD COLUMN IF NOT EXISTS `memo` VARCHAR(100) DEFAULT NULL
    COMMENT 'Memo/tag required by some networks (e.g. XRP, Stellar)' AFTER `address`;

-- ============================================================
-- 2. WITHDRAWAL METHODS: set seeded methods to inactive by default
--    so they only appear to users after the admin explicitly enables them
-- ============================================================
UPDATE `withdrawal_methods`
SET `status` = 'inactive'
WHERE `id` IN (1, 2, 3, 4, 5)
  AND `status` = 'active';

SET FOREIGN_KEY_CHECKS = 1;
