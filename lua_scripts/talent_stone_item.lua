--[[
    Talent Stone Item Script
    天赋石物品脚本
    
    This script demonstrates how to use a custom item to grant talent points to players.
    Replace ITEM_ENTRY_ID with the actual item ID you want to use as a talent stone.
    
    这个脚本演示如何使用自定义物品为玩家增加天赋点。
    将 ITEM_ENTRY_ID 替换为您想要用作天赋石的实际物品ID。
]]

-- Configuration / 配置
local ITEM_ENTRY_ID = 12345  -- Replace with your item ID / 替换为您的物品ID
local TALENT_POINTS_PER_USE = 1  -- Number of talent points to grant per use / 每次使用授予的天赋点数
local CONSUME_ITEM = true  -- Whether to consume the item when used / 是否在使用时消耗物品

-- Item use event handler / 物品使用事件处理器
local function OnUseTalentStone(event, player, item, target)
    -- Check if player is valid / 检查玩家是否有效
    if not player then
        return false
    end
    
    -- Get current extra talent points / 获取当前额外天赋点
    local currentExtra = player:GetExtraTalentPoints()
    
    -- Add talent points / 增加天赋点
    player:ModifyExtraTalentPoints(TALENT_POINTS_PER_USE)
    
    -- Get new extra talent points / 获取新的额外天赋点
    local newExtra = player:GetExtraTalentPoints()
    
    -- Send message to player / 向玩家发送消息
    player:SendBroadcastMessage(string.format(
        "You have gained %d talent point(s)! Total extra talent points: %d",
        TALENT_POINTS_PER_USE, newExtra
    ))
    player:SendBroadcastMessage(string.format(
        "你获得了 %d 个天赋点！总额外天赋点：%d",
        TALENT_POINTS_PER_USE, newExtra
    ))
    
    -- Play sound effect (optional) / 播放音效（可选）
    player:PlayDirectSound(8959) -- Level up sound / 升级音效
    
    -- Consume the item if configured / 如果配置了就消耗物品
    if CONSUME_ITEM then
        player:RemoveItem(item, 1)
    end
    
    -- Prevent default item behavior / 阻止默认物品行为
    return false
end

-- Register the item event / 注册物品事件
RegisterItemEvent(ITEM_ENTRY_ID, 2, OnUseTalentStone) -- 2 = ITEM_EVENT_ON_USE

print("Talent Stone script loaded for item ID: " .. ITEM_ENTRY_ID)
