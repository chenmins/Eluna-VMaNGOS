# Testing Guide for Talent Stone System
# 天赋石系统测试指南

## Prerequisites / 前提条件

1. VMangos server with Eluna support / 支持 Eluna 的 VMangos 服务器
2. Access to the world database / 可以访问世界数据库
3. GM account for testing / 用于测试的 GM 账号

## Setup / 设置

### 1. Create a Test Item / 创建测试物品

Execute this SQL in your world database:

在您的世界数据库中执行此 SQL：

```sql
-- Create a talent stone item
-- 创建天赋石物品
INSERT INTO item_template (entry, class, subclass, name, displayid, Quality, Flags, BuyPrice, SellPrice, InventoryType, AllowableClass, AllowableRace, ItemLevel, RequiredLevel, maxcount, stackable, Material, delay, spellid_1, spelltrigger_1, spellcharges_1)
VALUES (12345, 0, 8, 'Talent Stone', 6418, 4, 0, 10000, 2500, 0, -1, -1, 1, 1, 20, 1, -1, 0, 0, 0, 0);

-- Chinese version / 中文版本
-- UPDATE item_template SET name = '天赋石' WHERE entry = 12345;
```

### 2. Deploy Lua Scripts / 部署 Lua 脚本

1. Copy the lua_scripts folder to your server's root directory
2. Edit `mangosd.conf` and set the Eluna script path:
   ```
   Eluna.ScriptPath = "lua_scripts"
   ```
3. **Create the database table for persistence** / 创建持久化数据库表
   ```bash
   mysql -u root -p characters < lua_scripts/character_extra_talent_points.sql
   ```
4. Restart your server / 重启服务器

将 lua_scripts 文件夹复制到服务器根目录
编辑 `mangosd.conf` 并设置 Eluna 脚本路径
重启服务器

### 3. Configure the Item ID / 配置物品 ID

Edit `lua_scripts/talent_stone_item.lua` and set:
编辑 `lua_scripts/talent_stone_item.lua` 并设置：

```lua
local ITEM_ENTRY_ID = 12345  -- Your item ID / 您的物品 ID
```

## Test Cases / 测试用例

### Test 1: Basic Item Usage / 基本物品使用

**Steps / 步骤:**

1. Log in with a level 10+ character / 使用 10 级以上的角色登录
2. Give yourself the talent stone:
   ```
   .additem 12345 5
   ```
3. Open your talent window and note the current free talent points
   打开天赋窗口并记录当前的可用天赋点
4. Use the talent stone item from your inventory
   从背包中使用天赋石物品
5. Check your talent window again
   再次检查天赋窗口

**Expected Result / 预期结果:**
- You should see a message: "You have gained 1 talent point(s)!"
  应该看到消息："你获得了 1 个天赋点！"
- Your talent window should show one additional free point
  天赋窗口应该显示增加了一个可用点数
- The item should be consumed (removed from inventory)
  物品应该被消耗（从背包中移除）

### Test 2: Multiple Uses / 多次使用

**Steps / 步骤:**

1. Use 3 talent stones in succession / 连续使用 3 个天赋石
2. Check your total extra talent points / 检查总额外天赋点

**Expected Result / 预期结果:**
- You should gain 3 talent points total
  应该总共获得 3 个天赋点
- Each use should display the cumulative total
  每次使用都应该显示累计总数

### Test 3: GM Commands / GM 命令

**Steps / 步骤:**

Test the talent point commands:
测试天赋点命令：

```
.talentpoints get          # Check current extra points / 检查当前额外点数
.talentpoints add 5        # Add 5 points / 添加 5 点
.talentpoints get          # Verify addition / 验证添加
.talentpoints remove 2     # Remove 2 points / 移除 2 点
.talentpoints set 10       # Set to exactly 10 / 设置为正好 10
```

**Expected Result / 预期结果:**
- Commands should work correctly and display appropriate messages
  命令应该正常工作并显示适当的消息
- Talent window should reflect changes after each command
  每次命令后天赋窗口应该反映变化

### Test 4: Level Up Integration / 升级集成

**Steps / 步骤:**

1. Create a new character or use a low-level one
   创建新角色或使用低级别的角色
2. Level up to 10, 20, 30, etc.
   升级到 10、20、30 级等
3. Check if bonus talent points are granted
   检查是否授予了额外天赋点

**Expected Result / 预期结果:**
- At specific levels (10, 20, 30, etc.), you should receive bonus talent points
  在特定级别（10、20、30 等），您应该收到额外天赋点
- Messages should appear confirming the bonus
  应该出现确认奖励的消息

### Test 5: Quest Rewards / 任务奖励

