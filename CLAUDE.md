# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LODP is a persistent DCS World PvP mission framework for cooperative territorial warfare (RED vs BLUE) on the Caucasus map. It is built on **Lua (5.1)** scripting loaded by DCS World, the **Moose** framework (March 2026 build), and 11 custom modules. For comprehensive architecture and convention details, see [AGENTS.md](AGENTS.md).

## Development Workflow

The mission is distributed as a `.miz` file, which is a ZIP archive:

1. Extract `Miz files/LODP_DML.miz` into `LODP_DML/`
2. Edit Lua scripts in [LODP_DML/l10n/DEFAULT/](LODP_DML/l10n/DEFAULT/)
3. Repack `LODP_DML/` back into a `.miz` ZIP archive
4. Load in DCS World and test — persistence is verified by saving in-mission, then loading fresh

There is no automated test suite. All testing is manual in DCS World.

## Python Telemetry Tools

These run **outside** DCS against the [DCS-gRPC](https://github.com/DCS-gRPC/rs-grpc) server (default port `50051`):

```bash
# Compile proto stubs (run once, or after proto changes)
python compile_protos.py

# Full event listener: slot-in/takeoff/land/shot/hit via UDP:9876 + kills/guns via gRPC
python Exports/listener.py

# Legacy kill-only logger
python dcs_grpc_kill_logger.py
```

`Exports/listener.py` writes to `Exports/dcs_events.db` (SQLite). `dcs_grpc_kill_logger.py` writes to `dcs_kills.db`. Proto stubs are generated into `protos/`.

## Architecture

### Initialization Order (matters — modules depend on earlier ones)

```
dcsCommon → cfxZones → cfxMX → bank → cfxOwnedZones → income
→ persistence → unitPersistence → commander → CTLD & Menus
```

### Territory & Victory System (`cfxOwnedZones_modified.lua`)

Zone ownership has four states: `RED`, `BLUE`, `CONTESTED` (both coalitions present), `NEUTRAL` (neither). Victory triggers a 5-minute countdown when one coalition controls all zones; capturing any zone cancels it.

### Economics (`bank.lua` + `income.lua`)

`bank` manages coalition fund accounts (configured via `bankConfig` trigger zone). `income` ticks on a timer and deposits funds per owned zone (configured via `incomeConfig` trigger zone). Aircraft loss penalties are deducted from the owning coalition's account.

### Persistence (`persistence.lua` + `unitPersistence.lua`)

Modules opt in by calling `persistence.registerModule()` with a save callback that returns `{ dataTable, sharedDataKey }`. On load, callbacks restore state and emit version warnings if data predates the current module version. The DCS server must desanitize `lfs` and `io` for file I/O to work.

### Zone-Based Configuration

**All gameplay configuration lives in DCS Mission Editor trigger zones — never hardcoded.** Read zone properties like:

```lua
local cfg = cfxZones.getZoneByName("moduleConfig")
local rate = cfg:getNumberFromZoneProperty("rate", 100)
local on   = cfg:getBoolFromZoneProperty("enabled", true)
```

Standard config zones: `bankConfig`, `incomeConfig`, `CommanderConfig`.

## Lua Conventions

### New Module Template

```lua
myModule = {}
myModule.version = "1.0.0"
myModule.requiredLibs = { "dcsCommon", "cfxZones" }

function myModule.saveData()
    return { myModule.state }, "myModuleKey"
end

persistence.registerModule("myModule", { persistData = myModule.saveData })

function myModule.start()
    timer.scheduleFunction(myModule.update, {}, 1.0)
end
```

### Coalition Coding

Numeric: `0 = Neutral`, `1 = RED`, `2 = BLUE`. Text: `"neutral"`, `"red"`, `"blue"`. Both forms appear throughout — conversion is handled internally.

### OOP Pattern

```lua
dmlZone = {}
function dmlZone:new(o)
    setmetatable(o, self); self.__index = self; return o
end
```

## Known DCS Quirks

- `Group.getByName()` returns `nil` for empty groups — `dcsCommon` patches this.
- Zone radius is sometimes a string, not a number — `cfxZones` handles the cast.
- DCS 2.9 has table-cloning issues — use the `deepCopy()` alternative provided in `dcsCommon`.
- Coalition values from `env.mission` use numeric codes; DCS runtime APIs use text — both need handling.
