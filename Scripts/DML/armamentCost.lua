--[[
armamentCost.lua
Version: 1.5.0

PURPOSE:
Charges individual player score (cfxPlayerScore) per sortie when taking off from
a forward (non-Main-Base) airfield. Two cost components apply at takeoff:

  1. AIRCRAFT FEE  — charged for the platform at any non-Main-Base zone.
     Refunded when the aircraft lands safely. If the aircraft is lost (crash /
     eject / disconnect in flight), the fee is NOT refunded.

  2. WEAPON COSTS  — charged per weapon carried at takeoff. On landing, the cost
     of weapons still on the rails is refunded (expended weapons are not refunded).
     If the aircraft is lost, weapon costs are NOT refunded.
     Taking off again charges for whatever weapons are loaded at that time.

BEHAVIOUR:
- On TAKEOFF : deduct (aircraft fee + weapon costs) from player score immediately.
              If unaffordable → warn + 90-second kick countdown.
- On LAND    : refund the aircraft fee + cost of weapons still on the rails.
              If a kick was pending (re-armed in time), cancel it.
- On DEAD / CRASH / EJECT : clear pending refunds (aircraft and weapons lost).

F10 RADIO MENU:
  "Armament > Check Loadout Cost" added per group on spawn.
  Shows aircraft fee, known weapon costs, and any UNRECOGNISED weapons with
  their raw DCS typeName — copy those names into weaponCosts to start charging.

SPAWN FEE (cfxBaseEnforcer):
  The birth-event spawn fee is disabled in cfxBaseEnforcer. armamentCost handles
  the aircraft cost at takeoff instead.

CONFIGURATION:
  All scalar settings overridable via an "armamentCostConfig" trigger zone.
  Per-weapon costs are hardcoded in the weaponCosts table below.

DEPENDENCIES:
  dcsCommon, cfxZones, cfxPlayerScore
  cfxOwnedZones (optional — for Main Base detection)
  bankPenalties  (optional — for aircraft tier categorisation)
--]]

armamentCost = {}
armamentCost.version      = "1.5.0"
armamentCost.requiredLibs = { "dcsCommon", "cfxZones", "cfxPlayerScore" }

armamentCost.enabled           = true
armamentCost.kickDelay         = 90   -- seconds to land before kick
armamentCost.unknownWeaponCost = 0    -- cost for unrecognised weapons (0 = free)
armamentCost.verbose           = true

-- ─── AIRCRAFT FEE ─────────────────────────────────────────────────────────────
-- Charged on takeoff at non-Main-Base zones. Refunded on safe landing.
armamentCost.chargeAircraftFee    = true
armamentCost.mainBaseType         = "MAIN BASE"
armamentCost.aircraftSearchRadius = 3000         -- metres, same as cfxBaseEnforcer
armamentCost.aircraftCostFallback = 75
armamentCost.aircraftCosts = {
    modernMultirolePlane = 400,
    coldWarBomberPlane   = 175,
    attackHeli           = 50,
    transportHeli        = 25,
}