**Steps / 步骤:**

1. Configure a quest in `talent_system_examples.lua`
   在 `talent_system_examples.lua` 中配置任务
2. Complete the quest / 完成任务
3. Check if talent points are granted
   检查是否授予天赋点

**Expected Result / 预期结果:**
- Quest completion should grant configured talent points
  任务完成应该授予配置的天赋点
- Appropriate message should be displayed
  应该显示适当的消息

### Test 6: Negative Value Protection / 负值保护

**Steps / 步骤:**

1. Set extra talent points to 2: `.talentpoints set 2`
2. Try to remove 5 points: `.talentpoints remove 5`
3. Check the result / 检查结果

**Expected Result / 预期结果:**
- Extra talent points should be set to 0 (not negative)
  额外天赋点应该设置为 0（不是负数）
- No errors should occur / 不应该出现错误

### Test 7: Server Restart Persistence / 服务器重启持久化

**Important**: This test requires the database table to be created first!
**重要**：此测试需要先创建数据库表！

**Steps / 步骤:**

1. Ensure `character_extra_talent_points` table exists in characters database
   确保 characters 数据库中存在 `character_extra_talent_points` 表
2. Add extra talent points using `.talentpoints add 10`
   使用 `.talentpoints add 10` 添加额外天赋点
3. Check current points: `.talentpoints get`
   检查当前点数：`.talentpoints get`
4. Logout character / 登出角色
5. Restart the server / 重启服务器
6. Login with the same character / 使用同一角色登录
7. Check points again: `.talentpoints get`
   再次检查点数：`.talentpoints get`

**Expected Result / 预期结果:**
- Extra talent points should be preserved after server restart
  额外天赋点应该在服务器重启后保留
- Points shown should match the value before restart
  显示的点数应该与重启前的值匹配
- Talent window should show the correct total
  天赋窗口应该显示正确的总数

## Troubleshooting / 故障排除

### Lua Scripts Not Loading / Lua 脚本未加载

1. Check `Eluna.ScriptPath` in mangosd.conf
   检查 mangosd.conf 中的 `Eluna.ScriptPath`
2. Verify lua_scripts folder path is correct
   验证 lua_scripts 文件夹路径是否正确
3. Check server logs for Eluna errors
   检查服务器日志中的 Eluna 错误

### Item Not Working / 物品不起作用

1. Verify item ID matches in both database and Lua script
   验证数据库和 Lua 脚本中的物品 ID 是否匹配
2. Check if Eluna item hooks are enabled
   检查 Eluna 物品钩子是否启用
3. Look for error messages in server console
   在服务器控制台中查找错误消息

### Talent Points Not Showing / 天赋点未显示

1. Close and reopen talent window / 关闭并重新打开天赋窗口
2. Relog the character / 重新登录角色
3. Check if `UpdateFreeTalentPoints()` is called
   检查是否调用了 `UpdateFreeTalentPoints()`

### Compile Errors / 编译错误

1. Make sure all header files are included
   确保包含所有头文件
2. Check for syntax errors in Player.h and Player.cpp
   检查 Player.h 和 Player.cpp 中的语法错误
3. Verify VMangos version compatibility
   验证 VMangos 版本兼容性

## Verification Checklist / 验证清单

- [ ] Item can be added to inventory / 物品可以添加到背包
- [ ] Using item grants talent points / 使用物品授予天赋点
- [ ] Item is consumed after use / 使用后物品被消耗
- [ ] Talent window updates correctly / 天赋窗口正确更新
- [ ] GM commands work properly / GM 命令正常工作
- [ ] Messages display in both English and Chinese / 消息以中英文显示
- [ ] Negative values are handled correctly / 正确处理负值
- [ ] Sound effects play (optional) / 播放音效（可选）
- [ ] Multiple uses accumulate correctly / 多次使用正确累积

## Performance Notes / 性能注意事项

- The implementation has minimal performance impact
  实现对性能的影响最小
- Extra talent points are stored in memory (uint32)
  额外天赋点存储在内存中（uint32）
- Calculation is O(1) - just addition
  计算是 O(1) - 只是加法
- No database queries during gameplay
  游戏过程中没有数据库查询

## Future Enhancements / 未来增强

Consider implementing:
考虑实现：

1. Database persistence for extra talent points
   额外天赋点的数据库持久化
2. Per-character talent stone usage limits
   每个角色的天赋石使用限制
3. Configuration file for talent rewards
   天赋奖励的配置文件
4. Admin panel for managing talent bonuses
   管理天赋奖励的管理面板
5. Talent point decay over time
   随时间天赋点衰减
6. Guild-based talent point bonuses
   基于公会的天赋点奖励
