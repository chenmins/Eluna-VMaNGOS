# AoE Loot Feature Testing Guide

## Overview

This document provides comprehensive testing scenarios and procedures for the AoE Loot feature. It covers functional testing, configuration validation, edge cases, and performance testing.

## Prerequisites

Before testing, ensure:
1. Server is compiled with the AoE loot changes
2. Configuration files are properly set up
3. Test character has appropriate permissions and level
4. Test environment has multiple spawned creatures for testing

## Configuration Testing

### Test 1: Feature Enable/Disable

**Objective**: Verify the master enable/disable switch works correctly

**Steps**:
1. Set `AoELoot.Enable = 0` in mangosd.conf
2. Restart server
3. Kill multiple nearby creatures
4. Loot one creature
5. **Expected**: Only the selected creature's loot appears
6. Set `AoELoot.Enable = 1` in mangosd.conf
7. Restart server
8. Kill multiple nearby creatures
9. Loot one creature
10. **Expected**: Multiple corpses' loot is merged

**Status**: ⬜ Pass ⬜ Fail

---

### Test 2: Range Configuration

**Objective**: Verify the loot range setting works as intended

**Test Cases**:

#### Case A: Default Range (55 yards)
```ini
AoELoot.Range = 55.0
```
- Kill creatures at various distances (40, 50, 60 yards)
- **Expected**: Corpses within 55 yards are merged, those beyond are not

#### Case B: Minimum Range (5 yards)
```ini
AoELoot.Range = 5.0
```
- Kill creatures at 3, 5, and 10 yards
- **Expected**: Only very close corpses are merged

#### Case C: Maximum Range (100 yards)
```ini
AoELoot.Range = 100.0
```
- Kill creatures spread across 90 yards
- **Expected**: All corpses within 100 yards are merged

#### Case D: Out of Bounds Values
```ini
AoELoot.Range = 2.0    # Below minimum
AoELoot.Range = 150.0  # Above maximum
```
- **Expected**: Values are clamped to 5.0 and 100.0 respectively

**Status**: ⬜ Pass ⬜ Fail

---

### Test 3: Group Mode

**Objective**: Verify group settings work correctly

#### Test 3A: Group Mode Enabled
```ini
AoELoot.Group = 1
```
**Steps**:
1. Form a group with another player
2. Kill multiple creatures
3. Loot corpses
4. **Expected**: AoE loot works in group

**Status**: ⬜ Pass ⬜ Fail

#### Test 3B: Group Mode Disabled
```ini
AoELoot.Group = 0
```
**Steps**:
1. Form a group with another player
2. Kill multiple creatures
3. Loot corpses
4. **Expected**: AoE loot does NOT work, only single corpse loot
5. Leave group and loot again
6. **Expected**: AoE loot now works when solo

**Status**: ⬜ Pass ⬜ Fail

---

### Test 4: Max Corpses Limit

**Objective**: Verify corpse count limit is respected

**Test Cases**:

#### Case A: Default Limit (10 corpses)
```ini
AoELoot.MaxCorpses = 10
```
- Kill 15 creatures in close proximity
- Loot one corpse
- **Expected**: Only 10 additional corpses are merged (11 total including main)

#### Case B: Minimum Limit (1 corpse)
```ini
AoELoot.MaxCorpses = 1
```
- Kill 5 creatures nearby
- **Expected**: Only 1 additional corpse is merged (2 total)

#### Case C: Maximum Limit (20 corpses)
```ini
AoELoot.MaxCorpses = 20
```
- Kill 25 creatures nearby
- **Expected**: Only 20 additional corpses are merged (21 total)

**Status**: ⬜ Pass ⬜ Fail

---

## Functional Testing

### Test 5: Basic Loot Merging

**Objective**: Verify loot from multiple corpses is correctly merged

**Steps**:
1. Kill 3-5 creatures within 30 yards
2. Note the items/gold on each corpse (if visible via GM commands)
3. Loot the first corpse
4. **Expected**: 
   - All items from nearby corpses appear in loot window
   - Gold amounts are summed correctly
   - All merged corpses lose their sparkle effect

**Verification**:
- Check that merged corpses no longer have LOOTABLE flag
- Verify total gold matches sum of all corpses
- Verify all expected items are present

