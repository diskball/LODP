# LODP_DML: DCS Mission AI Agent Guide

**LODP** (Logistics/Operational Dynamics Persistent) is a sophisticated DCS mission framework for cooperative territorial warfare with persistent progression, economics, and logistics mechanics.

## Quick Facts

- **Project Type**: DCS mission with persistent Lua scripting framework
- **Theatre**: Caucasus  
- **Framework**: Moose (March 2026 build) + 11 custom Lua modules
- **Core Systems**: Territory control, coalition economics, unit persistence, dynamic logistics
- **Development**: Extract → Edit Lua scripts in `l10n/DEFAULT/` → Repack `.miz`

## Architecture Overview

```
Mission Start
  ↓ [dcsCommon] Initialize utilities & mission IDs
  ↓ [cfxZones] Read zones from mission editor  
  ↓ [cfxMX] Index groups, units, players
  ↓ [bank] Open coalition accounts
  ↓ [cfxOwnedZones] Initialize zone ownership
  ↓ [income] Start income ticker  
  ↓ [persistence] Load saved mission state
  ↓ [unitPersistence] Restore unit positions
  ↓ [commander] Load pathfinding zones
  ↓ [CTLD] Initialize helicopter cargo system
```

## Core Modules

| Module | Purpose | Key Pattern |
|--------|---------|------------|
| [dcsCommon.lua](l10n/DEFAULT/dcsCommon.lua) | Foundational utilities (v3.3.2) | Group/unit lookups, formation management, DCS API patches |
| [cfxZones.lua](l10n/DEFAULT/cfxZones.lua) | Zone management OOP system (v4.5.4) | `dmlZone` class, circular/polygonal support, zone properties |
| [cfxMX.lua](l10n/DEFAULT/cfxMX.lua) | Mission data decoder (v4.1.0) | Accesses mission editor structure, coalition/group/unit indexing |
| [cfxOwnedZones_modified.lua](l10n/DEFAULT/cfxOwnedZones_modified.lua) | Territory ownership tracking (v2.5.3) | Coalition capture states, contested/neutral handling, victory conditions |
| [bank.lua](l10n/DEFAULT/bank.lua) | Coalition fund management (v1.0.0) | Zone-based configuration via `bankConfig` trigger zone |
| [income.lua](l10n/DEFAULT/income.lua) | Territory-based income generation (v0.9.8) | Deposits into bank, configurable via `incomeConfig` zone |
| [commander.lua](l10n/DEFAULT/commander.lua) | Group automation & pathfinding (v2.0.1) | Road/offroad routing, formation support, `CommanderConfig` zone |
| [persistence.lua](l10n/DEFAULT/persistence.lua) | Mission state serialization (v3.1.0) | Module registry, save/load callbacks, version checking |
| [unitPersistence.lua](l10n/DEFAULT/unitPersistence.lua) | Unit state persistence (v2.0.1) | Ground/air/ship unit restoration across server restarts |
| [CTLD & Menus.lua](l10n/DEFAULT/CTLD%20&%20Menus.lua) | Moose CTLD helicopter cargo system | Cargo loading/dropping, zone-based configuration |
| [Moose_ (2).lua](l10n/DEFAULT/Moose_%20(2).lua) | Moose framework (March 2026) | Dynamic module loading via `Scripts/Moose/Modules.lua` |

## Lua Scripting Conventions

### Module Template
```lua
module = {}
module.version = "1.0.0"
module.requiredLibs = { "dcsCommon", "cfxZones" }

persistence.registerModule("moduleName", {
    persistData = module.saveData
})

function module.start()
    timer.scheduleFunction(module.update, {}, 1.0)
end
```

### Zone-Based Configuration Pattern
Configuration stored in **trigger zones** with named properties accessed via DML zone methods:

```lua
local configZone = cfxZones.getZoneByName("moduleConfig")
local amount = configZone:getNumberFromZoneProperty("amount", 100)
local enabled = configZone:getBoolFromZoneProperty("enabled", true)
local message = configZone:getStringFromZoneProperty("message", "default")
```

**Standard config zones**:
- `bankConfig` — Coalition starting balances
- `incomeConfig` — Income rates, intervals, announcements  
- `CommanderConfig` — Pathfinding behavior (roads, offroad, verbose)
- Custom zones for module-specific settings

### Coalition Coding
- **Numeric**: `0 = Neutral`, `1 = RED`, `2 = BLUE`
- **Text**: `"neutral"`, `"red"`, `"blue"`
- Conversion logic handles both transparently

### Object-Oriented Pattern (dmlZone class)
```lua
dmlZone = {}
function dmlZone:new(o)
    setmetatable(o, self)
    self.__index = self
    return o
end
```

