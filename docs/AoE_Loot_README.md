# AoE Loot Feature - Quick Start Guide

## What is AoE Loot?

AoE (Area of Effect) Loot is a quality-of-life feature that automatically combines loot from multiple nearby corpses into a single loot window. When you loot one creature, the system searches for other lootable corpses within range and merges their items and gold into the main loot window.

## Quick Start

### 1. Installation

The feature is already integrated into the codebase. Simply compile the server:

```bash
mkdir build && cd build
cmake ..
make -j$(nproc)
```

### 2. Configuration

Edit your `mangosd.conf` file and configure the AoE loot settings:

```ini
# Enable/Disable the feature
AoELoot.Enable = 1

# Show login message
AoELoot.Message = 1

# Search range in yards (5.0 - 100.0)
AoELoot.Range = 55.0

# Enable in groups
AoELoot.Group = 1

# Maximum corpses to merge (1 - 20)
AoELoot.MaxCorpses = 10
```

### 3. Start Server

Start your server normally. The feature will be active immediately.

## How to Use

1. **Kill multiple enemies** in close proximity (within the configured range)
2. **Loot one corpse** as you normally would
3. **Automatically receive** loot from all nearby corpses in a single window
4. **Profit!** No need to loot each corpse individually

## Features

✅ Automatic loot merging from nearby corpses  
✅ Configurable search range  
✅ Configurable maximum corpse count  
✅ Group support (can be toggled)  
✅ Respects loot permissions  
✅ Compatible with all loot modes  
✅ Safe overflow protection  
✅ Performance optimized  

## Configuration Reference

| Setting | Default | Range | Description |
|---------|---------|-------|-------------|
| `AoELoot.Enable` | 1 | 0-1 | Enable/disable the feature |
| `AoELoot.Message` | 1 | 0-1 | Show login message |
| `AoELoot.Range` | 55.0 | 5.0-100.0 | Search range in yards |
| `AoELoot.Group` | 1 | 0-1 | Enable in groups |
| `AoELoot.MaxCorpses` | 10 | 1-20 | Max corpses to merge |

## Documentation

- 📖 [Design Document (English)](AoE_Loot_Design.md)
- 📖 [Design Document (中文)](AoE_Loot_Design_CN.md)
- 🧪 [Testing Guide (English)](AoE_Loot_Testing.md)
- 🧪 [Testing Guide (中文)](AoE_Loot_Testing_CN.md)

## Compatibility

- ✅ All VMaNGOS supported client versions (1.12.1, 1.11.2, 1.10.2, etc.)
- ✅ All loot modes (Free for All, Round Robin, Master Looter, etc.)
- ✅ Solo and group play
- ✅ Eluna Lua engine compatible

## Troubleshooting

### Feature not working?

1. Check `AoELoot.Enable = 1` in config
2. Verify corpses are within configured range
3. Ensure you have loot permission for the corpses
4. Check if `AoELoot.Group` is properly set for your scenario

### Performance issues?

1. Reduce `AoELoot.MaxCorpses` to a lower value (e.g., 5)
2. Reduce `AoELoot.Range` to a smaller radius (e.g., 30.0)

### Loot missing?

- Item window has a 16-item limit. If more items exist, some will be lost
- Quest items should always appear if you have the quest

## Credits

- Original inspiration: [azerothcore/mod-aoe-loot](https://github.com/azerothcore/mod-aoe-loot)
- Adapted for VMaNGOS by the community

## Support

For issues or questions:
- Check the [Testing Guide](AoE_Loot_Testing.md) for common scenarios
- Review the [Design Document](AoE_Loot_Design.md) for technical details
- Report bugs with full configuration and reproduction steps

---

**Enjoy easier looting!** 🎮
