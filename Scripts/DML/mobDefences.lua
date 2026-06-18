--[[
mobDefences.lua
Spawns coalition-specific defence groups at MOB zones on mission start and whenever
a MOB is captured by a coalition.

REQUIREMENTS:
- dcsCommon, cfxZones, cfxOwnedZones must be loaded first
- Moose must be loaded first
- Two late-activation template groups must exist in the mission editor:
    "BLUE_MOB_DEFENCES"
    "RED_MOB_DEFENCES"
- Each MOB zone needs up to 2 trigger zones named:
    "MOB_DEFENCES_<MOB zone name>_1"
    "MOB_DEFENCES_<MOB zone name>_2"
  Example: MOB zone "Maykop" -> "MOB_DEFENCES_Maykop_1" and "MOB_DEFENCES_Maykop_2"

  IMPORTANT: these defence zones MUST sit INSIDE the MOB capture zone. The spawned
  defence units are what hold the MOB for its owner; if they spawn outside the MOB
  zone, cfxOwnedZones will see no units inside the MOB and flip it to neutral. The
  script warns at start if a defence zone centre is not inside its MOB.

BEHAVIOUR:
- On start: spawns the owning coalition's defence group at a randomly-chosen
  defence zone for each MOB, based on the MOB's CONFIGURED starting owner
  (captured before the ownership update loop can mutate it).
- On capture: when a MOB is taken by a coalition (owner becomes RED or BLUE),
  the old defence group is removed and the new owner's group is spawned at a
  freshly-chosen random defence zone.
- Neutral (0) and contested (3) transitions are IGNORED so we never destroy a
  coalition's own defences mid-fight or during the start-up settle tick.
- These groups are NOT registered with persistence; they are always recreated
  fresh at mission start.
--]]

mobDefences = {}
mobDefences.version = "1.1.0"
mobDefences.requiredLibs = { "dcsCommon", "cfxZones", "cfxOwnedZones" }

mobDefences.blueTemplate = "BLUE_MOB_DEFENCES"
mobDefences.redTemplate  = "RED_MOB_DEFENCES"
mobDefences.zonePrefix   = "MOB_DEFENCES_"

-- { [mobZoneName] = groupAlias or nil } -- the MOOSE alias we last spawned
mobDefences.activeGroups = {}
-- { [mobZoneName] = 1|2 } -- the coalition we currently have defences for
mobDefences.activeOwner = {}
-- { [mobZoneName] = { "MOB_DEFENCES_X_1", "MOB_DEFENCES_X_2" } }
mobDefences.defenceZones = {}

-- -----------------------------------------------------------------------
-- Zone map: discover which defence zones exist for each MOB, and warn if
-- any defence zone centre sits outside its MOB capture zone.
-- -----------------------------------------------------------------------
function mobDefences.buildDefenceZoneMap()
    local found = 0
    for _, mobZone in pairs(cfxOwnedZones.mobZones) do
        local mobName = mobZone.name
        local list = {}
        for i = 1, 2 do
            local zname = mobDefences.zonePrefix .. mobName .. "_" .. i
            local dz = cfxZones.getZoneByName(zname)
            if dz then
                table.insert(list, zname)
                -- Verify the defence zone is inside the MOB capture zone
                if not mobZone:pointInZone(dz:getPoint()) then
                    trigger.action.outText("+++mobDef: WARNING - defence zone '" .. zname
                        .. "' is OUTSIDE MOB '" .. mobName .. "'. Defences spawned there "
                        .. "will NOT hold the MOB.", 30)
                end
            end
        end
        if #list > 0 then
            mobDefences.defenceZones[mobName] = list
            found = found + 1
        else
            trigger.action.outText("+++mobDef: WARNING - no defence zones for MOB '" .. mobName
                .. "' (expected '" .. mobDefences.zonePrefix .. mobName .. "_1' / '_2')", 30)
        end
    end
    return found
end

-- -----------------------------------------------------------------------
-- Destroy the current defence group at a MOB (if any)
-- -----------------------------------------------------------------------
function mobDefences.destroyGroup(mobName)
    local alias = mobDefences.activeGroups[mobName]
    mobDefences.activeGroups[mobName] = nil
    mobDefences.activeOwner[mobName] = nil
    if not alias then return end
    local grp = GROUP:FindByName(alias)
    if grp and grp:IsAlive() then
        grp:Destroy()
    end