-- ─── WEAPON COST TABLE ────────────────────────────────────────────────────────
-- Keys  : short DCS typeName (prefix stripped — "weapons.missiles.AGM_114K" → "AGM_114K").
--         verbose=true logs unrecognised typeNames to DCS.log AND the F10 menu.
-- Values: score points deducted PER weapon of that type at takeoff.
-- Notes : ↔ comments mark US/Russian pairs intentionally priced the same tier.
armamentCost.weaponCosts = {

    -- ── HELICOPTER ATGMs ──────────────────────────────────────────────────────
    ["AGM_114K"]         = 45,   -- AGM-114K Hellfire II (laser seeker)
    ["AGM_114"]          = 55,   -- AGM-114L Longbow Hellfire (MMW radar) [DCS typeName IS "AGM_114"]
    ["AGM_114M"]         = 45,   -- AGM-114M Hellfire Blast-Frag
    ["AGM_114R"]         = 50,   -- AGM-114R Hellfire Romeo (dual-mode)
    ["Vikhr_M"]          = 45,   -- 9A4172 Vikhr-M / Ka-50, Ka-52     ↔ AGM-114K
    ["9M120"]            = 45,   -- 9M120 Ataka / Mi-28N               ↔ AGM-114K
    ["Ataka_9M120F"]     = 45,   -- 9M120F Ataka-F variant
    ["Shturm_9M114"]     = 30,   -- 9M114 Shturm / Mi-24V (older ATGM)
    ["HOT3"]             = 35,   -- HOT 3 / Tiger UHT, Gazelle
    ["HOT2T"]            = 30,   -- HOT-2T

    -- ── MAVERICKS ─────────────────────────────────────────────────────────────
    ["AGM_65D"]          = 20,   -- Maverick D  (IR seeker)          ↔ Kh-29T
    ["AGM_65E"]          = 20,   -- Maverick E  (laser seeker)       ↔ Kh-29L
    ["AGM_65F"]          = 20,   -- Maverick F  (IR enhanced)
    ["AGM_65G"]          = 20,   -- Maverick G  (IR, heavy WH)       ↔ Kh-29TE
    ["AGM_65H"]          = 20,   -- Maverick H  (CCD seeker)
    ["AGM_65K"]          = 20,   -- Maverick K  (CCD, heavy WH)
    ["AGM_65L"]          = 20,   -- Maverick L  (laser, heavy WH)

    -- ── HARM / ANTI-RADIATION (US) ────────────────────────────────────────────
    ["AGM_88"]           = 55,   -- AGM-88A/B HARM                   ↔ Kh-58U / Kh-31P
    ["AGM_88C"]          = 55,   -- AGM-88C HARM Block 5             ↔ Kh-58E / Kh-31PD
    ["AGM_45"]           = 0,   -- AGM-45 Shrike (old anti-radiation)
    ["AGM_122"]          = 0,   -- AGM-122 Sidearm (AV-8B)

    -- ── JSOW ──────────────────────────────────────────────────────────────────
    ["AGM_154A"]         = 30,   -- AGM-154A JSOW (submunitions, GPS)
    ["AGM_154C"]         = 55,   -- AGM-154C JSOW (unitary, GPS + IIR)

    -- ── RUSSIAN AGM / ANTI-RADIATION ─────────────────────────────────────────
    ["Kh_25ML"]          = 20,   -- Kh-25ML  (laser)                ↔ GBU-12 tier
    ["Kh_25MR"]          = 20,   -- Kh-25MR  (radar seeker)
    ["Kh_25MP"]          = 20,   -- Kh-25MP  (anti-radiation)
    ["Kh_25MPU"]         = 35,   -- Kh-25MPU (anti-radiation, upgraded)
    ["Kh_29L"]           = 20,   -- Kh-29L   (laser)                ↔ AGM-65E
    ["Kh_29T"]           = 20,   -- Kh-29T   (TV seeker)            ↔ AGM-65D
    ["Kh_29TE"]          = 20,   -- Kh-29TE  (enhanced TV)          ↔ AGM-65G
    ["Kh_31A"]           = 20,   -- Kh-31A   (anti-ship supersonic)
    ["Kh_31P"]           = 20,   -- Kh-31P   (anti-radiation)       ↔ AGM-88
    ["Kh_31PD"]          = 20,   -- Kh-31PD  (anti-radiation enhanced) ↔ AGM-88C
    ["Kh_35"]            = 20,   -- Kh-35    (anti-ship cruise)
    ["Kh_35UE"]          = 20,   -- Kh-35UE  (upgraded)
    ["Kh_58U"]           = 20,   -- Kh-58U   (anti-radiation)       ↔ AGM-88
    ["Kh_58E"]           = 20,   -- Kh-58E   (anti-radiation enhanced) ↔ AGM-88C
    ["Kh_59M"]           = 20,   -- Kh-59M   (TV cruise missile, long-range)

    -- ── SHORT-RANGE IR AAM: 1950s–60s ─────────────────────────────────────────
    ["AIM_9B"]           = 0,    -- AIM-9B Sidewinder (front-aspect only)
    ["AIM_9D"]           = 0,    -- AIM-9D Sidewinder
    ["AIM_9J"]           = 0,    -- AIM-9J Sidewinder
    ["R_3S"]             = 0,    -- R-3S (copy of AIM-9B)           ↔ AIM-9B
    ["R_3R"]             = 8,    -- R-3R (radar-guided variant)
    ["R_13M"]            = 0,   -- R-13M (MiG-21 era)
    ["R_13M1"]           = 0,   -- R-13M1 (improved)
    ["R_55"]             = 0,    -- RS-2US (MiG-19 beam-rider)

    -- ── SHORT-RANGE IR AAM: MODERN ────────────────────────────────────────────
    ["AIM_9P"]           = 0,   -- AIM-9P Sidewinder P             ↔ R-60
    ["AIM_9P3"]          = 0,   -- AIM-9P3
    ["AIM_9P5"]          = 0,   -- AIM-9P5 (upgraded)
    ["R_60"]             = 0,   -- R-60    (no fuze upgrade)        ↔ AIM-9P
    ["R_60M"]            = 0,   -- R-60M   (proximity fuze)        ↔ AIM-9L
    ["AIM_9L"]           = 0,   -- AIM-9L  (all-aspect IR)         ↔ R-60M
    ["AIM_9M"]           = 0,   -- AIM-9M  (IRCCM, snap-turn)      ↔ R-73
    ["R_73"]             = 0,   -- R-73    (IRCCM, thrust-vector)  ↔ AIM-9M
    ["AIM_9X"]           = 20,   -- AIM-9X  (HOBS + datalink, top-tier)

    -- ── MEDIUM-RANGE AAM: SEMI-ACTIVE RADAR ──────────────────────────────────
    ["AIM_7D"]           = 10,   -- AIM-7D Sparrow D
    ["AIM_7E"]           = 10,   -- AIM-7E Sparrow E
    ["AIM_7E2"]          = 10,   -- AIM-7E-2 Sparrow E2
    ["AIM_7F"]           = 10,   -- AIM-7F  Sparrow F               ↔ R-23R / R-24R
    ["AIM_7M"]           = 10,   -- AIM-7M  Sparrow M               ↔ R-27R
    ["AIM_7MH"]          = 10,   -- AIM-7MH Sparrow MH              ↔ R-27T
    ["AIM_7P"]           = 20,   -- AIM-7P  Sparrow P               ↔ R-27ER
    ["R_23R"]            = 10,   -- R-23R   (semi-active)           ↔ AIM-7F
    ["R_23T"]            = 10,   -- R-23T   (IR version)
    ["P_24R"]            = 10,   -- R-24R   (semi-active, MiG-23/25) ↔ AIM-7F
    ["P_24T"]            = 10,   -- R-24T   (IR version)
    ["R_27R"]            = 10,   -- R-27R   (semi-active)           ↔ AIM-7M
    ["R_27T"]            = 10,   -- R-27T   (IR seeker)             ↔ AIM-7MH
    ["R_27ER"]           = 20,   -- R-27ER  (extended range SARH)   ↔ AIM-7P
    ["R_27ET"]           = 20,   -- R-27ET  (extended range IR)
    -- MiG-25 legacy long-range SARH
    ["R_4R"]             = 10,   -- R-4R  (MiG-25, old)
    ["R_4T"]             = 10,   -- R-4T  (MiG-25 IR, old)
    ["R_40R"]            = 10,   -- R-40R (MiG-25, upgraded SARH)
    ["R_40T"]            = 10,   -- R-40T (MiG-25, IR upgraded)
    -- European SARH equivalents
    ["Super_530D"]       = 10,   -- Super 530D (Mirage 2000C)       ↔ AIM-7M
    ["Super_530F"]       = 10,   -- Super 530F (Mirage F1)          ↔ AIM-7F
    ["Skyflash"]         = 10,   -- Skyflash  (Tornado / Phantom UK) ↔ AIM-7M
    ["Rb71"]             = 10,   -- Rb 71 Skyflash (AJS37 Viggen)   ↔ AIM-7M

    -- ── BEYOND-VISUAL-RANGE AAM: ACTIVE RADAR ────────────────────────────────
    ["AIM_120B"]         = 26,   -- AIM-120B AMRAAM                 ↔ R-77
    ["AIM_120C"]         = 55,   -- AIM-120C AMRAAM C               ↔ R-77-1
    ["AIM_120C_5"]       = 55,   -- AIM-120C-5 AMRAAM               ↔ R-77-1
    ["R_77"]             = 55,   -- R-77 Adder (active BVR)         ↔ AIM-120B
    ["R_77_1"]           = 55,   -- R-77-1 (improved)               ↔ AIM-120C
    ["SD_10"]            = 55,   -- PL-12 / SD-10 (JF-17)          ↔ AIM-120B
    ["PL_12"]            = 55,   -- PL-12 alternate typeName

    -- ── LONG-RANGE AAM: PHOENIX (F-14) ───────────────────────────────────────
    ["AIM_54A_Mk47"]     = 30,   -- AIM-54A Phoenix (Mk47 motor)
    ["AIM_54A_Mk60"]     = 30,   -- AIM-54A Phoenix (Mk60 motor)
    ["AIM_54C_Mk47"]     = 30,   -- AIM-54C Phoenix C

    -- ── SHORT-RANGE IR AAM: EUROPEAN / OTHER ─────────────────────────────────
    ["Magic_2"]              = 0,   -- R550 Magic 2 (Mirage 2000/F1)   ↔ AIM-9M / R-73
    ["Matra_R550_Magic_2"]   = 0,   -- alternate DCS typeName
    ["R_550_Magic_2"]        = 0,   -- alternate DCS typeName
    ["Rb24J"]            = 0,   -- Rb 24J (AJS37 Viggen)           ↔ AIM-9L
    ["Rb74"]             = 0,   -- Rb 74  (AJS37 Viggen)           ↔ AIM-9M
    ["Mistral"]          = 0,   -- Mistral MANPADS (SA342)         ↔ R-60M
    ["PL_5EII"]          = 0,   -- PL-5EII (JF-17)                ↔ AIM-9P

    -- ── LASER-GUIDED BOMBS ───────────────────────────────────────────────────
    ["GBU_12"]           = 0,   -- GBU-12 Paveway II 500 lb        ↔ Kh-25ML
    ["GBU_16"]           = 0,   -- GBU-16 Paveway II 1000 lb       ↔ Kh-29L
    ["GBU_10"]           = 0,   -- GBU-10 Paveway II 2000 lb
    ["GBU_24"]           = 0,   -- GBU-24 Paveway III 2000 lb
    ["GBU_27"]           = 0,   -- GBU-27 (penetrator LGB)

    -- ── JDAM (GPS-GUIDED) ────────────────────────────────────────────────────
    ["GBU_38"]           = 20,   -- GBU-38 JDAM  500 lb
    ["GBU_32"]           = 25,   -- GBU-32 JDAM 1000 lb
    ["GBU_31"]           = 30,   -- GBU-31 JDAM 2000 lb
    ["GBU_31_V_2B"]      = 30,   -- GBU-31 JDAM Mk84
    ["GBU_31_V_2_B"]     = 30,   -- alternate DCS typeName variant
    ["GBU_31_V_3B"]      = 35,   -- GBU-31 BLU-109 penetrator JDAM
    ["GBU_31_V_4B"]      = 35,   -- GBU-31 V4 JDAM
    ["GBU_31_V_4_B"]     = 35,   -- alternate DCS typeName variant
    ["GBU_54"]           = 30,   -- GBU-54 LJDAM (laser + GPS)

    -- ── CLUSTER BOMBS ────────────────────────────────────────────────────────
    ["CBU_87"]           = 0,   -- CBU-87 CEM cluster
    ["CBU_97"]           = 10,   -- CBU-97 SFW (sensor-fuzed, very effective)
    ["CBU_103"]          = 10,   -- CBU-103 CEM + WCMD
    ["CBU_105"]          = 25,   -- CBU-105 SFW + WCMD
    ["KMGU_2"]           = 12,   -- KMGU-2 submunitions dispenser   ↔ CBU tier

    -- ── UNGUIDED US BOMBS ────────────────────────────────────────────────────
    ["Mk_82"]            = 0,    -- Mk 82   500 lb                  ↔ FAB-100/250
    ["Mk_82SE"]          = 0,    -- Mk 82 Snake Eye
    ["Mk_82AIR"]         = 0,    -- Mk 82 AIR (retarded)
    ["Mk_83"]            = 0,    -- Mk 83  1000 lb                  ↔ FAB-250
    ["Mk_84"]            = 0,   -- Mk 84  2000 lb                  ↔ FAB-500
    ["BLU_107"]          = 0,   -- BLU-107 Durandal (anti-runway)
    ["MK_77"]            = 0,    -- Mk 77 napalm canister

    -- ── UNGUIDED RUSSIAN BOMBS ───────────────────────────────────────────────
    ["FAB_100"]          = 0,    -- FAB-100  (~500 lb class)        ↔ Mk 82
    ["FAB_250"]          = 0,    -- FAB-250  (~1000 lb class)       ↔ Mk 83
    ["FAB_500"]          = 0,   -- FAB-500  (~2000 lb class)       ↔ Mk 84
    ["FAB_500M62"]       = 0,   -- FAB-500 M62 variant
    ["FAB_500_M62"]      = 0,   -- alternate DCS typeName
    ["BETAB_500"]        = 0,   -- BetAB-500 (concrete penetrating)
    ["BETAB_500ShP"]     = 0,   -- BetAB-500ShP

    -- ── US ROCKETS ───────────────────────────────────────────────────────────
    ["Hydra_70_M151"]    = 0,    -- Hydra 70 HEAT
    ["Hydra_70_M229"]    = 0,    -- Hydra 70 HE
    ["Hydra_70_M257"]    = 0,    -- Hydra 70 Illumination
    ["Hydra_70_M274"]    = 0,    -- Hydra 70 Smoke
    ["FFAR_Mk5_HEAT"]    = 0,    -- FFAR Mk 5 HEAT
    ["Zuni_127"]         = 0,    -- Zuni 5" rocket                  ↔ S-13 tier

    -- ── RUSSIAN ROCKETS ──────────────────────────────────────────────────────
    ["S_5KO"]            = 0,    -- S-5KO  57mm                     ↔ Hydra 70
    ["S_5M"]             = 0,    -- S-5M   57mm
    ["S_5MO"]            = 0,    -- S-5MO  57mm
    ["S_5P"]             = 0,    -- S-5P   57mm
    ["S_8KOM"]           = 0,    -- S-8KOM  80mm
    ["S_8OFP2"]          = 0,    -- S-8OFP2 80mm
    ["S_13OF"]           = 0,    -- S-13OF  122mm                   ↔ Zuni
    ["S_13T"]            = 0,    -- S-13T   122mm
    ["S_13OFBT"]         = 0,    -- S-13OFBT
    ["S_24B"]            = 0,    -- S-24B   240mm (large unguided)
    ["S_25OFM"]          = 0,   -- S-25OFM 340mm (very large)
    ["S_25L"]            = 0,   -- S-25L   340mm laser-guided
}

