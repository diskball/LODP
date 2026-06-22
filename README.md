# LODP: DCS Dynamic Playground PvP

**LODP** (Logistics/Operational Dynamics Persistent) is a dynamic PvP mission for DCS World set in the **Caucasus** theatre, featuring persistent territorial warfare, coalition economics, individual player scoring, and advanced logistics mechanics.

## About

Created by **=GR= Diskball** with contributions from **=GR= Jackal** and **=GR= Panthir**.

This is a sophisticated multiplayer mission framework designed for cooperative territorial control gameplay with:

- **Persistent Progression** — Mission state survives server restarts
- **Territory Control System** — RED vs BLUE coalitions compete for zone control
- **Dual Economy** — Coalition bank (§) for logistics purchases, personal score (pts) for sortie costs
- **Sortie Cost System** — Aircraft and weapon fees charged at takeoff; unused weapons refunded on landing
- **Unit Persistence** — Ground, air, and ship units maintain state across sessions
- **Advanced Logistics** — Helicopter cargo transport and supply management via Moose CTLD
- **Automated Commander System** — Pathfinding and group automation with road/off-road routing
- **MOB Defences** — AI garrison groups spawn at Main Operating Bases on capture

## Getting Started

### Mission File
The compiled mission is located at:
```
Miz files/LODP_DML_2_0_Bubble.miz
```

### Development
For mission editing and scripting:
1. Edit canonical Lua scripts in `Scripts/`
2. Copy changed scripts into the extracted miz at `Miz files/LODP_DML_2_0_Bubble - Copy/l10n/DEFAULT/`
3. Repack the folder back into `LODP_DML_2_0_Bubble.miz` (ZIP format)
4. Load the mission in DCS World to test

See [CLAUDE.md](CLAUDE.md) and [AGENTS.md](AGENTS.md) for detailed development guidance.

## Architecture

Scripts load in this order at mission start:

```
dcsCommon → cfxZones → cfxMX → bank → cfxOwnedZones → income
→ persistence → unitPersistence → commander → CTLD & Menus (refactored)
→ cfxBaseEnforcer → bankPenalties → armamentCost → mobDefences
→ loadzoneMarks → spawn-GC → mist → EWRS → AutoRestart
```

### Module Reference

| Module | Folder | Role |
|--------|--------|------|
| `dcsCommon.lua` | DML | Foundational utilities & DCS API patches |
| `cfxZones.lua` | DML | OOP zone system (circular & polygon) |
| `cfxMX.lua` | DML | Mission data decoder |
| `cfxOwnedZones_modified.lua` | DML | Territory ownership & victory conditions |
| `bank.lua` | DML | Coalition fund accounts |
| `income.lua` | DML | Territory-based income generation |
| `commander.lua` | DML | Group automation & pathfinding |
| `persistence.lua` | DML | Save/load callbacks & version checking |
| `unitPersistence.lua` | DML | Unit position/state restoration |
| `cfxBaseEnforcer.lua` | DML | Kicks players who spawn/land at enemy bases |
| `bankPenalties.lua` | DML | Safe-landing bank bonus; base-violation penalties |
| `armamentCost.lua` | DML | Sortie fees (aircraft + weapons) charged at takeoff |
| `mobDefences.lua` | DML | Spawns AI defence groups at MOB zones |
| `loadzoneMarks.lua` | DML | F10 map marks for CTLD loadzones |
| `spawn-GC.lua` | DML | F10 map mark commands (`explode`, `spawn-<Group>`) |
| `CTLD & Menus_refactored.lua` | CTLD & Menus | Moose CTLD helicopter cargo system |
| `cfxPlayerScore.lua` | CTLD & Menus | Per-player score economy & kill rewards |
| `cfxScoreTable.lua` | CTLD & Menus | Score table display helpers |
| `mist_4_5_128.lua` | MIST | MIST framework (required by EWRS) |
| `EWRS_v11.8.6.lua` | Others | Early Warning Radar System |
| `AutoRestart.lua` | Others | Schedules server restart at 5 hours |
| `Moose_ (2).lua` | Moose | Third-party Moose framework (March 2026) |