end

-- -----------------------------------------------------------------------
-- Spawn a fresh defence group for a given coalition at a MOB zone
-- owner: 1 (RED) or 2 (BLUE)
-- -----------------------------------------------------------------------
function mobDefences.spawnFor(mobName, owner)
    if owner ~= 1 and owner ~= 2 then return end  -- neutral / contested

    local template = (owner == 1) and mobDefences.redTemplate or mobDefences.blueTemplate
    local zoneList = mobDefences.defenceZones[mobName]
    if not zoneList or #zoneList == 0 then return end

    -- Pick one defence zone at random
    local chosenName = zoneList[math.random(#zoneList)]
    local chosenZone = cfxZones.getZoneByName(chosenName)
    if not chosenZone then
        env.info("mobDefences: could not find zone '" .. chosenName .. "'")
        return
    end

    local pos = chosenZone:getPoint()
    local safeName = mobName:gsub("[%s%-]+", "_")
    local alias = template .. "_" .. safeName .. "_" .. tostring(math.random(10000, 99999))

    local ok, err = pcall(function()
        local sp = SPAWN:NewWithAlias(template, alias)
        sp:SpawnFromVec2({ x = pos.x, y = pos.z })
    end)

    if ok then
        mobDefences.activeGroups[mobName] = alias
        mobDefences.activeOwner[mobName] = owner
        env.info("mobDefences: spawned '" .. alias .. "' at '" .. chosenName .. "' for MOB " .. mobName)
    else
        env.info("mobDefences: spawn FAILED for MOB " .. mobName
            .. " (template '" .. template .. "'): " .. tostring(err))
        trigger.action.outText("+++mobDef: spawn FAILED for MOB '" .. mobName
            .. "' - is template group '" .. template .. "' present and late-activated?", 30)
    end
end

-- -----------------------------------------------------------------------
-- Conquest callback - fires whenever ANY owned zone changes hands.
-- We only react to DEFINITIVE captures (owner becomes RED or BLUE).
-- Neutral (0) and contested (3) transitions are ignored so we never
-- destroy a coalition's own defences during a fight or the start tick.
-- -----------------------------------------------------------------------
function mobDefences.onZoneConquered(aZone, newOwner, lastOwner)
    if not aZone or aZone.zoneType ~= "MOB" then return end
    if newOwner ~= 1 and newOwner ~= 2 then return end

    local mobName = aZone.name
    -- Already holding defences for this coalition and they are alive? Nothing to do.
    if mobDefences.activeOwner[mobName] == newOwner then
        local alias = mobDefences.activeGroups[mobName]
        local grp = alias and GROUP:FindByName(alias)
        if grp and grp:IsAlive() then return end
    end

    mobDefences.destroyGroup(mobName)
    mobDefences.spawnFor(mobName, newOwner)
end

-- -----------------------------------------------------------------------
-- Init
-- -----------------------------------------------------------------------
function mobDefences.init()
    if not dcsCommon.libCheck("MOB Defences", mobDefences.requiredLibs) then
        return false
    end

    local mobCount = 0
    for _ in pairs(cfxOwnedZones.mobZones or {}) do mobCount = mobCount + 1 end

    local zonesFound = mobDefences.buildDefenceZoneMap()

    -- Register for zone ownership changes
    cfxOwnedZones.addCallBack(mobDefences.onZoneConquered)

    -- Spawn initial defences using each MOB's CONFIGURED owner, captured now
    -- (cfxOwnedZones.update() has not run yet, so mobZone.owner is still the
    -- starting/persisted owner). Spawning synchronously here means the units
    -- exist before the first update tick, so the MOB is never flipped neutral.
    local spawned = 0
    for _, mobZone in pairs(cfxOwnedZones.mobZones) do
        local owner = mobZone.owner
        if owner == 1 or owner == 2 then
            mobDefences.spawnFor(mobZone.name, owner)
            if mobDefences.activeGroups[mobZone.name] then spawned = spawned + 1 end
        end
    end

    trigger.action.outText("+++mobDef: MOB Defences v" .. mobDefences.version
        .. " started - " .. mobCount .. " MOBs, defence zones for " .. zonesFound
        .. ", initial groups spawned: " .. spawned, 30)
    return true
end

if not mobDefences.init() then
    trigger.action.outText("MOB Defences aborted: missing libraries", 30)
    mobDefences = nil
end
