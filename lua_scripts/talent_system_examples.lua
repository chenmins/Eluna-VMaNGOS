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
-- Example 3: GM Command for Talent Points / GM 命令授予天赋点
-- ==============================================================================

local function HandleTalentPointCommand(event, player, command)
    -- Command format: .talentpoints <add|remove|set|get> [amount]
    -- 命令格式：.talentpoints <add|remove|set|get> [数量]
    
    local parts = {}
    for word in command:gmatch("%S+") do
        table.insert(parts, word)
    end
    
    if parts[1] ~= "talentpoints" then
        return true  -- Not our command, pass to next handler
    end
    
    local action = parts[2]
    local amount = tonumber(parts[3]) or 0
    
    if action == "get" then
        local current = player:GetExtraTalentPoints()
        player:SendBroadcastMessage(string.format(
            "Extra talent points: %d", current
        ))
        player:SendBroadcastMessage(string.format(
            "额外天赋点：%d", current
        ))
        
    elseif action == "add" and amount > 0 then
        player:ModifyExtraTalentPoints(amount)
        player:SendBroadcastMessage(string.format(
            "Added %d talent point(s)", amount
        ))
        player:SendBroadcastMessage(string.format(
            "添加了 %d 个天赋点", amount
        ))
        
    elseif action == "remove" and amount > 0 then
        player:ModifyExtraTalentPoints(-amount)
        player:SendBroadcastMessage(string.format(
            "Removed %d talent point(s)", amount
        ))
        player:SendBroadcastMessage(string.format(
            "移除了 %d 个天赋点", amount
        ))
        
    elseif action == "set" and amount >= 0 then
        player:SetExtraTalentPoints(amount)
        player:SendBroadcastMessage(string.format(
            "Set extra talent points to %d", amount
        ))
        player:SendBroadcastMessage(string.format(
            "设置额外天赋点为 %d", amount
        ))
        
    else
        player:SendBroadcastMessage("Usage: .talentpoints <add|remove|set|get> [amount]")
        player:SendBroadcastMessage("用法：.talentpoints <add|remove|set|get> [数量]")
    end
    
    return false  -- Command handled, don't pass to next handler
end

-- Register command event (event 42 = PLAYER_EVENT_ON_COMMAND)
-- 注册命令事件
RegisterPlayerEvent(42, HandleTalentPointCommand)

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
