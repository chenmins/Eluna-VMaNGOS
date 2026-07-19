# AoE Loot Feature Design Document

## Overview

The Area of Effect (AoE) Loot feature enhances the looting experience by automatically merging loot from multiple nearby corpses into a single loot window. This feature is particularly useful for players who are killing multiple enemies in quick succession, as it eliminates the need to individually loot each corpse.

## Feature Description

When a player opens a loot window on a creature corpse, the system automatically searches for other lootable corpses within a configurable range and merges their loot into the main loot window. This allows players to collect loot from multiple kills with a single loot action.

### Key Benefits

1. **Improved Player Experience**: Reduces the tedious task of looting multiple corpses individually
2. **Time Efficiency**: Speeds up the looting process for AoE farming scenarios
3. **Configurable**: Server administrators can customize the feature to their preferences
4. **Performance Conscious**: Includes limits to prevent performance degradation

## Configuration Options

All configuration options are added to `mangosd.conf` with sensible defaults:

### AoELoot.Enable
- **Description**: Master switch to enable or disable the AoE loot feature
- **Default**: 1 (Enabled)
- **Values**: 0 (Disabled), 1 (Enabled)

### AoELoot.Message
- **Description**: Shows a message to players on login about the AoE loot feature
- **Default**: 1 (Enabled)
- **Values**: 0 (Disabled), 1 (Enabled)
- **Note**: Currently the message display logic needs to be implemented in player login handler

### AoELoot.Range
- **Description**: Maximum range in yards to search for nearby lootable corpses
- **Default**: 55.0
- **Valid Range**: 5.0 - 100.0 (automatically clamped)
- **Note**: Higher ranges increase the search radius but may impact performance

### AoELoot.Group
- **Description**: Controls whether AoE loot works when the player is in a group
- **Default**: 1 (Enabled)
- **Values**: 
  - 0 (Disabled - AoE loot only works when solo)
  - 1 (Enabled - AoE loot works in groups)

### AoELoot.MaxCorpses
- **Description**: Maximum number of nearby corpses to merge into the loot window
- **Default**: 10
- **Valid Range**: 1 - 20 (automatically clamped)
- **Note**: Lower values improve performance; higher values allow more corpses to be looted at once

## Technical Implementation

### Architecture

The implementation consists of the following components:

#### 1. Configuration Files
- `conf/aoe_loot.conf.dist` - Standalone configuration file with detailed documentation
- `src/mangosd/mangosd.conf.dist.in` - Integration of AoE loot settings into main config

#### 2. Core Implementation
Location: `src/game/Handlers/LootHandler.cpp`

**Components:**

##### Helper Class: `MaNGOS::AllLootableDeadCreaturesInRange`
A grid notifier check class that identifies lootable dead creatures within range. It verifies:
- Creature is not alive
- Creature is within specified range
- Creature has the LOOTABLE flag set
- Creature has a loot recipient
- Player has permission to loot (is recipient or in same group)

##### Helper Function: `GetNearbyLootableCorpses()`
Searches the grid for nearby lootable corpses using the Cell visitor pattern:
```cpp
static void GetNearbyLootableCorpses(
    std::list<Creature*>& corpseList,
    Player* player,
    Creature* excludeCreature,
    float range)
```

##### Modified Function: `WorldSession::HandleLootOpcode()`
Enhanced to include AoE loot logic:
1. Performs all standard loot checks
2. If AoE loot is enabled and target is a creature:
   - Reads configuration settings
   - Searches for nearby lootable corpses
   - Merges loot from found corpses:
     - Combines gold amounts (with overflow protection)
     - Copies items (respecting MAX_NR_LOOT_ITEMS limit)
   - Creates a temporary merged view; source corpses remain unchanged until an item or gold is actually taken
3. Sends the merged loot window to the player

### Loot Merging Process

1. **Target Selection**: Player initiates looting on a creature corpse
2. **Validation**: System verifies AoE loot is enabled and conditions are met
3. **Search**: System searches for nearby lootable corpses within configured range
4. **Permission Check**: Each corpse is validated for loot permissions
5. **Merge**: 
   - Gold amounts are summed (with overflow protection)
   - Items are copied to main loot window (up to item limit)
   - Closing without looting rolls back the temporary merge and preserves source corpses
   - Taking any item or gold commits the merge and clears the source corpses
6. **Display**: Merged loot window is shown to the player

### Safety Features

1. **Range Clamping**: Loot range is automatically clamped between 5.0 and 100.0 yards
2. **Corpse Limit**: Maximum corpses processed is clamped between 1 and 20
3. **Overflow Protection**: Gold merging includes checks to prevent uint32 overflow
4. **Item Limit**: Respects the game's MAX_NR_LOOT_ITEMS (16) limit
5. **Permission Checks**: Only loots corpses the player has permission to loot
6. **Group Support Toggle**: Can be disabled for group scenarios if desired

### Performance Considerations

1. **Limited Search Radius**: Default 55-yard range balances usability and performance
2. **Corpse Count Limit**: Default 10 corpses prevents excessive processing
3. **Early Termination**: Stops processing when item limit is reached
4. **Efficient Grid Search**: Uses MaNGOS Cell visitor pattern for optimal grid traversal

## Integration Points

### Files Modified

1. **src/mangosd/mangosd.conf.dist.in**
   - Added AoE loot configuration section

2. **src/game/Handlers/LootHandler.cpp**
   - Added necessary includes (Config.h, Creature.h, Cell headers)
   - Added AllLootableDeadCreaturesInRange check class
   - Added GetNearbyLootableCorpses() helper function
   - Modified HandleLootOpcode() to implement AoE loot

### Files Added

1. **conf/aoe_loot.conf.dist**
   - Standalone configuration file for AoE loot feature

2. **docs/AoE_Loot_Design.md**
   - This design document

3. **docs/AoE_Loot_Testing.md**
   - Testing guide and scenarios

## Compatibility

### Client Versions
The feature works with all supported client builds as it operates server-side without client modifications.

### Group Loot Modes
Compatible with all group loot modes:
- Free for All
- Round Robin
- Master Looter
- Group Loot
- Need Before Greed

The feature respects existing loot permissions and only merges corpses the player can legitimately loot.

## Future Enhancements

Potential improvements for future versions:

1. **Login Message Implementation**: Add actual message display when players log in
2. **Per-Player Toggle**: Allow players to enable/disable AoE loot via command
3. **Loot Priority**: Smart ordering of merged loot (e.g., quest items first)
4. **Visual Feedback**: Optional UI indicator showing number of corpses looted
5. **Statistics Tracking**: Log AoE loot usage for server analytics
6. **Distance-Based Ordering**: Loot closer corpses first

## References

- Original inspiration: [azerothcore/mod-aoe-loot](https://github.com/azerothcore/mod-aoe-loot)
- VMaNGOS Core: [vmangos/core](https://github.com/vmangos/core)
- Eluna integration: Compatible with Eluna Lua engine
