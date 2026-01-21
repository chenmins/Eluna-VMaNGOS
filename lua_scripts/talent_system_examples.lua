--[[
    Advanced Talent Point System Examples
    高级天赋点系统示例
    
    This file contains additional examples for granting talent points through
    various means: achievements, quests, and GM commands.
    
    此文件包含通过各种方式授予天赋点的其他示例：成就、任务和 GM 命令。
]]

-- ==============================================================================
-- Example 1: Achievement-based Talent Points / 基于成就的天赋点
-- ==============================================================================

--[[
    Configuration for achievement rewards
    成就奖励配置
]]
local ACHIEVEMENT_REWARDS = {
    [457] = 1,   -- Achievement ID 457 grants 1 talent point / 成就 ID 457 授予 1 个天赋点
    [458] = 2,   -- Achievement ID 458 grants 2 talent points / 成就 ID 458 授予 2 个天赋点
    [459] = 5,   -- Achievement ID 459 grants 5 talent points / 成就 ID 459 授予 5 个天赋点
}

--[[
    Track which achievements have already granted talent points
    跟踪哪些成就已经授予过天赋点
]]
local playerAchievementTalents = {}

local function OnAchievementComplete(event, player, achievement)
    local achievementId = achievement:GetId()
    local talentReward = ACHIEVEMENT_REWARDS[achievementId]
    
    if talentReward then
        -- Check if player already received this reward
        -- 检查玩家是否已经获得过这个奖励
        local playerGuid = player:GetGUIDLow()
        playerAchievementTalents[playerGuid] = playerAchievementTalents[playerGuid] or {}
        
        if not playerAchievementTalents[playerGuid][achievementId] then
            player:ModifyExtraTalentPoints(talentReward)
            player:SendBroadcastMessage(string.format(
                "|cff00ff00Achievement reward: %d talent point(s)!|r", talentReward
            ))
            player:SendBroadcastMessage(string.format(
                "|cff00ff00成就奖励：%d 个天赋点！|r", talentReward
            ))
            playerAchievementTalents[playerGuid][achievementId] = true
        end
    end
end

-- Register achievement event
-- 注册成就事件
-- NOTE: Achievement completion hooks are not available in VMangos classic (1.12).
--       This is an example for reference only. Use quest rewards or items instead.
-- 注意：VMangos classic (1.12) 中不支持成就完成钩子。
--       这只是一个参考示例。请改用任务奖励或物品。
-- If your server version supports achievements:
-- 如果您的服务器版本支持成就：
-- RegisterPlayerEvent(8, OnAchievementComplete)  -- 8 = PLAYER_EVENT_ON_ACHIEVEMENT_COMPLETE

-- ==============================================================================
-- Example 2: Quest-based Talent Points / 基于任务的天赋点
-- ==============================================================================

--[[
    Configuration for quest rewards
    任务奖励配置
]]
local QUEST_TALENT_REWARDS = {
    [1000] = 1,   -- Quest ID 1000 grants 1 talent point / 任务 ID 1000 授予 1 个天赋点
    [1001] = 2,   -- Quest ID 1001 grants 2 talent points / 任务 ID 1001 授予 2 个天赋点
    [1002] = 3,   -- Quest ID 1002 grants 3 talent points / 任务 ID 1002 授予 3 个天赋点
}

local function OnQuestComplete(event, player, quest)
    local questId = quest:GetId()
    local talentReward = QUEST_TALENT_REWARDS[questId]
    
    if talentReward then
        player:ModifyExtraTalentPoints(talentReward)
        player:SendBroadcastMessage(string.format(
            "|cff00ff00Quest reward: %d talent point(s)!|r", talentReward
        ))
        player:SendBroadcastMessage(string.format(
            "|cff00ff00任务奖励：%d 个天赋点！|r", talentReward
        ))
        player:PlayDirectSound(8959) -- Level up sound / 升级音效
    end
end

-- Register quest complete event (event 6 = PLAYER_EVENT_ON_QUEST_COMPLETE)
-- 注册任务完成事件
RegisterPlayerEvent(6, OnQuestComplete)

-- ==============================================================================
-- Example 3: GM NPC for Managing Talent Points / GM NPC 管理天赋点
-- ==============================================================================

--[[
    NOTE: Custom `.command` style GM commands do NOT work in VMangos through Eluna.
    VMangos does not integrate Eluna's command system like TrinityCore does.
    
    注意：在 VMangos 中，通过 Eluna 无法实现自定义的 `.command` 风格 GM 命令。
    VMangos 不像 TrinityCore 那样集成 Eluna 的命令系统。
    
    Instead, use one of these alternatives:
    建议使用以下替代方案：
    
    1. Items - Use talent stone items (see talent_stone_item.lua)
       物品 - 使用天赋石物品（见 talent_stone_item.lua）
    
    2. NPC Gossip - Create an NPC that GMs can use to manage talent points
       NPC 对话 - 创建一个 NPC，GM 可以用它来管理天赋点
    
    3. C++ Commands - Add a native C++ command to the server (requires server modification)
       C++ 命令 - 向服务器添加原生 C++ 命令（需要修改服务器）
    
    Below is an example using NPC Gossip:
    下面是使用 NPC 对话的示例：
]]