**Status**: ⬜ Pass ⬜ Fail

---

### Test 6: Item Limit Respect

**Objective**: Verify the MAX_NR_LOOT_ITEMS (16) limit is respected

**Steps**:
1. Set up creatures with guaranteed drops (multiple items each)
2. Kill enough creatures to exceed 16 items total
3. Loot one corpse
4. **Expected**:
   - Only 16 items maximum appear in loot window
   - No crash or error occurs
   - Remaining items are lost (acceptable behavior)

**Status**: ⬜ Pass ⬜ Fail

---

### Test 7: Permission Checks

**Objective**: Verify loot permission system works correctly

#### Test 7A: No Tap Rights
**Steps**:
1. Have another player kill creatures
2. Wait for loot rights to be assigned to them
3. Try to loot corpses
4. **Expected**: Cannot loot corpses without permission

#### Test 7B: Group Tap Rights
**Steps**:
1. Form group with another player
2. One player kills creatures
3. Other player loots
4. **Expected**: Can loot corpses killed by group member

#### Test 7C: Solo Tap Rights
**Steps**:
1. Kill creatures solo
2. Loot corpses
3. **Expected**: Can loot all own kills

**Status**: ⬜ Pass ⬜ Fail

---

### Test 8: Already Looted Corpses

**Objective**: Verify already-looted corpses are properly handled

**Steps**:
1. Kill 5 creatures
2. Manually loot 2 of them completely
3. Loot a third corpse
4. **Expected**: Only unlooted corpses are merged

**Status**: ⬜ Pass ⬜ Fail

---

## Edge Cases

### Test 9: Gold Overflow Protection

**Objective**: Verify gold overflow is prevented

**Setup**: Requires GM commands to set high gold amounts

**Steps**:
1. Set gold on corpses to values near uint32 max (4,294,967,295 copper)
2. Kill creatures with these values
3. Loot corpses
4. **Expected**: Gold is capped and doesn't overflow (no negative values)

**Status**: ⬜ Pass ⬜ Fail

---

### Test 10: No Nearby Corpses

**Objective**: Verify normal loot behavior when no nearby corpses exist

**Steps**:
1. Kill a single creature far from others
2. Loot the corpse
3. **Expected**: Normal loot window, no errors

**Status**: ⬜ Pass ⬜ Fail

---

### Test 11: Mixed Creature Types

**Objective**: Verify feature works with different creature types

**Test with**:
- Regular creatures
- Elite creatures
- Rare creatures
- Boss creatures (if applicable)

**Expected**: All types are handled correctly

**Status**: ⬜ Pass ⬜ Fail

---

### Test 12: Living Creatures

**Objective**: Verify only dead creatures are considered

**Steps**:
1. Kill some creatures
2. Leave some creatures alive nearby
3. Loot dead corpses
4. **Expected**: Living creatures are ignored, only dead are merged

**Status**: ⬜ Pass ⬜ Fail

---

## Group Loot Modes Testing

### Test 13: Master Looter Mode

**Setup**: Set group to Master Looter mode

**Steps**:
1. Form group with master looter assigned
2. Kill multiple creatures
3. Have non-master player try to loot
4. **Expected**: Respects master loot rules

**Status**: ⬜ Pass ⬜ Fail

---

### Test 14: Round Robin Mode

**Setup**: Set group to Round Robin loot mode

**Steps**:
1. Form group with Round Robin enabled
2. Kill multiple creatures
3. Different players loot corpses
4. **Expected**: Loot is distributed according to Round Robin rules

**Status**: ⬜ Pass ⬜ Fail

---

### Test 15: Free For All Mode

**Setup**: Set group to Free For All mode

**Steps**:
1. Form group with FFA enabled
2. Kill multiple creatures
3. Any player loots corpses
4. **Expected**: All players can loot

**Status**: ⬜ Pass ⬜ Fail

---

## Performance Testing

### Test 16: High Corpse Count

**Objective**: Verify performance with maximum corpses

**Steps**:
1. Set `AoELoot.MaxCorpses = 20`
2. Kill 30+ creatures in close proximity
3. Loot one corpse
4. Monitor:
   - Server lag/freeze
   - Client responsiveness
   - Time to open loot window

