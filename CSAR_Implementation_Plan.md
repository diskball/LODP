# CSAR Implementation Plan for LODP

## Overview

This plan adds Combat Search and Rescue (CSAR) to the LODP mission using three DML modules:

| Module | Role |
|--------|------|
| **csarManager** | Core — helicopter pickup/delivery, F10 CSAR menu, player messaging |
| **autoCSAR** | Auto-generates a CSAR mission whenever any pilot ejects |
| **csarFX** | Optional — places enemy troops around downed pilots (true CSAR) |

---

## Step 1 — Download the DML Script Files

The DML GitHub repo (`csofranz/DML`) only contains documentation PDFs. The actual Lua scripts are distributed **inside DCS tutorial .miz files** on digitalcombatsimulator.com. A .miz file is a ZIP archive — open it with 7-Zip or WinRAR and extract the scripts from `l10n/DEFAULT/`.

### Files to download

**Primary source — T040 tutorial mission (contains csarManager + autoCSAR):**
- URL: https://www.digitalcombatsimulator.com/en/files/3329564/
- Download `T040 - Adding Full Feature Drop-Ins to DML.miz`
- Open as ZIP → `l10n/DEFAULT/` → extract:
  - `csarManager.lua`
  - `autoCSAR.lua`
  - `cfxPlayer.lua`
  - `nameStats.lua`
  - `cargoSuper.lua`

**Secondary source — "Marianas Universal Proving Grounds (all modules)" (contains all DML scripts including csarFX):**
- URL: https://www.digitalcombatsimulator.com/en/files/3334197/
- Download and extract `csarFX.lua` (and any other modules missing from T040)

> **Note:** Both downloads require a free DCS account login.

### Place extracted scripts
Copy all extracted `.lua` files to `Scripts/` in this repo.

---

## Step 2 — Determine Load Order

The updated initialization order for the mission (additions marked with `+`):

```
dcsCommon → cfxZones → cfxMX → bank → cfxOwnedZones → income
→ persistence → unitPersistence → commander
→ [+] cfxPlayer
→ [+] nameStats
→ [+] cargoSuper
→ [+] csarManager        ← must load BEFORE autoCSAR and csarFX
→ [+] autoCSAR
→ [+] csarFX             ← optional, omit for unconflicted SAR
→ CTLD & Menus → cfxBaseEnforcer → bankPenalties → loadzoneMarks → spawn-GC
→ mist → EWRS → AutoRestart
```

> **Rule:** csarManager must load before autoCSAR, csarFX, and limitedAirframes (if ever added).

---

## Step 3 — Add DOSCRIPT Triggers in DCS Mission Editor

Open the mission in ME → Triggers tab → add new triggers at mission start, in order:

1. Trigger: Mission Start → Do Script File → `cfxPlayer.lua`
2. Trigger: Mission Start → Do Script File → `nameStats.lua`
3. Trigger: Mission Start → Do Script File → `cargoSuper.lua`
4. Trigger: Mission Start → Do Script File → `csarManager.lua`
5. Trigger: Mission Start → Do Script File → `autoCSAR.lua`
6. (Optional) Trigger: Mission Start → Do Script File → `csarFX.lua`

Insert these triggers **after** the existing `commander` trigger and **before** `CTLD & Menus`.

---

## Step 4 — Place Trigger Zones in DCS Mission Editor

### 4.1 CSARBASE Zones (REQUIRED — one per coalition)

Place a trigger zone at each friendly airbase or FARP where rescued pilots will be delivered.

**Suggested placements for LODP (Caucasus):**
- Blue CSARBASE → Batumi or Kobuleti (main blue airfield)
- Red CSARBASE → Mozdok or Beslan (main red airfield)

**Zone attributes:**

| Attribute | Value |
|-----------|-------|
| `CSARBASE` | `blue` (or `red` for the red zone) |

Zone name can be anything (e.g., "Blue CSAR Base - Batumi"). Without a CSARBASE for each coalition, CSAR missions cannot be completed by that side.

### 4.2 csarManagerConfig Zone (REQUIRED)

Place a trigger zone anywhere (off-map is fine), name it **exactly** `csarManagerConfig`.

**Recommended attributes for LODP:**

| Attribute | Value | Notes |
|-----------|-------|-------|
| `troopCarriers` | `helos` | Allow all player helicopters to rescue |
| `useSmoke` | `true` | Pops smoke when helo approaches |
| `useFlare` | `true` | Pops flare when helo approaches (night ops) |
| `rescueRadius` | `70` | Meters — helo must land within 70m |
| `vectoring` | `true` | F10 menu shows range + bearing to pilot |
| `addPrefix` | `true` | Adds "downed" prefix to mission name |
| `timeLimit` | `60-120` | Minutes before pilot is considered MIA (optional) |

