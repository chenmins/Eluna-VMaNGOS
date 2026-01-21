-- Create table for persisting extra talent points
-- 创建用于持久化额外天赋点的表

-- Drop existing table if it exists / 如果表存在则删除
DROP TABLE IF EXISTS `character_extra_talent_points`;

-- Create the table / 创建表
CREATE TABLE `character_extra_talent_points` (
  `guid` INT(11) UNSIGNED NOT NULL COMMENT 'Character GUID / 角色GUID',
  `extra_points` INT(11) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Extra talent points / 额外天赋点',
  PRIMARY KEY (`guid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Stores extra talent points for characters / 存储角色的额外天赋点';

-- Note: This table must be created in your characters database
-- 注意：此表必须在您的 characters 数据库中创建

-- Example: 
-- USE characters;
-- SOURCE /path/to/character_extra_talent_points.sql;
