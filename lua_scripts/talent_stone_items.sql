-- Talent Stone Item Template
-- 天赋石物品模板
-- 
-- This SQL creates a sample talent stone item that can be used to grant talent points.
-- Adjust the values as needed for your server.
-- 
-- 此 SQL 创建一个示例天赋石物品，可用于授予天赋点。
-- 根据您的服务器需要调整值。

-- Delete existing item if it exists / 如果存在则删除现有物品
DELETE FROM item_template WHERE entry = 12345;

-- Create the talent stone item / 创建天赋石物品
INSERT INTO item_template (
    entry,              -- Item ID / 物品 ID
    class,              -- Item class (0 = Consumable) / 物品类别（0 = 消耗品）
    subclass,           -- Item subclass (8 = Other) / 物品子类别（8 = 其他）
    name,               -- Item name / 物品名称
    displayid,          -- Display model ID / 显示模型 ID
    Quality,            -- Quality (0=Poor, 1=Common, 2=Uncommon, 3=Rare, 4=Epic, 5=Legendary)
    Flags,              -- Item flags / 物品标志
    BuyPrice,           -- Buy price in copper / 购买价格（铜币）
    SellPrice,          -- Sell price in copper / 出售价格（铜币）
    InventoryType,      -- Inventory slot type (0 = Non-equip) / 背包槽类型（0 = 不装备）
    AllowableClass,     -- Class restriction (-1 = All classes) / 职业限制（-1 = 所有职业）
    AllowableRace,      -- Race restriction (-1 = All races) / 种族限制（-1 = 所有种族）
    ItemLevel,          -- Item level / 物品等级
    RequiredLevel,      -- Required level to use / 使用所需等级
    maxcount,           -- Max stack in inventory / 背包中最大堆叠数
    stackable,          -- How many can stack / 可堆叠数量
    Material            -- Material type (-1 = Consumables) / 材质类型（-1 = 消耗品）
) VALUES (
    12345,              -- Change this to an unused item ID / 更改为未使用的物品 ID
    0,                  -- Consumable
    8,                  -- Other
    'Talent Stone',     -- English name / 英文名称
    6418,               -- Blue glowing stone model / 蓝色发光石头模型
    4,                  -- Epic quality (purple) / 史诗品质（紫色）
    0,                  -- No special flags
    10000,              -- 1 gold to buy / 1金购买
    2500,               -- 25 silver to sell / 25银出售
    0,                  -- Non-equip
    -1,                 -- All classes / 所有职业
    -1,                 -- All races / 所有种族
    1,                  -- Item level 1
    1,                  -- Required level 1
    20,                 -- Max 20 in inventory / 背包中最多 20 个
    1,                  -- Stackable / 可堆叠
    -1                  -- Consumable material / 消耗品材质
);

-- Optional: Add item description / 可选：添加物品描述
-- Note: The description field name may vary depending on your database version
-- 注意：描述字段名称可能因数据库版本而异

-- For some database versions / 对于某些数据库版本:
-- UPDATE item_template SET description = 'Grants one talent point when used. / 使用时授予一个天赋点。' WHERE entry = 12345;

-- Optional: Make the item soulbound / 可选：使物品绑定
-- UPDATE item_template SET bonding = 1 WHERE entry = 12345;  -- 1 = Binds when picked up / 拾取绑定

-- Optional: Add Chinese name / 可选：添加中文名称
-- UPDATE item_template SET name = '天赋石' WHERE entry = 12345;

-- ================================================================================
-- Additional Talent Stone Variants / 额外的天赋石变体
-- ================================================================================

-- Lesser Talent Stone (Green quality, 1 point) / 次级天赋石（绿色品质，1点）
DELETE FROM item_template WHERE entry = 12346;
INSERT INTO item_template (entry, class, subclass, name, displayid, Quality, Flags, BuyPrice, SellPrice, InventoryType, AllowableClass, AllowableRace, ItemLevel, RequiredLevel, maxcount, stackable, Material)
VALUES (12346, 0, 8, 'Lesser Talent Stone', 6417, 2, 0, 5000, 1250, 0, -1, -1, 1, 1, 20, 1, -1);

-- Greater Talent Stone (Epic quality, 3 points) / 高级天赋石（史诗品质，3点）
DELETE FROM item_template WHERE entry = 12347;
INSERT INTO item_template (entry, class, subclass, name, displayid, Quality, Flags, BuyPrice, SellPrice, InventoryType, AllowableClass, AllowableRace, ItemLevel, RequiredLevel, maxcount, stackable, Material)
VALUES (12347, 0, 8, 'Greater Talent Stone', 6419, 4, 0, 30000, 7500, 0, -1, -1, 1, 1, 20, 1, -1);

-- Supreme Talent Stone (Legendary quality, 5 points) / 至高天赋石（传说品质，5点）
DELETE FROM item_template WHERE entry = 12348;
INSERT INTO item_template (entry, class, subclass, name, displayid, Quality, Flags, BuyPrice, SellPrice, InventoryType, AllowableClass, AllowableRace, ItemLevel, RequiredLevel, maxcount, stackable, Material)
VALUES (12348, 0, 8, 'Supreme Talent Stone', 6418, 5, 0, 100000, 25000, 0, -1, -1, 1, 1, 20, 1, -1);

-- ================================================================================
-- To use these items in-game / 在游戏中使用这些物品:
-- ================================================================================
-- 
-- 1. Execute this SQL in your world database / 在世界数据库中执行此 SQL
-- 2. Update the ITEM_ENTRY_ID in talent_stone_item.lua to match / 更新 talent_stone_item.lua 中的 ITEM_ENTRY_ID 以匹配
-- 3. Restart your server or reload scripts / 重启服务器或重新加载脚本
-- 4. In-game, use: .additem 12345 [count] / 游戏中使用：.additem 12345 [数量]
-- 
-- For different point amounts, create multiple Lua handlers or use a single handler
-- that checks the item ID and grants different amounts accordingly.
-- 
-- 对于不同的点数，创建多个 Lua 处理程序或使用一个处理程序
-- 检查物品 ID 并相应地授予不同的数量。