-- ─── STATE ────────────────────────────────────────────────────────────────────

armamentCost.kickGeneration        = {}  -- { [playerName] = number }
armamentCost.hasWarning            = {}  -- { [playerName] = true }
armamentCost.pendingAircraftRefund = {}  -- { [playerName] = number } — refund on safe landing
armamentCost.pendingWeaponRefund   = {}  -- { [playerName] = number } — max weapon refund on safe landing
armamentCost.groupMenus            = {}  -- { [groupID]    = { root, cmd, groupName } }

-- ─── LOW-LEVEL HELPERS ────────────────────────────────────────────────────────

local function playerOf(unit)
    local ok, name = pcall(unit.getPlayerName, unit)
    return (ok and name and name ~= "") and name or nil
end

local function resolvePlayerID(playerName)
    if not (net and net.get_player_list) then return nil end
    for _, id in ipairs(net.get_player_list()) do
        if net.get_name(id) == playerName then return id end
    end
    return nil
end

local function dist2D(a, b)
    local dx = a.x - b.x
    local dz = a.z - b.z
    return math.sqrt(dx * dx + dz * dz)
end

local function findNearestAirbase(pos)
    local nearest, bestDist = nil, math.huge
    for _, side in ipairs({0, 1, 2}) do
        local bases = coalition.getAirbases(side)
        if bases then
            for _, ab in ipairs(bases) do
                local d = dist2D(pos, ab:getPoint())
                if d < bestDist then bestDist = d; nearest = ab end
            end
        end
    end
    return nearest, bestDist
