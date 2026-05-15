# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**LODP** (Logistics/Operational Dynamics Persistent) is a DCS World multiplayer mission framework for PvP territorial warfare on the Caucasus map. It is written entirely in **Lua** — there is no Node.js, Python, or traditional build system. The mission file (`Miz files/LODP_DML_1_0_Full_Map.miz`) is a ZIP archive containing all scripts and mission data.

## Development Workflow

There is no build tool. The development cycle is:

Canonical script sources live in `Scripts/`. The miz archive under `Miz files/` contains a copy in `l10n/DEFAULT/` — keep both in sync when editing.

1. Edit Lua scripts in `Scripts/`
2. Copy changed scripts into the extracted miz at `Miz files/LODP_DML_1_0_Full_Map - Copy/l10n/DEFAULT/`
3. Repack that folder back into `LODP_DML_1_0_Full_Map.miz` (ZIP format)
4. Load the mission in DCS World to test
5. In-game: use server save to trigger persistence callbacks
6. Restart mission fresh to verify state is restored correctly

> The `mission` file inside the archive is the raw DCS Mission Editor data structure and should be edited via the DCS Mission Editor GUI, not by hand.

## Architecture

Initialization order matters — modules load sequentially at mission start:

```
dcsCommon → cfxZones → cfxMX → bank → cfxOwnedZones → income
→ persistence → unitPersistence → commander → CTLD & Menus (refactored)
→ cfxBaseEnforcer → bankPenalties → loadzoneMarks → spawn-GC
→ mist → EWRS → AutoRestart
```

| Module | Role |
|--------|------|
| `dcsCommon.lua` | Foundational utilities, DCS API patches, group/unit lookups |
| `cfxZones.lua` | OOP zone system (`dmlZone` class), circular & polygon zones |
| `cfxMX.lua` | Mission data decoder — accesses DCS mission editor structure |
| `cfxOwnedZones_modified.lua` | Territory ownership, contested state, victory conditions |
| `bank.lua` | Coalition fund accounts, configured via `bankConfig` trigger zone |
| `income.lua` | Deposits income to bank based on zone ownership |
| `commander.lua` | Group automation, road/off-road pathfinding |
| `persistence.lua` | Module registry, save/load callbacks, version checking |
| `unitPersistence.lua` | Restores ground/air/ship unit state across server restarts |
| `CTLD & Menus_refactored.lua` | Moose CTLD helicopter cargo system (troops, vehicles) |
| `cfxBaseEnforcer.lua` | Kicks players who spawn/land at enemy-controlled airbases |
| `bankPenalties.lua` | Deducts coalition funds on aircraft loss, tiered by type |
| `loadzoneMarks.lua` | Places F10 map marks for all `Loadzone *` CTLD zones |
| `spawn-GC.lua` | F10 map mark commands: `explode` and `spawn-<GroupName>` |
| `mist_4_5_128.lua` | MIST framework (required by EWRS) |
| `EWRS_v11.8.6.lua` | Early Warning Radar System — requires MIST |
| `AutoRestart.lua` | Schedules server restart via `MISSION_RESTART` flag at 5 hours |
| `Moose_ (2).lua` | Third-party Moose framework (March 2026 build) |

## Key Conventions

### New Module Template
```lua
myModule = {}
myModule.version = "1.0.0"
myModule.requiredLibs = { "dcsCommon", "cfxZones" }

persistence.registerModule("myModule", {
    persistData = myModule.saveData
})

function myModule.start()
    timer.scheduleFunction(myModule.update, {}, 1.0)
end

function myModule.saveData()
    return { myModule.state }, "myModuleKey"
end
```

### Zone-Based Configuration
Never hardcode gameplay values. All configuration goes in DCS trigger zones and is read at runtime:
```lua
local cfg = cfxZones.getZoneByName("myModuleConfig")
local rate  = cfg:getNumberFromZoneProperty("rate", 100)
local label = cfg:getStringFromZoneProperty("label", "default")
local on    = cfg:getBoolFromZoneProperty("enabled", true)
```

### Coalition Coding
- Numeric: `0 = Neutral`, `1 = RED`, `2 = BLUE`
- Text: `"neutral"`, `"red"`, `"blue"` — conversion is handled transparently in dcsCommon

### Contested Zone Logic
- Both RED and BLUE units present → **contested** (yellow)
- Only one side present → that coalition owns it
- Neither present → **neutral**

## Known DCS Quirks

- Zone radius is sometimes returned as a string instead of a number (cfxZones handles this)
- `Group.getByName()` returns `nil` for empty groups — dcsCommon patches this
- `deepCopy()` has a DCS 2.9 bug; use the alternative copy utility in dcsCommon
- Some DCS API operations require a **desanitized** server environment (e.g., file I/O for persistence)

## Detailed Reference

See [AGENTS.md](AGENTS.md) for the comprehensive development guide including DCS API reference, Moose integration patterns, and persistence debugging tips.