## Persistence Mechanism

### Data Flow
1. **Runtime**: Modules maintain state in Lua tables (balances, ownership, positions)
2. **On save**: `persistence.update()` calls registered save callbacks
3. **Serialization**: Data written to file (configurable location)
4. **On load**: `persistence.loadData()` restores and calls load callbacks
5. **Version checking**: Warns if saved data from older module versions

### Module Save Callback Pattern
```lua
function module.saveData()
    return { data_table }, "sharedDataKey"
end
```

## DCS APIs & Moose Framework

### Common DCS APIs Used
- `coalition.getPlayers()` — Get player units per side
- `env.mission.coalition[]` — Mission data structure
- `trigger.action.outText()`, `outTextForCoalition()` — Messaging
- `Group.getByName()`, `Unit.getByName()` — Object access
- `timer.scheduleFunction()` — Event scheduling
- `Unit.getLife()`, `Unit.getPoint()` — Unit state queries

### Moose Integration
- **CTLD**: Combat Transport Logistics Drop for helicopter cargo operations
- **Cargo system**: Troops and vehicles as loadable cargo  
- **Smoke markers**: Zone visualization with colored smoke
- **Module loading**: Dynamic imports via `Scripts/Moose/Modules.lua`

## Development Workflow

### Mission Modification Cycle
1. **Edit mission** in DCS Mission Editor → creates/updates zones, groups, triggers
2. **Extract .miz** → uncompress to LODP_DML folder
3. **Edit Lua scripts** in `l10n/DEFAULT/` 
4. **Repack as .miz** → compress LODP_DML back to miz format
5. **Test in DCS** → verify persistence, zone mechanics, income
6. **Save via DCS** → triggers persistence callbacks
7. **Load fresh** → verify state restored correctly

### Key Files to Modify
- **l10n/DEFAULT/*.lua** — All game logic scripts
- **mission** — Raw DCS mission editor data (coalitions, groups, triggers, zones)
- **options** — DCS game options and difficulty settings
- **theatre** — Mission theatre (contains: `Caucasus`)

## Common Patterns & Gotchas

### Known DCS Quirks (handled in code)
- **Zone radius**: Sometimes stored as string instead of number (cfxOwnedZones comment: "WTF, ED?")
- **Empty groups**: `Group.getByName()` returns nil for empty groups; dcsCommon patches this
- **DCS 2.9 workaround**: Alternative `deepCopy()` for table cloning issues
- **Unit counting bug** (cfxOwnedZones v2.5.2): Fixed multiplying group size error

### Contested Zone Logic (cfxOwnedZones)
- **RED present** → zone potentially RED
- **BLUE present** → zone potentially BLUE  
- **Both present** → zone **contested** (yellow state)
- **Neither present** → zone **neutral**
- Victory determined by sustained ownership time

### Commander Pathfinding
- Road-based routing for realism (slower, safer)
- Off-road routing for speed (faster, risky)
- Pathing zones define route constraints per region
- Formation support for coordinated unit groups

## File Structure

```
LODP/
  LODP_DML/
    mission              # DCS mission editor data structure
    options              # DCS game options
    theatre              # Mission theatre ("Caucasus")
    warehouses           # Logistics/warehouse data
    l10n/
      DEFAULT/           # Localization folder
        *.lua             # All game logic scripts
        dictionary        # Text/command translations
        mapResource       # Resource definitions
  Miz files/
    LODP_DML.miz         # Compressed mission archive
```

## Quick Tips for Agents

1. **All configuration via zones**: Don't hardcode values—use trigger zone properties
2. **Module interdependencies**: Check `requiredLibs` before modifying module load order
3. **Persistence is opt-in**: Must call `persistence.registerModule()` to save state
4. **Coalition agnostic**: Use text representation (`"red"`, `"blue"`, `"neutral"`) for clarity
5. **Version checking**: Update module version when making breaking changes
6. **Moose framework**: Extensive—use `Moose.lua` docs for advanced features
7. **Zone drawing**: Zones support circles, polygons, and property-based logic
8. **Save callbacks must return**: `{ dataTable, sharedDataKey }` tuple
9. **Testing**: Use fresh mission loads to verify persistence works correctly
10. **DCS API limits**: Some operations require desanitized environment on server

## Next Steps for Customization

Consider creating skills/agents for:
- **Zone configuration helpers** — Automate zone property reading/writing
- **Module scaffolding** — Generate new persistent modules from template
- **Persistence debugging** — Validate save/load data integrity
- **CTLD configuration** — Helicopter capability management
- **Territory analysis** — Zone ownership state queries and reporting

---

*Last updated: May 2, 2026 • Moose framework: March 31, 2026*