end

local function findZoneForAirbase(airbaseName)
    if not (cfxOwnedZones and cfxOwnedZones.zones) then return nil end
    local lower = string.lower(airbaseName)
    for _, z in pairs(cfxOwnedZones.zones) do
        if z.controlsAirport and string.lower(z.controlsAirport) == lower then
            return z
        end
    end
    return nil
end

-- ─── PUBLIC HELPERS ───────────────────────────────────────────────────────────

function armamentCost.isAtMainBase(unit)
    local ok, pos = pcall(unit.getPoint, unit)
    if not ok or not pos then return false end
    local ab, dist = findNearestAirbase(pos)
    if not ab or dist > armamentCost.aircraftSearchRadius then return false end
    local zone = findZoneForAirbase(ab:getName())
    if not zone then return false end
    return string.upper(zone.zoneType or "") == armamentCost.mainBaseType
end

function armamentCost.getAircraftFee(unit)
    if not armamentCost.chargeAircraftFee then return 0, "" end
    local ok, desc = pcall(unit.getDesc, unit)
    if ok and desc and bankPenalties and bankPenalties.categorizeAircraft then
        local category, label = bankPenalties.categorizeAircraft(desc, desc.typeName or "unknown")
        local fee = armamentCost.aircraftCosts[category]
        if fee then return fee, label end
    end
    return armamentCost.aircraftCostFallback, "aircraft"
