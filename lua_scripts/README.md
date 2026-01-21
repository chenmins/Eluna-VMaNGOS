# 天赋石 (Talent Stone) System / 天赋石系统

## English

### Overview
This feature allows server administrators to create custom items that grant additional talent points to players. The system is implemented using Eluna scripting and provides flexible control over talent point distribution.

### Installation

1. **Apply C++ changes**: The core changes have been made to:
   - `src/game/Objects/Player.h` - Added extra talent points storage
   - `src/game/Objects/Player.cpp` - Modified talent calculation
   - `src/modules/Eluna/methods/VMangos/PlayerMethods.h` - Added Eluna API

2. **Compile the server**: Build your VMangos server as usual with CMake.

3. **Deploy Lua scripts**: 
   - Copy the `lua_scripts` folder to your server's root directory
   - Edit `mangosd.conf` and set: `Eluna.ScriptPath = "lua_scripts"`

4. **Create database table for persistence**:
   - Execute `lua_scripts/character_extra_talent_points.sql` in your **characters** database
   - This table stores extra talent points so they persist across server restarts
   ```bash
   mysql -u root -p characters < lua_scripts/character_extra_talent_points.sql
   ```

5. **Create items**: 
   - Execute `lua_scripts/talent_stone_items.sql` in your world database
   - This creates sample talent stone items with IDs 12345-12348

6. **Configure scripts**:
   - Edit `lua_scripts/talent_stone_item.lua` 
   - Set `ITEM_ENTRY_ID` to your desired item ID
   - Adjust `TALENT_POINTS_PER_USE` as needed

6. **Restart server**: Launch your server and test!

For detailed testing instructions, see `lua_scripts/TESTING.md`.

### How It Works
1. **Extra Talent Points Storage**: Each player has an `m_extraTalentPoints` field that stores bonus talent points from items, achievements, or other sources.
2. **Talent Calculation**: The `CalculateTalentsPoints()` function now includes extra talent points in the total calculation.
3. **Persistence**: Extra talent points are saved to the `character_extra_talent_points` table in the characters database.
4. **Eluna API**: Three new methods are available:
   - `GetExtraTalentPoints()`: Returns the current extra talent points
   - `SetExtraTalentPoints(points)`: Sets the extra talent points to a specific value
   - `ModifyExtraTalentPoints(points)`: Adds or removes extra talent points (positive to add, negative to remove)

### Usage Example

#### Creating a Talent Stone Item
1. Create or choose an item in your world database to use as a talent stone
2. Edit `lua_scripts/talent_stone_item.lua` and set the `ITEM_ENTRY_ID` to your item's ID
3. Configure the number of talent points granted per use with `TALENT_POINTS_PER_USE`
4. Set whether the item should be consumed with `CONSUME_ITEM`
5. Restart your server or reload Eluna scripts

#### Lua Script Example
```lua
-- Grant 1 talent point when using item ID 12345
local ITEM_ENTRY_ID = 12345
local TALENT_POINTS_PER_USE = 1

local function OnUseTalentStone(event, player, item, target)
    player:ModifyExtraTalentPoints(TALENT_POINTS_PER_USE)
    player:SendBroadcastMessage("You gained a talent point!")
    player:RemoveItem(item, 1)  -- Consume the item
    return false
end

RegisterItemEvent(ITEM_ENTRY_ID, 2, OnUseTalentStone)
```

#### Advanced Usage
You can also grant talent points through other means:
- Achievement rewards
- Quest rewards
- GM commands
- Special events

Example for quest reward:
```lua
local function OnQuestComplete(event, player, quest)
    if quest:GetId() == 12345 then  -- Your quest ID
        player:ModifyExtraTalentPoints(5)  -- Grant 5 talent points
        player:SendBroadcastMessage("Quest reward: 5 talent points!")
    end
end

RegisterPlayerEvent(6, OnQuestComplete)  -- 6 = PLAYER_EVENT_ON_QUEST_COMPLETE
```

### API Reference

#### Player Methods

##### GetExtraTalentPoints()
Returns the current number of extra talent points.
```lua
local extraPoints = player:GetExtraTalentPoints()
```

##### SetExtraTalentPoints(points)
Sets the extra talent points to a specific value.
```lua
player:SetExtraTalentPoints(10)  -- Set to exactly 10 extra points
```

##### ModifyExtraTalentPoints(points)
Adds or removes extra talent points.
```lua
player:ModifyExtraTalentPoints(5)   -- Add 5 points
player:ModifyExtraTalentPoints(-3)  -- Remove 3 points
```

---

## 中文

