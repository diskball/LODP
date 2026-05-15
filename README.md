# LODP: DCS Dynamic Playground PvP

**LODP** (Logistics/Operational Dynamics Persistent) is a dynamic PvP mission for DCS World set in the **Caucasus** theatre, featuring persistent territorial warfare, coalition economics, and advanced logistics mechanics.

## About

Created by **=GR= Diskball** with contributions from **=GR= Jackal** and **=GR= Panthir**.

This is a sophisticated multiplayer mission framework designed for cooperative territorial control gameplay with:

- **Persistent Progression** — Mission state survives server restarts
- **Territory Control System** — RED vs BLUE coalitions compete for zone control
- **Coalition Economics** — Dynamic income generation based on zone ownership
- **Unit Persistence** — Ground, air, and ship units maintain state across sessions
- **Advanced Logistics** — Helicopter cargo transport and supply management via Moose CTLD
- **Automated Commander System** — Pathfinding and group automation with road/off-road routing

## Getting Started

### Mission File
The compiled mission is located at:
```
Miz files/LODP_DML_1_0_Full_Map.miz
```

### Development
For mission editing and scripting:
1. Extract `LODP_DML.miz` (it's a ZIP archive)
2. Edit Lua scripts in `l10n/DEFAULT/`
3. Modify mission data in the `mission` file using DCS Mission Editor
4. Repack and test in DCS World

See [AGENTS.md](AGENTS.md) for detailed development guidance.

## Architecture

The mission is built on **11 core Lua modules**:

| Module | Role |
|--------|------|
| dcsCommon | Foundational utilities & DCS API patches |
| cfxZones | Zone management system (OOP) |
| cfxMX | Mission data decoder |
| cfxOwnedZones | Territory ownership & victory conditions |
| bank | Coalition fund management |
| income | Territory-based income generation |
| commander | Group automation & pathfinding |
| persistence | Mission state serialization |
| unitPersistence | Unit position/state restoration |
| CTLD & Menus | Helicopter cargo transport system |
| Moose | Framework integration (March 2026) |

## Key Features

### Territory Control
- Circular and polygonal zones support ownership tracking
- Contested zones when both coalitions present
- Victory conditions with configurable timers
- Dynamic zone visualization with smoke markers

### Economics System
- Coalition bank accounts with starting balances
- Income generation from controlled zones
- Configurable income rates and intervals
- Player notifications of economic events

### Persistence
- Automatic save/load of mission state
- Module registration system with version checking
- Ground unit position restoration
- Bank balance recovery across server restarts

### Logistics
- Moose CTLD helicopter cargo system
- Loadable troops and vehicles (infantry, armor, SAMs, FARP support)
- Zone-based cargo operations at loadzones
- Multiple airframe support: UH-1H, UH-60L, Mi-8MTV2, Mi-24P, CH-47Fbl1
- Combat-only airframes: AH-64D, OH-58D (Kiowa)

## Configuration

All gameplay settings are configured via **trigger zones** in the mission editor:

- `bankConfig` — Coalition starting funds
- `incomeConfig` — Income rates and messaging
- `CommanderConfig` — Pathfinding behavior
- Custom zones for module-specific settings

See [AGENTS.md](AGENTS.md) for detailed configuration patterns.

## Technical Details

- **Framework**: Moose (March 2026 build) + custom Lua modules
- **Language**: Lua (DCS mission scripting)
- **Map**: Caucasus
- **Module System**: Dynamic loading with version checking
- **Data Persistence**: File-based save/load with callbacks

## Development Notes

- All configuration should be zone-based (no hardcoding values)
- Update module versions when making breaking changes
- Module dependencies are declared via `requiredLibs`
- Persistence callbacks must return `{ dataTable, sharedDataKey }`
- Test persistence by loading fresh mission instances

## Support

For mission editing assistance, refer to:
- [AGENTS.md](AGENTS.md) — Comprehensive AI agent guide with patterns and conventions
- Individual module files in `l10n/DEFAULT/` for implementation details

## Contributors

- **Creator**: =GR= Diskball
- **Contributors**: =GR= Jackal, =GR= Panthir

---

*Version: LODP DML 1.0 • Last updated: May 15, 2026*