end

--- Scan unit ammo. Returns:
---   totalCost    (number)
---   breakdown    ({ displayName → {count, costEach, total} } for weapons with cost > 0)
---   unknownItems (array of { typeName, displayName, count } for unrecognised/free weapons)
function armamentCost.calculateLoadoutCost(unit)
    local totalCost    = 0
    local breakdown    = {}
    local unknownItems = {}

    local ok, ammo = pcall(unit.getAmmo, unit)
    if not ok or not ammo then return 0, {}, {} end

    for _, item in ipairs(ammo) do
        local typeName    = item.desc and item.desc.typeName
        local displayName = (item.desc and item.desc.displayName) or typeName or "?"
        local count       = item.count or 0

        if count > 0 then
            -- DCS typeNames include a category prefix: "weapons.missiles.AGM_114K"
            -- Strip everything up to and including the last dot for table lookup.
            local shortName = typeName and (typeName:match("[^.]+$") or typeName) or nil
            local inTable   = shortName and (armamentCost.weaponCosts[shortName] ~= nil)
            local costEach  = (inTable and armamentCost.weaponCosts[shortName])
                              or armamentCost.unknownWeaponCost

            if inTable and costEach > 0 then
                local lineTotal = costEach * count
                totalCost = totalCost + lineTotal
                breakdown[displayName] = { count = count, costEach = costEach, total = lineTotal }
            else
                table.insert(unknownItems, {
                    typeName    = typeName or "?",
                    displayName = displayName,
                    count       = count,
                })
                if typeName and armamentCost.verbose and not inTable then
                    env.info("armamentCost: UNKNOWN WEAPON typeName='" .. typeName
                        .. "'  shortName='" .. tostring(shortName)
                        .. "'  displayName='" .. tostring(displayName)
                        .. "'  count=" .. count
                        .. "  — add shortName key to armamentCost.weaponCosts to charge for it")
                end
            end
        end
    end

    return totalCost, breakdown, unknownItems
end

function armamentCost.cancelKick(playerName)
    armamentCost.kickGeneration[playerName] =
        (armamentCost.kickGeneration[playerName] or 0) + 1
end

function armamentCost.removeMenu(groupID)
    local entry = armamentCost.groupMenus[groupID]
    if not entry then return end
    pcall(missionCommands.removeItemForGroup, groupID, entry.cmd)
    pcall(missionCommands.removeItemForGroup, groupID, entry.root)
    armamentCost.groupMenus[groupID] = nil
end

-- ─── KICK CHECK (scheduled callback) ─────────────────────────────────────────

function armamentCost.kickCheck(args)
    local playerName = args.playerName
    local unitName   = args.unitName
    local cost       = args.cost
    local aircraftFee = args.aircraftFee or 0
    local gen        = args.gen

    if (armamentCost.kickGeneration[playerName] or 0) ~= gen then return end  -- cancelled

    armamentCost.hasWarning[playerName] = nil

    local unit = Unit.getByName(unitName)
    if not unit or not Unit.isExist(unit) then return end
    if playerOf(unit) ~= playerName then return end

    local okId, uid = pcall(unit.getID, unit)
    uid = okId and uid or nil

    -- Re-check in case they earned score during the grace period
    if cfxPlayerScore and cfxPlayerScore.getPlayerScore then
        local ps   = cfxPlayerScore.getPlayerScore(playerName)
        local have = ps.score or 0
        if have >= cost then
            ps.score = have - cost
            cfxPlayerScore.setPlayerScore(playerName, ps)
            -- Track fees for landing refund
            armamentCost.pendingAircraftRefund[playerName] = aircraftFee
            armamentCost.pendingWeaponRefund[playerName]   = cost - aircraftFee
            if uid then
                trigger.action.outTextForUnit(uid,
                    "Sortie fee paid: -" .. cost .. " score | Remaining: " .. ps.score .. " pts", 15)
            end
            return
        end
    end

    -- Still can't pay → kick
    local pid = resolvePlayerID(playerName)
    if pid and net and net.force_player_slot then
        net.force_player_slot(pid, 0, "")
    end
    trigger.action.outText(
        "ENFORCER: " .. playerName ..
        " moved to spectators — insufficient score for sortie (needed " .. cost .. " pts).", 15)