### 4.3 autoCSARConfig Zone (RECOMMENDED)

Place a trigger zone anywhere, name it **exactly** `autoCSARConfig`.

**Recommended attributes:**

| Attribute | Value | Notes |
|-----------|-------|-------|
| `red` | `true` | Auto-CSAR for red pilots |
| `blue` | `true` | Auto-CSAR for blue pilots |
| `noExploit` | `true` | No CSAR spawns within killDist of an airfield |
| `killDist` | `2100` | Meters (default, prevents CSAR abuse near airbases) |

### 4.4 csarFXConfig Zone (OPTIONAL — only if using csarFX)

Place a trigger zone anywhere, name it **exactly** `csarFXConfig`.

| Attribute | Value | Notes |
|-----------|-------|-------|
| `congregateOnSmoke` | `true` | Enemies move toward pilot when smoke pops |

### 4.5 Pre-placed CSAR Zones (OPTIONAL)

To add a downed pilot present at mission start (e.g., for a scripted scenario):

Place a trigger zone where you want the pilot, add these attributes:

| Attribute | Value | Notes |
|-----------|-------|-------|
| `CSAR` | `Lt. Wesley Crasher` | Pilot name (or `*rnd` for random, requires `names.lua`) |
| `coalition` | `blue` | Which side needs to rescue this pilot |
| `deferred` | `false` | `true` = only spawns when triggered by flag |
| `timeLimit` | `90` | Minutes (optional) |

**If using csarFX**, also add to the same zone:

| Attribute | Value | Notes |
|-----------|-------|-------|
| `enemies` | `Soldier M4, Soldier RPG, Soldier AK` | Enemy types to spawn near pilot |
| `strength` | `3-6` | Number of enemies |
| `range` | `1-2` | Km from pilot — keep >0.5 so they don't instant-capture |
| `debris` | `A-10A, F-16C bl.50` | Wreck placed ~1km away |

---

## Step 5 — Copy Scripts to Miz and Repack

1. Copy all new `.lua` files from `Scripts/` into:
   `Miz files/LODP_DML_1_0_Full_Map - Copy/l10n/DEFAULT/`

2. Repack that folder back into `LODP_DML_1_0_Full_Map.miz` (ZIP format).

---

## Step 6 — Test In-Game

1. Load the mission in DCS as server host.
2. Spawn a player aircraft and **eject** — this triggers autoCSAR.
3. Open F10 → Other menu → verify CSAR mission appears with bearing + range.
4. Spawn a helicopter (Mi-8, UH-1H, or similar) and fly to the downed pilot.
5. Watch for smoke + flare at ~2km range.
6. Land within 70m of the pilot — F10 menu should show "pick up" option.
7. Fly to your coalition's CSARBASE zone and land — mission completes.

---

## Notes on Compatibility with Existing CTLD

- csarManager uses `cargoSuper` (its own cargo system), **not** CTLD's cargo mechanism. The two do not conflict.
- Player helos can do both CTLD troop transport and csarManager rescues independently.
- The CSAR F10 menu installs at **F10 → Other**, same level as CTLD's menu. If this gets crowded, you can use `attachTo:` in csarManagerConfig to push CSAR under a radioMenus submenu.

---

## Module Summary

```
Required scripts to add to Scripts/:
  cfxPlayer.lua       (DML dependency)
  nameStats.lua       (DML dependency)
  cargoSuper.lua      (DML dependency)
  csarManager.lua     (CSAR core)
  autoCSAR.lua        (auto-generate on eject)
  csarFX.lua          (optional: enemies around pilot)

Required trigger zones in ME:
  CSARBASE            (one per coalition, at airbases)
  csarManagerConfig   (global config)
  autoCSARConfig      (auto-eject config)

Optional zones:
  csarFXConfig        (enemy config)
  CSAR zones          (pre-placed downed pilots)
```

---

## Sources

- DML Documentation: [DML_Doc.md](Scripts/DML_Doc.md) — sections 5.4.3 (csarManager), 5.4.4 (autoCSAR), 5.5.2 (csarFX)
- DML Forum Thread: [ED Forums — DML Mission Creation Toolbox](https://forum.dcs.world/topic/290975-dml-mission-creation-toolbox-no-lua-required)
- T040 Tutorial Mission (contains scripts): [digitalcombatsimulator.com/en/files/3329564/](https://www.digitalcombatsimulator.com/en/files/3329564/)
- All-modules mission (contains csarFX): [digitalcombatsimulator.com/en/files/3334197/](https://www.digitalcombatsimulator.com/en/files/3334197/)
- DML GitHub (docs only): [github.com/csofranz/DML](https://github.com/csofranz/DML)