local TALENT_MANAGER_NPC = 90000  -- Replace with your NPC entry ID / 替换为您的 NPC ID

local function TalentManagerGossipHello(event, player, creature)
    player:GossipClearMenu()
    player:GossipMenuAddItem(0, "Check Extra Talent Points / 查看额外天赋点", 0, 1)
    player:GossipMenuAddItem(0, "Add 1 Talent Point / 添加 1 个天赋点", 0, 2)
    player:GossipMenuAddItem(0, "Add 5 Talent Points / 添加 5 个天赋点", 0, 3)
    player:GossipMenuAddItem(0, "Add 10 Talent Points / 添加 10 个天赋点", 0, 4)
    player:GossipMenuAddItem(0, "Remove 1 Talent Point / 移除 1 个天赋点", 0, 5)
    player:GossipMenuAddItem(0, "Remove All Extra Points / 移除所有额外点数", 0, 6)
    player:GossipSendMenu(1, creature)
end

local function TalentManagerGossipSelect(event, player, creature, sender, action)
    if action == 1 then
        -- Check points / 查看点数
        local current = player:GetExtraTalentPoints()
        player:SendBroadcastMessage(string.format("Extra Talent Points: %d / 额外天赋点：%d", current, current))
        player:GossipComplete()
        
    elseif action == 2 then
        -- Add 1 / 添加 1
        player:ModifyExtraTalentPoints(1)
        player:SendBroadcastMessage("Added 1 talent point / 添加了 1 个天赋点")
        player:GossipComplete()
        
    elseif action == 3 then
        -- Add 5 / 添加 5
        player:ModifyExtraTalentPoints(5)
        player:SendBroadcastMessage("Added 5 talent points / 添加了 5 个天赋点")
        player:GossipComplete()
        
    elseif action == 4 then
        -- Add 10 / 添加 10
        player:ModifyExtraTalentPoints(10)
        player:SendBroadcastMessage("Added 10 talent points / 添加了 10 个天赋点")
        player:GossipComplete()
        
    elseif action == 5 then
        -- Remove 1 / 移除 1
        player:ModifyExtraTalentPoints(-1)
        player:SendBroadcastMessage("Removed 1 talent point / 移除了 1 个天赋点")
        player:GossipComplete()
        
    elseif action == 6 then
        -- Remove all / 移除所有
        player:SetExtraTalentPoints(0)
        player:SendBroadcastMessage("Removed all extra talent points / 移除了所有额外天赋点")
        player:GossipComplete()
    end
end

-- Register NPC gossip events (only uncomment if you create the NPC)
-- 注册 NPC 对话事件（仅在创建 NPC 后取消注释）
-- RegisterCreatureGossipEvent(TALENT_MANAGER_NPC, 1, TalentManagerGossipHello)
-- RegisterCreatureGossipEvent(TALENT_MANAGER_NPC, 2, TalentManagerGossipSelect)

-- ==============================================================================
-- Example 4: Level-based Bonus Talent Points / 基于等级的额外天赋点
-- ==============================================================================

--[[
    Grant bonus talent points at specific levels
    在特定等级授予额外天赋点
]]
local LEVEL_TALENT_BONUSES = {
    [10] = 1,   -- 1 bonus point at level 10 / 10级时获得1个额外点数
    [20] = 1,   -- 1 bonus point at level 20 / 20级时获得1个额外点数
    [30] = 2,   -- 2 bonus points at level 30 / 30级时获得2个额外点数
    [40] = 2,   -- 2 bonus points at level 40 / 40级时获得2个额外点数
    [50] = 3,   -- 3 bonus points at level 50 / 50级时获得3个额外点数
    [60] = 5,   -- 5 bonus points at level 60 / 60级时获得5个额外点数
}

local playerLevelBonusGiven = {}

local function OnLevelUp(event, player, oldLevel)
    local newLevel = player:GetLevel()
    local bonusPoints = LEVEL_TALENT_BONUSES[newLevel]
    
    if bonusPoints then
        local playerGuid = player:GetGUIDLow()
        playerLevelBonusGiven[playerGuid] = playerLevelBonusGiven[playerGuid] or {}
        
        if not playerLevelBonusGiven[playerGuid][newLevel] then
            player:ModifyExtraTalentPoints(bonusPoints)
            player:SendBroadcastMessage(string.format(
                "|cffff8000Level %d bonus: %d talent point(s)!|r", newLevel, bonusPoints
            ))
            player:SendBroadcastMessage(string.format(
                "|cffff8000%d级奖励：%d 个天赋点！|r", newLevel, bonusPoints
            ))
            playerLevelBonusGiven[playerGuid][newLevel] = true
        end
    end
end

-- Register level up event (event 13 = PLAYER_EVENT_ON_LEVEL_CHANGE)
-- 注册升级事件
RegisterPlayerEvent(13, OnLevelUp)

print("Advanced talent point system examples loaded successfully!")
print("高级天赋点系统示例加载成功！")