**Metrics**:
- Loot window open time: ___ ms
- Server performance: ⬜ Normal ⬜ Degraded

**Status**: ⬜ Pass ⬜ Fail

---

### Test 17: Large Range Testing

**Objective**: Verify performance with maximum range

**Steps**:
1. Set `AoELoot.Range = 100.0`
2. Kill many creatures spread across 100 yards
3. Loot corpse in center
4. Monitor performance

**Metrics**:
- Loot window open time: ___ ms
- Server performance: ⬜ Normal ⬜ Degraded

**Status**: ⬜ Pass ⬜ Fail

---

## Regression Testing

### Test 18: Non-Creature Loot

**Objective**: Verify normal loot still works for non-creatures

**Test Cases**:
- Chests (GameObjects)
- Herb nodes
- Mining nodes
- Fishing nodes
- Player corpses (PvP)

**Expected**: All work normally, AoE loot only applies to creatures

**Status**: ⬜ Pass ⬜ Fail

---

### Test 19: Quest Item Loot

**Objective**: Verify quest items are properly handled

**Steps**:
1. Accept a quest requiring kills
2. Kill multiple quest creatures
3. Loot using AoE loot
4. **Expected**: Quest items appear correctly

**Status**: ⬜ Pass ⬜ Fail

---

### Test 20: Profession Loot (Skinning)

**Objective**: Verify skinning still works correctly

**Steps**:
1. Kill skinnable creatures
2. Skin them normally
3. **Expected**: Skinning works as before, AoE loot doesn't interfere

**Status**: ⬜ Pass ⬜ Fail

---

## Stress Testing

### Test 21: Rapid Loot Actions

**Objective**: Test for race conditions or crashes

**Steps**:
1. Kill many creatures
2. Rapidly open and close loot windows
3. Try to loot multiple corpses in quick succession
4. **Expected**: No crashes, no duplicate loot

**Status**: ⬜ Pass ⬜ Fail

---

### Test 22: Multiple Players Same Area

**Objective**: Test concurrent looting scenarios

**Steps**:
1. Have multiple players killing in same area
2. Each player loots their own corpses with AoE
3. **Expected**: 
   - No loot stealing
   - No crashes
   - Each player gets correct loot

**Status**: ⬜ Pass ⬜ Fail

---

### Test 23: Reopen After Closing Without Looting

**Objective**: Verify that opening an AoE loot window does not itself consume the source corpses' loot.

**Steps**:
1. Kill 3 creatures within `AoELoot.Range`, each with ordinary items or gold.
2. Open corpse A and confirm that loot from corpses B and C appears in the merged window.
3. Take no item or gold, then close the loot window.
4. Attempt to reopen corpses A, B, and C.

**Expected**: All three corpses remain lootable; their combined loot equals the loot before step 2, with no duplication or loss. After taking any item or gold from A's merged window, only then are merged source corpses marked looted.

**Regression basis**: Before this fix, step 2 immediately cleared B/C and removed their lootable flags, so step 4 failed.

**Status**: ⬜ Pass ⬜ Fail

---
## Testing Checklist

Before declaring the feature production-ready, verify:

- [ ] All configuration options work as documented
- [ ] Feature can be enabled/disabled
- [ ] Range limits are respected
- [ ] Corpse limits are respected
- [ ] Group settings work correctly
- [ ] Loot permissions are honored
- [ ] Item limits are respected
- [ ] No crashes or errors occur
- [ ] Performance is acceptable
- [ ] Works with all group loot modes
- [ ] Doesn't break existing loot systems
- [ ] Quest items work correctly
- [ ] Gold merging works correctly
- [ ] Proper cleanup of looted corpses

## Reporting Issues

When reporting bugs, include:
1. Configuration settings used
2. Steps to reproduce
3. Expected vs actual behavior
4. Server logs (if applicable)
5. Client version
6. Number of players involved

## Notes

- Some tests may require GM commands or debug tools
- Performance metrics will vary based on hardware
- Test in both PvE and PvP scenarios if applicable
- Test with various client versions if server supports multiple

## Test Results Summary

Total Tests: 23
- Passed: ___
- Failed: ___
- Not Tested: ___

Overall Status: ⬜ Ready for Production ⬜ Needs Fixes ⬜ In Progress
