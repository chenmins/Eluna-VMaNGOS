DROP PROCEDURE IF EXISTS add_migration;
delimiter ??
CREATE PROCEDURE `add_migration`()
BEGIN
DECLARE v INT DEFAULT 1;
SET v = (SELECT COUNT(*) FROM `migrations` WHERE `id`='20240701010101');
IF v=0 THEN
INSERT INTO `migrations` VALUES ('20240701010101');
-- Add your query below.


ALTER TABLE `item_instance`
    ADD COLUMN `trade_expire` BIGINT(20) UNSIGNED NOT NULL DEFAULT '0' AFTER `generated_loot`,
    ADD COLUMN `trade_participants` TEXT NULL AFTER `trade_expire`;


END IF;
END??
delimiter ;
CALL add_migration();
DROP PROCEDURE IF EXISTS add_migration;