end

-- ─── F10 MENU CALLBACK ────────────────────────────────────────────────────────

function armamentCost.showLoadoutMenu(args)
    local grp = Group.getByName(args.groupName)
    if not grp then return end
    local unit = grp:getUnit(1)
    if not unit or not unit:isActive() then return end

    local playerName = playerOf(unit)
    if not playerName then return end

    local okId, uid = pcall(unit.getID, unit)
    if not okId or not uid then return end

    local weaponCost, breakdown, unknownItems = armamentCost.calculateLoadoutCost(unit)

    local atMainBase = armamentCost.isAtMainBase(unit)
    local aircraftFee, aircraftLabel = 0, ""
    if not atMainBase then
        aircraftFee, aircraftLabel = armamentCost.getAircraftFee(unit)
    end

    local totalCost = weaponCost + aircraftFee
    local ps   = cfxPlayerScore and cfxPlayerScore.getPlayerScore(playerName)
    local have = ps and (ps.score or 0) or 0

    local lines = { "=== Sortie Cost Estimate ===" }
    lines[#lines + 1] = "Score available: " .. have .. " pts"
    lines[#lines + 1] = atMainBase
        and "Base: MAIN BASE (aircraft fee waived)"
        or  "Base: Forward airfield"

    if totalCost == 0 and #unknownItems == 0 then
        lines[#lines + 1] = "No charges — takeoff is free."
    else
        if totalCost > 0 then
            lines[#lines + 1] = "Total sortie cost: " .. totalCost .. " pts"
            if aircraftFee > 0 then
                lines[#lines + 1] = "  Aircraft [" .. aircraftLabel .. "]: "
                    .. aircraftFee .. " pts  (refunded on safe landing)"
            end
            if weaponCost > 0 then
                lines[#lines + 1] = "  Weapons: " .. weaponCost .. " pts"
                local sorted = {}
                for name, info in pairs(breakdown) do
                    table.insert(sorted, { name = name, info = info })
                end
                table.sort(sorted, function(a, b) return a.name < b.name end)
                for _, entry in ipairs(sorted) do
                    local i = entry.info
                    lines[#lines + 1] = "    " .. entry.name
                        .. " x" .. i.count
                        .. "  (" .. i.costEach .. " ea = " .. i.total .. " pts)"
                end
            end
            if have >= totalCost then
                lines[#lines + 1] = "Status: AFFORDABLE (remaining: " .. (have - totalCost) .. " pts)"
            else
                lines[#lines + 1] = "Status: OVER BUDGET by " .. (totalCost - have) .. " pts!"
                lines[#lines + 1] = "Reduce armament or launch from a Main Base."
            end
        end
        -- Always show unrecognised weapons so the admin can add them to the table
        if #unknownItems > 0 then
            lines[#lines + 1] = "Unrecognised weapons (currently FREE — typeName shown):"
            for _, w in ipairs(unknownItems) do
                lines[#lines + 1] = "  " .. w.displayName
                    .. " [" .. w.typeName .. "] x" .. w.count
            end
        end
    end

    trigger.action.outTextForUnit(uid, table.concat(lines, "\n"), 30)
end

-- ─── EVENT REACTIONS ──────────────────────────────────────────────────────────

function armamentCost.onBirth(unit)
    local playerName = playerOf(unit)
    if not playerName then return end

    local okGrp, grp = pcall(unit.getGroup, unit)
    if not okGrp or not grp then return end

    local okId,   groupID   = pcall(grp.getID,   grp)
    local okName, groupName = pcall(grp.getName, grp)
    if not okId or not okName then return end

    armamentCost.removeMenu(groupID)

    if not missionCommands then return end

    local okRoot, rootMenu = pcall(missionCommands.addSubMenuForGroup, groupID, "Armament")
    if not okRoot or not rootMenu then return end

    local okCmd, cmdPath = pcall(
        missionCommands.addCommandForGroup,
        groupID, "Check Loadout Cost", rootMenu,
        armamentCost.showLoadoutMenu, { groupID = groupID, groupName = groupName }
    )
    if not okCmd or not cmdPath then
        pcall(missionCommands.removeItemForGroup, groupID, rootMenu)
        return
    end

    armamentCost.groupMenus[groupID] = { root = rootMenu, cmd = cmdPath, groupName = groupName }
end

function armamentCost.onTakeoff(unit)
    if not armamentCost.enabled then return end
    if not (cfxPlayerScore and cfxPlayerScore.getPlayerScore) then return end
    if not unit or not Unit.isExist(unit) then return end

    local playerName = playerOf(unit)
    if not playerName then return end

    local weaponCost, _, _ = armamentCost.calculateLoadoutCost(unit)

    local atMainBase = armamentCost.isAtMainBase(unit)
    local aircraftFee, aircraftLabel = 0, ""
    if not atMainBase then
        aircraftFee, aircraftLabel = armamentCost.getAircraftFee(unit)
    end

    local cost = weaponCost + aircraftFee
    if cost <= 0 then return end

    local ps   = cfxPlayerScore.getPlayerScore(playerName)
    local have = ps.score or 0

    local okId, uid = pcall(unit.getID, unit)
    uid = okId and uid or nil

    -- Cancel previous kick if any, then read the new generation
    armamentCost.hasWarning[playerName]            = nil
    armamentCost.pendingAircraftRefund[playerName] = nil  -- clear any stale refund from prev sortie
    armamentCost.pendingWeaponRefund[playerName]   = nil
    armamentCost.cancelKick(playerName)
    local gen = armamentCost.kickGeneration[playerName]

    if have >= cost then
        -- ── Affordable ──────────────────────────────────────────────────────
        ps.score = have - cost
        cfxPlayerScore.setPlayerScore(playerName, ps)

        -- Track fees for landing refund
        armamentCost.pendingAircraftRefund[playerName] = aircraftFee
        armamentCost.pendingWeaponRefund[playerName]   = weaponCost

        if uid then
            local lines = { "Sortie charged: -" .. cost .. " score | Score: " .. ps.score .. " pts" }
            if aircraftFee > 0 then
                lines[#lines + 1] = "  Aircraft [" .. aircraftLabel .. "]: -" .. aircraftFee .. " pts (refunded on landing)"
            end
            if weaponCost > 0 then
                lines[#lines + 1] = "  Weapons: -" .. weaponCost .. " pts (unused weapons refunded on landing)"
            end
            trigger.action.outTextForUnit(uid, table.concat(lines, "\n"), 15)
        end

        if armamentCost.verbose then
            env.info("armamentCost: charged " .. playerName .. " " .. cost
                .. " pts (aircraft=" .. aircraftFee .. " weapons=" .. weaponCost .. ")")
        end
    else
        -- ── Unaffordable: warn + schedule kick ──────────────────────────────
        armamentCost.hasWarning[playerName] = true
        if uid then
            local lines = {
                "INSUFFICIENT SCORE for this sortie!",
                "Total cost: " .. cost .. " pts   |   You have: " .. have .. " pts",
            }
            if aircraftFee > 0 then
                lines[#lines + 1] = "  Aircraft [" .. aircraftLabel .. "]: " .. aircraftFee .. " pts"
            end
            if weaponCost > 0 then
                lines[#lines + 1] = "  Weapons: " .. weaponCost .. " pts"
            end
            lines[#lines + 1] = "Land and reduce your armament, or you will be moved to"
                .. " SPECTATORS in " .. armamentCost.kickDelay .. " seconds."
            trigger.action.outTextForUnit(uid, table.concat(lines, "\n"), armamentCost.kickDelay)
        end
        timer.scheduleFunction(armamentCost.kickCheck, {
            playerName  = playerName,
            unitName    = unit:getName(),
            cost        = cost,
            aircraftFee = aircraftFee,
            gen         = gen,
        }, timer.getTime() + armamentCost.kickDelay)

        if armamentCost.verbose then
            env.info("armamentCost: " .. playerName .. " cannot afford sortie (cost="
                .. cost .. " have=" .. have .. ") kick in " .. armamentCost.kickDelay
                .. "s gen=" .. gen)
        end
    end
end

function armamentCost.onLand(unit)
    if not unit then return end
    local playerName = playerOf(unit)
    if not playerName then return end

    local okId, uid = pcall(unit.getID, unit)
    uid = okId and uid or nil

    -- Cancel kick if one was pending (player landed to re-arm in time)
    if armamentCost.hasWarning[playerName] then
        armamentCost.hasWarning[playerName] = nil
        armamentCost.cancelKick(playerName)
        if uid then
            trigger.action.outTextForUnit(uid,
                "Kick cancelled — landed in time. Reduce armament before next takeoff.", 15)
        end
    end

    -- Refund aircraft fee + cost of weapons still on the rails
    local aircraftRefund = armamentCost.pendingAircraftRefund[playerName]
    local weaponCap      = armamentCost.pendingWeaponRefund[playerName]
    armamentCost.pendingAircraftRefund[playerName] = nil
    armamentCost.pendingWeaponRefund[playerName]   = nil

    local weaponRefund = 0
    if weaponCap and weaponCap > 0 then
        local remainingCost, _, _ = armamentCost.calculateLoadoutCost(unit)
        weaponRefund = math.min(remainingCost, weaponCap)
    end

    local totalRefund = (aircraftRefund or 0) + weaponRefund
    if totalRefund > 0 and cfxPlayerScore and cfxPlayerScore.getPlayerScore then
        local ps = cfxPlayerScore.getPlayerScore(playerName)
        ps.score = ps.score + totalRefund
        cfxPlayerScore.setPlayerScore(playerName, ps)
        if uid then
            local lines = { "Landed safely: +" .. totalRefund .. " pts refunded | Score: " .. ps.score .. " pts" }
            if (aircraftRefund or 0) > 0 then
                lines[#lines + 1] = "  Aircraft returned: +" .. aircraftRefund .. " pts"
            end
            if weaponRefund > 0 then
                lines[#lines + 1] = "  Unused weapons:    +" .. weaponRefund .. " pts"
            end
            trigger.action.outTextForUnit(uid, table.concat(lines, "\n"), 15)
        end
        if armamentCost.verbose then
            env.info("armamentCost: refunded " .. totalRefund .. " pts to " .. playerName
                .. " on landing (aircraft=" .. (aircraftRefund or 0)
                .. " weapons=" .. weaponRefund .. ")")
        end
    end
end

function armamentCost.onCleanup(unit)
    local playerName = playerOf(unit)
    if playerName then
        armamentCost.hasWarning[playerName]            = nil
        armamentCost.pendingAircraftRefund[playerName] = nil  -- aircraft lost, no refund
        armamentCost.pendingWeaponRefund[playerName]   = nil  -- weapons lost with aircraft
        armamentCost.cancelKick(playerName)
    end
    local okGrp, grp = pcall(unit.getGroup, unit)
    if okGrp and grp then
        local okId, gid = pcall(grp.getID, grp)
        if okId then armamentCost.removeMenu(gid) end
    end
end

-- ─── EVENT HANDLER ────────────────────────────────────────────────────────────

local armamentCostEventHandler = {}

function armamentCostEventHandler:onEvent(event)
    local unit = event.initiator
    if not unit then return end
    local id = event.id

    if id == world.event.S_EVENT_BIRTH then
        timer.scheduleFunction(function()
            if unit and Unit.isExist and Unit.isExist(unit) then
                armamentCost.onBirth(unit)
            end
        end, {}, timer.getTime() + 0.5)

    elseif id == world.event.S_EVENT_TAKEOFF then
        timer.scheduleFunction(function()
            if unit and Unit.isExist and Unit.isExist(unit) then
                armamentCost.onTakeoff(unit)
            end
        end, {}, timer.getTime() + 1.0)

    elseif id == world.event.S_EVENT_LAND then
        armamentCost.onLand(unit)

    elseif id == world.event.S_EVENT_DEAD
        or id == world.event.S_EVENT_CRASH
        or id == world.event.S_EVENT_EJECTION
        or id == world.event.S_EVENT_PILOT_DEAD
        or id == world.event.S_EVENT_PLAYER_LEAVE_UNIT then
        armamentCost.onCleanup(unit)
    end
end

-- ─── CONFIG ZONE ──────────────────────────────────────────────────────────────

function armamentCost.readConfigZone()
    local z = cfxZones.getZoneByName("armamentCostConfig")
    if not z then z = cfxZones.createSimpleZone("armamentCostConfig") end

    armamentCost.enabled                      = z:getBoolFromZoneProperty("enabled", true)
    armamentCost.kickDelay                    = z:getNumberFromZoneProperty("kickDelay", 90)
    armamentCost.unknownWeaponCost            = z:getNumberFromZoneProperty("unknownWeaponCost", 0)
    armamentCost.verbose                      = z:getBoolFromZoneProperty("verbose", true)
    armamentCost.chargeAircraftFee            = z:getBoolFromZoneProperty("chargeAircraftFee", true)
    armamentCost.mainBaseType                 = string.upper(
        z:getStringFromZoneProperty("mainBaseType", "Main Base"))
    armamentCost.aircraftSearchRadius         = z:getNumberFromZoneProperty("aircraftSearchRadius", 3000)
    armamentCost.aircraftCostFallback         = z:getNumberFromZoneProperty("aircraftCostFallback", 75)
    armamentCost.aircraftCosts.modernMultirolePlane =
        z:getNumberFromZoneProperty("modernMultiroleFee", 100)
    armamentCost.aircraftCosts.coldWarBomberPlane =
        z:getNumberFromZoneProperty("coldWarBomberFee", 75)
    armamentCost.aircraftCosts.attackHeli =
        z:getNumberFromZoneProperty("attackHeliFee", 50)
    armamentCost.aircraftCosts.transportHeli =
        z:getNumberFromZoneProperty("transportHeliFee", 25)
end

-- ─── INIT ─────────────────────────────────────────────────────────────────────

function armamentCost.init()
    if not dcsCommon.libCheck("armamentCost", armamentCost.requiredLibs) then
        return false
    end

    armamentCost.readConfigZone()
    world.addEventHandler(armamentCostEventHandler)

    local aircraftInfo = armamentCost.chargeAircraftFee
        and (" | Fwd-base fees (refunded on landing): Modern "
             .. armamentCost.aircraftCosts.modernMultirolePlane
             .. " / CW " .. armamentCost.aircraftCosts.coldWarBomberPlane
             .. " / AtkHeli " .. armamentCost.aircraftCosts.attackHeli
             .. " / TrnHeli " .. armamentCost.aircraftCosts.transportHeli)
        or " | Aircraft fee: DISABLED"
    local state = armamentCost.enabled
        and ("kick delay: " .. armamentCost.kickDelay .. "s"
             .. (armamentCost.verbose and " | VERBOSE" or "")
             .. aircraftInfo)
        or "DISABLED"
    trigger.action.outText("armamentCost v" .. armamentCost.version .. " loaded | " .. state, 10)
    return true
end

if not armamentCost.init() then
    trigger.action.outText("armamentCost aborted: missing libraries", 30)
    armamentCost = nil
end