## Key Features

### Territory Control
- Circular and polygonal zones support ownership tracking
- Contested zones when both coalitions have units present
- Victory conditions: hold all 6 MOBs for 5 minutes
- Dynamic zone visualization with F10 map smoke markers

### Dual Economy System

**Coalition Bank (§)** — shared funds for the whole team:
- Starting balance: §10,000 per side
- Income generated every 30 minutes from controlled zones and factories
- Used to purchase CTLD units (troops, vehicles, SAMs)
- §10 bonus deposited when a friendly fixed-wing lands safely at a friendly base

**Player Score (pts)** — individual currency per pilot:
- Starting score: 200 pts per player (configurable via `playerScoreConfig` zone)
- Kill rewards accumulate during a sortie and post on safe landing
- §2 per score point is also deposited into the coalition bank on landing
- Spent on sortie costs (aircraft fee + weapon costs) at every takeoff

### Sortie Cost System
- **Aircraft fee**: charged at takeoff from any non-Main-Base; refunded on safe landing
- **Weapon costs**: charged per weapon loaded; unused weapons on the rails are refunded on landing
- **90-second warning**: if score is insufficient on takeoff, land and reduce loadout to cancel; stay airborne and you're moved to spectators
- **F10 Menu → Armament → Check Loadout Cost**: previews your full sortie cost before takeoff
- Main Bases (Anapa for RED, Tbilisi for BLUE) are always free to take off from

### Kill Rewards
- Air kills during a sortie are held as *pending* score until safe landing
- Ground/ship kills from Combined Arms score immediately
- Fratricide applies a ×−5 multiplier to the killer's personal score
- Aircraft loss (crash/eject/death) costs −50 pts personal score; coalition bank unaffected

### MOB Defences
- AI defence groups spawn at each MOB zone on mission start
- Groups respawn when a MOB changes ownership

### Persistence
- Automatic save/load of mission state across server restarts
- Module registration system with version checking
- Ground unit position restoration
- Bank balances recovered across restarts

### Logistics (CTLD)
- Moose CTLD helicopter cargo system
- Loadable troops and vehicles (infantry, armor, SAMs, FARP support)
- Zone-based cargo operations at named Loadzones
- Multi-airframe support: UH-1H, UH-60L, Mi-8, Mi-24P, CH-47Fbl1, C-130J-30
- Combat-only airframes: AH-64D, OH-58D (Kiowa)

## Configuration

All gameplay settings are configured via **trigger zones** in the mission editor:

| Zone Name | Module | Purpose |
|-----------|--------|---------|
| `bankConfig` | bank | Coalition starting funds |
| `incomeConfig` | income | Income rates and messaging |
| `CommanderConfig` | commander | Pathfinding behaviour |
| `playerScoreConfig` | cfxPlayerScore | Starting score, kill reward multipliers |
| `armamentCostConfig` | armamentCost | Aircraft fees, kick delay, weapon cost overrides |
| `bankPenaltyConfig` | bankPenalties | Safe-landing bonus amount |

See [AGENTS.md](AGENTS.md) for detailed configuration patterns and zone property reference.

## Technical Details

- **Framework**: Moose (March 2026 build) + custom Lua modules
- **Language**: Lua (DCS LuaJIT — Lua 5.1 compatible only)
- **Map**: Caucasus
- **Module System**: Dynamic loading with version checking and `requiredLibs` declarations
- **Data Persistence**: File-based save/load with registered callbacks

## Contributors

- **Creator**: =GR= Diskball
- **Contributors**: =GR= Jackal, =GR= Panthir

---

*Version: LODP DML 2.0 • Last updated: June 2026*
