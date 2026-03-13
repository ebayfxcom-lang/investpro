-- Migration 012: Keyword moderation, community enhancements, bot support
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- Restricted keywords table
CREATE TABLE IF NOT EXISTS `restricted_keywords` (
  `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `keyword`    VARCHAR(200) NOT NULL,
  `created_by` INT UNSIGNED DEFAULT NULL,
  `created_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_keyword` (`keyword`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add bot_id column to community_posts (for bot-authored posts)
-- Uses helper procedure pattern if available
DROP PROCEDURE IF EXISTS `_m012_add_col`;
DELIMITER //
CREATE PROCEDURE `_m012_add_col`(IN p_tbl VARCHAR(100), IN p_col VARCHAR(100), IN p_def TEXT)
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = p_tbl AND COLUMN_NAME = p_col
  ) THEN
    SET @_s = CONCAT('ALTER TABLE `', p_tbl, '` ADD COLUMN `', p_col, '` ', p_def);
    PREPARE _ps FROM @_s;
    EXECUTE _ps;
    DEALLOCATE PREPARE _ps;
  END IF;
END //
DELIMITER ;

CALL `_m012_add_col`('community_posts', 'bot_id', 'INT UNSIGNED DEFAULT NULL AFTER `user_id`');
CALL `_m012_add_col`('community_comments', 'bot_id', 'INT UNSIGNED DEFAULT NULL AFTER `user_id`');
CALL `_m012_add_col`('community_likes', 'bot_id', 'INT UNSIGNED DEFAULT NULL AFTER `user_id`');
CALL `_m012_add_col`('community_posts', 'is_featured', 'TINYINT(1) NOT NULL DEFAULT 0 AFTER `is_bot`');
CALL `_m012_add_col`('community_posts', 'is_hidden', 'TINYINT(1) NOT NULL DEFAULT 0 AFTER `is_featured`');
CALL `_m012_add_col`('withdrawals', 'proof_image', 'VARCHAR(255) DEFAULT NULL AFTER `status`');
CALL `_m012_add_col`('support_tickets', 'department_id', 'INT UNSIGNED DEFAULT NULL AFTER `user_id`');

DROP PROCEDURE IF EXISTS `_m012_add_col`;

SET FOREIGN_KEY_CHECKS = 1;
