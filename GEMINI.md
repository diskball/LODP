# LODP_DML Project Guide for Gemini

This project is a sophisticated DCS (Digital Combat Simulator) mission framework for cooperative territorial warfare with persistent progression, economics, and logistics mechanics.

## Architecture & Framework
- **Framework:** Moose (March 2026 build) + custom Lua modules.
- **Environment:** Lua scripting for DCS World.
- **Scripts Location:** All game logic scripts are located in `LODP_DML/l10n/DEFAULT/`.
- **Mission File:** `LODP_DML` is the extracted structure of the mission. The packed mission is in `Miz files/`.

## Development Workflow
1. **Never edit `.miz` files directly to change code.** Modify the extracted `.lua` scripts located in `LODP_DML/l10n/DEFAULT/` or `Miz files/DC Template 3_Full_Map_DML/l10n/DEFAULT/` as applicable.
2. Ensure changes are strictly idiomatic to the existing Moose and custom framework code.
3. Repacking as `.miz` is done after script modifications via archiving tools.

## Key Technical Conventions

### 1. Zone-Based Configuration
Do NOT hardcode configuration values. Use trigger zone properties accessed via `dmlZone` methods:
```lua
local configZone = cfxZones.getZoneByName("moduleConfig")
local amount = configZone:getNumberFromZoneProperty("amount", 100)
local enabled = configZone:getBoolFromZoneProperty("enabled", true)
local message = configZone:getStringFromZoneProperty("message", "default")
```

### 2. Persistence Mechanism
Modules that track state MUST opt-in to persistence.
- Register modules with: `persistence.registerModule("moduleName", { persistData = module.saveData })`
- Save callbacks must return a tuple: `{ data_table, "sharedDataKey" }`

### 3. Coalitions
Use text representation for clarity: `"red"`, `"blue"`, `"neutral"`.
(Numeric codes: `0 = Neutral`, `1 = RED`, `2 = BLUE`).

### 4. Important Libraries
- `dcsCommon.lua`: Foundational utilities, group/unit lookups, DCS API patches.
- `cfxZones.lua`: Zone management OOP system.
- `persistence.lua`: Mission state serialization.
- `CTLD & Menus.lua`: Moose CTLD helicopter cargo system.

### 5. DCS Quirks to Remember
- Empty groups return `nil` for `Group.getByName()`. Use `dcsCommon` patches.
- Zone radii are sometimes stored as strings by the DCS Mission Editor.

## Instructions for Gemini CLI
- Always check `requiredLibs` before modifying module load orders.
- When creating new modules, follow the existing template structure defined in `AGENTS.md`.
- Ensure changes play nicely with the `Moose` framework and its event-driven callbacks.
