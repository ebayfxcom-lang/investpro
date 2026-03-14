-- Migration 014: Allow NULL user_id for bot/admin community posts and fix schema gaps
-- Safe to run on any database state 001–013.
-- Resolves: SQLSTATE[23000] user_id cannot be null in community_posts/comments.

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- Helper: _m014_add_col – idempotent column addition (MySQL 8+)
-- ============================================================
DROP PROCEDURE IF EXISTS `_m014_add_col`;
DELIMITER //
CREATE PROCEDURE `_m014_add_col`(
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
-- 1. community_posts: make user_id nullable so admin/bot posts
--    don't require a real user record; add admin_id for audit.
--    bot_id tracks which bot profile authored the post.
-- ============================================================

-- Change user_id from NOT NULL to nullable
DROP PROCEDURE IF EXISTS `_m014_alter_col`;
DELIMITER //
CREATE PROCEDURE `_m014_alter_col`(
    IN p_tbl  VARCHAR(100),
    IN p_col  VARCHAR(100),
    IN p_def  TEXT
)
BEGIN
    DECLARE v_not_null INT DEFAULT 0;
    SELECT COUNT(*) INTO v_not_null
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME   = p_tbl
      AND COLUMN_NAME  = p_col
      AND IS_NULLABLE  = 'NO';
    IF v_not_null > 0 THEN
        SET @_sql = CONCAT('ALTER TABLE `', p_tbl, '` MODIFY COLUMN `', p_col, '` ', p_def);
        PREPARE _ps FROM @_sql;
        EXECUTE _ps;
        DEALLOCATE PREPARE _ps;
    END IF;
END //
DELIMITER ;

CALL `_m014_alter_col`('community_posts',    'user_id', 'INT UNSIGNED DEFAULT NULL');
CALL `_m014_alter_col`('community_comments', 'user_id', 'INT UNSIGNED DEFAULT NULL');
CALL `_m014_alter_col`('community_likes',    'user_id', 'INT UNSIGNED DEFAULT NULL');

-- Add admin_id column so admin-authored posts are tracked without needing a user record
CALL `_m014_add_col`('community_posts', 'admin_id', 'INT UNSIGNED DEFAULT NULL AFTER `bot_id`');

-- ============================================================
-- 2. bot_profiles: ensure user_id column exists so a bot can
--    optionally be linked to a system user account in future.
-- ============================================================
CALL `_m014_add_col`('bot_profiles', 'user_id', 'INT UNSIGNED DEFAULT NULL COMMENT ''Optional linked system user''');

-- ============================================================
-- 3. spin_rewards: ensure color and spin_mode columns exist
--    (needed by SpinRewardModel queries)
-- ============================================================
CALL `_m014_add_col`('spin_rewards', 'color',     'VARCHAR(20) NOT NULL DEFAULT ''#6366f1''');
CALL `_m014_add_col`('spin_rewards', 'spin_mode', 'ENUM(''free'',''paid'',''both'') NOT NULL DEFAULT ''both''');

-- Remove 'points' type spin rewards as points are not used in the system
UPDATE `spin_rewards` SET `status` = 'inactive' WHERE `reward_type` = 'points';

-- ============================================================
-- 4. users: ensure preferred_currency column exists
-- ============================================================
CALL `_m014_add_col`('users', 'preferred_currency', 'VARCHAR(10) NOT NULL DEFAULT ''USD''');

-- ============================================================
-- Cleanup helper procedures
-- ============================================================
DROP PROCEDURE IF EXISTS `_m014_add_col`;
DROP PROCEDURE IF EXISTS `_m014_alter_col`;

SET FOREIGN_KEY_CHECKS = 1;