### 概述
此功能允许服务器管理员创建可以为玩家授予额外天赋点的自定义物品。该系统使用 Eluna 脚本实现，提供了灵活的天赋点分配控制。

### 安装步骤

1. **应用 C++ 更改**：核心更改已应用于：
   - `src/game/Objects/Player.h` - 添加了额外天赋点存储
   - `src/game/Objects/Player.cpp` - 修改了天赋计算
   - `src/modules/Eluna/methods/VMangos/PlayerMethods.h` - 添加了 Eluna API

2. **编译服务器**：使用 CMake 照常构建您的 VMangos 服务器。

3. **部署 Lua 脚本**：
   - 将 `lua_scripts` 文件夹复制到服务器根目录
   - 编辑 `mangosd.conf` 并设置：`Eluna.ScriptPath = "lua_scripts"`

4. **创建物品**：
   - 在世界数据库中执行 `lua_scripts/talent_stone_items.sql`
   - 这将创建 ID 为 12345-12348 的示例天赋石物品

5. **配置脚本**：
   - 编辑 `lua_scripts/talent_stone_item.lua`
   - 将 `ITEM_ENTRY_ID` 设置为您想要的物品 ID
   - 根据需要调整 `TALENT_POINTS_PER_USE`

6. **重启服务器**：启动服务器并测试！

详细的测试说明请参阅 `lua_scripts/TESTING.md`。

### 工作原理
1. **额外天赋点存储**：每个玩家都有一个 `m_extraTalentPoints` 字段，用于存储来自物品、成就或其他来源的额外天赋点。
2. **天赋计算**：`CalculateTalentsPoints()` 函数现在会在总计算中包含额外天赋点。
3. **Eluna API**：提供三个新方法：
   - `GetExtraTalentPoints()`：返回当前额外天赋点
   - `SetExtraTalentPoints(points)`：将额外天赋点设置为特定值
   - `ModifyExtraTalentPoints(points)`：添加或移除额外天赋点（正数添加，负数移除）

### 使用示例

#### 创建天赋石物品
1. 在您的世界数据库中创建或选择一个物品作为天赋石
2. 编辑 `lua_scripts/talent_stone_item.lua` 并将 `ITEM_ENTRY_ID` 设置为您的物品ID
3. 使用 `TALENT_POINTS_PER_USE` 配置每次使用授予的天赋点数
4. 使用 `CONSUME_ITEM` 设置物品是否被消耗
5. 重启服务器或重新加载 Eluna 脚本

#### Lua 脚本示例
```lua
-- 使用物品ID 12345时授予1个天赋点
local ITEM_ENTRY_ID = 12345
local TALENT_POINTS_PER_USE = 1

local function OnUseTalentStone(event, player, item, target)
    player:ModifyExtraTalentPoints(TALENT_POINTS_PER_USE)
    player:SendBroadcastMessage("你获得了一个天赋点！")
    player:RemoveItem(item, 1)  -- 消耗物品
    return false
end

RegisterItemEvent(ITEM_ENTRY_ID, 2, OnUseTalentStone)
```

#### 高级用法
您还可以通过其他方式授予天赋点：
- 成就奖励
- 任务奖励
- GM命令
- 特殊事件

任务奖励示例：
```lua
local function OnQuestComplete(event, player, quest)
    if quest:GetId() == 12345 then  -- 您的任务ID
        player:ModifyExtraTalentPoints(5)  -- 授予5个天赋点
        player:SendBroadcastMessage("任务奖励：5个天赋点！")
    end
end

RegisterPlayerEvent(6, OnQuestComplete)  -- 6 = PLAYER_EVENT_ON_QUEST_COMPLETE
```

### API 参考

#### 玩家方法

##### GetExtraTalentPoints()
返回当前额外天赋点数。
```lua
local extraPoints = player:GetExtraTalentPoints()
```

##### SetExtraTalentPoints(points)
将额外天赋点设置为特定值。
```lua
player:SetExtraTalentPoints(10)  -- 设置为正好10个额外点数
```

##### ModifyExtraTalentPoints(points)
添加或移除额外天赋点。
```lua
player:ModifyExtraTalentPoints(5)   -- 添加5点
player:ModifyExtraTalentPoints(-3)  -- 移除3点
```

### 注意事项
- 额外天赋点会在玩家天赋计算中自动包含
- 天赋点数不能为负数，`ModifyExtraTalentPoints` 会自动处理
- 修改天赋点后会自动更新玩家的天赋界面
- 服务器重启后天赋点数据需要持久化（建议添加到玩家保存数据中）
