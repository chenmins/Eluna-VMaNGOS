# 使用 Lua 动态开启区域 FFA PvP 的示例

你可以利用 Eluna 的区域更新事件在 Lua 脚本里给特定区域动态加上自由混战（FFA）和 PvP 标志，而不需要重新编译核心。

## 关键 API
- `PLAYER_EVENT_ON_UPDATE_AREA`（事件 ID 47）会在玩家区域发生变化时触发，回调参数包含旧区域 ID 与新区域 ID，适合做区域级别的开关逻辑。
- `Player:SetFFA(apply)`：直接调用核心的 `Player::SetPvPFreeForAll`，为玩家打开或关闭自由混战标志。
- `Unit:SetPvP(apply)`：为玩家（或任意 Unit）切换普通 PvP 标志，确保可以互相攻击。该方法由 `Unit` 绑定提供，玩家对象继承 `Unit`，因此可以直接用 `player:SetPvP(true/false)`（对应绑定在 `VMangos/UnitMethods.h` 中的 `LuaUnit::SetPvP`）。

## 示例脚本
把下面的脚本保存到服务器的 `lua_scripts` 目录（或你在 `mangosd.conf` 中配置的脚本目录）下，例如 `ffa_area_toggle.lua`。

```lua
-- 常量：区域更新事件 ID
local PLAYER_EVENT_ON_UPDATE_AREA = 47

-- 需要启用 FFA 的区域或子区域 ID 列表（AreaTable.dbc / area_table.sql 中的 AreaId）
local FFA_AREAS = {
    [33] = true,    -- 例：荆棘谷 Gurubashi Arena（更换成你的目标区域）
    [1234] = true,  -- 例：自定义区域 ID
}

local function OnAreaChanged(event, player, oldArea, newArea)
    local inFFA = FFA_AREAS[newArea]

    if inFFA then
        -- 进入指定区域：打开 FFA + PvP（如果核心暴露了 SetFFA）
        player:SetFFA(true)
        player:SetPvP(true)
        player:SendBroadcastMessage("你进入了自由混战区域！")
    elseif FFA_AREAS[oldArea] then
        -- 离开指定区域：关闭 FFA（若想保持 PvP 可移除下一行）
        player:SetFFA(false)
        player:SetPvP(false)
        player:SendBroadcastMessage("你已离开自由混战区域。")
    end
end

RegisterPlayerEvent(PLAYER_EVENT_ON_UPDATE_AREA, OnAreaChanged)
```

## 使用提示
1. **区域 ID 获取**：在客户端 `AreaTable.dbc` 或数据库 `area_table` 中查询目标区域/子区域的 ID，填入 `FFA_AREAS`。
2. **子区域优先**：优先使用子区域 ID，避免把整个大区（例如整张地图）都变成 FFA。
3. **与服务器配置的关系**：脚本只影响列表中的区域。若服务器整体开启了 FFA，则离开区域时不要调用 `SetPvP(false)`/`SetFFA(false)`，以免覆盖全局设置。
4. **调试**：可在脚本里打印 `oldArea`/`newArea` 或向玩家广播信息，确认事件已触发且区域 ID 正确。

按以上方式编写 Lua，重载 Eluna 或重启服务后即可让指定区域变成与古拉巴什竞技场类似的自由混战区。
