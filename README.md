# MaxDps-Tinkr Bridge

A bridge script to integrate [MaxDps](https://www.curseforge.com/wow/addons/maxdps-rotation-helper) rotation suggestions with [Tinkr](https://tinkr.site/) Lua unlocker execution.

## Features

- **Automated Rotation**: Automatically casts spells suggested by MaxDps.
- **Smart Casting**:
  - Handles ground-targeted spells (Death and Decay, Defile) by casting at the cursor/target.
  - Automatically handles self-buffs and pet commands.
- **Defensive Suite**:
  - Auto-uses Icebound Fortitude, Anti-Magic Shell, and Vampiric Blood at configurable HP thresholds.
  - Prioritizes Death Strike when critical.
- **Consumable Support**:
  - Automatically keybinds and uses health potions (including TWW/Midnight PTR potions) when low on health.

## Installation

1.  Clone this repository or download the script.
2.  Place `maxdps_dk.lua` into your Tinkr `scripts/routines` folder.
3.  Ensure you have the **MaxDps** addon (and the module for your class, e.g., MaxDps_DeathKnight) installed and enabled in WoW.

## Usage

1.  Log in to World of Warcraft.
2.  Load the routine in Tinkr:
    ```
    /routine load maxdps_dk
    ```
3.  Target an enemy and enter combat. The script will automatically execute the MaxDps rotation.

## Configuration

You can adjust the following thresholds at the top of `maxdps_dk.lua`:

```lua
local DEFENSIVE_HP_THRESHOLD = 50  -- HP % to use defensive cooldowns
local POTION_HP_THRESHOLD = 35     -- HP % to use health potions
```

## Supported Classes

- **Death Knight** (Blood, Frost, Unholy)
  - _Note: Currently optimized for Unholy and Blood, but should work for Frost as well._

## License

MIT
