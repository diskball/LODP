--[[
========================================================================================
baseGarrison.lua
========================================================================================
Automatically spawns a template AI garrison group when a zone is captured
by RED or BLUE. Only zones marked with garrison=true zone property fire.

The garrison spawns at a random position within the zone's own radius, so it is
always inside the capture boundary — guaranteeing it must be killed before the
base can be recaptured.

DEPENDENCIES (must be loaded before this script):
  - cfxZones, cfxOwnedZones (zone system and capture callbacks)
  - Moose (SPAWN framework)

MISSION EDITOR SETUP:
  1. Create a Late Activated group named "GARRISON_RED"  → the RED garrison template
  2. Create a Late Activated group named "GARRISON_BLUE" → the BLUE garrison template
  3. On each owned zone that should receive a garrison, add zone property:
       garrison = true
     Zones without this property are ignored regardless of airbase type.
  4. Place a trigger zone named "baseGarrisonConfig" (optional) with any of these
     zone properties to override defaults:
       spawnRadius  (number)  – metres, clamped to zone radius (default 300)
       redTemplate  (string)  – exact name of the RED Late Activated group  (default "GARRISON_RED")
       blueTemplate (string)  – exact name of the BLUE Late Activated group (default "GARRISON_BLUE")
       verbose      (bool)    – show on-screen errors and spawn confirmations (default false)

LOAD ORDER: after CTLD & Menus_refactored.lua, before mist
========================================================================================
]]

baseGarrison = {}
baseGarrison.version      = "1.1.0"
baseGarrison.spawnRadius  = 300        -- metres; clamped to zone.radius at spawn time
baseGarrison.redTemplate  = "GARRISON_RED"
baseGarrison.blueTemplate = "GARRISON_BLUE"
baseGarrison.verbose      = false
baseGarrison.activeGroups = {}  -- [zone.name] = { alias=string, side=number }

local function isGroupAlive(grp)
    -- grp is the MOOSE GROUP object returned by SpawnFromVec2.
    -- MOOSE appends " #001" etc. to the alias, so Group.getByName(alias) never
    -- finds the real group — use the object directly instead.
    if not grp then return false end
    return grp:IsAlive() == true
end

local function dbg(msg)
    env.info("baseGarrison: " .. msg)
    if baseGarrison.verbose then
        trigger.action.outText("[baseGarrison] " .. msg, 10)
    end
end

function baseGarrison.onZoneCaptured(zone, newOwner, lastOwner)
    local ok, err = pcall(function()
        dbg("capture event — zone='" .. zone.name .. "' newOwner=" .. tostring(newOwner) .. " lastOwner=" .. tostring(lastOwner))
        -- Only act on definitive RED or BLUE captures, not neutral/contested transitions
        if newOwner ~= 1 and newOwner ~= 2 then return end
        -- Zone must be explicitly opted in via zone property "garrison = true"
        if not zone:getBoolFromZoneProperty("garrison", false) then
            dbg("zone '" .. zone.name .. "' has no 'garrison' property — skipped")
            return
        end

        -- Always spawn fresh; destroy any lingering garrison for this zone first
        local existing = baseGarrison.activeGroups[zone.name]
        if existing and isGroupAlive(existing.group) then
            existing.group:Destroy()
            dbg("destroyed old garrison at '" .. zone.name .. "'")
        end
        baseGarrison.activeGroups[zone.name] = nil

        local template = newOwner == 1 and baseGarrison.redTemplate or baseGarrison.blueTemplate
        local radius   = math.min(baseGarrison.spawnRadius, zone.radius)

        -- Uniform random point within the zone
        local angle     = math.random() * 2 * math.pi
        local dist      = math.sqrt(math.random()) * radius
        local spawnVec2 = {
            x = zone.point.x + dist * math.cos(angle),
            y = zone.point.z + dist * math.sin(angle),
        }
        dbg("spawn point: dist=" .. math.floor(dist) .. "m angle=" .. math.floor(math.deg(angle)) .. "deg")

        local alias = template .. "_" .. zone.name .. "_" .. tostring(math.floor(timer.getTime()))
        local spawnedGroup
        local spawnOk, spawnErr = pcall(function()
            spawnedGroup = SPAWN:NewWithAlias(template, alias):SpawnFromVec2(spawnVec2)
        end)

        if not spawnOk then
            dbg("spawn FAILED at '" .. zone.name .. "' template='" .. template .. "': " .. tostring(spawnErr))
        else
            baseGarrison.activeGroups[zone.name] = { group = spawnedGroup, side = newOwner, spawnVec2 = spawnVec2 }
            dbg("garrison spawned — side=" .. newOwner .. " zone='" .. zone.name .. "' template='" .. template .. "' alias='" .. alias .. "' radius=" .. radius)
        end
    end)
    if not ok then
        env.info("baseGarrison: unhandled error in onZoneCaptured: " .. tostring(err))
    end
end

function baseGarrison.saveData()
    local saved = {}
    for zoneName, entry in pairs(baseGarrison.activeGroups) do
        dbg("saveData: saving zone='" .. zoneName .. "' side=" .. tostring(entry.side) .. " isDead=" .. tostring(not isGroupAlive(entry.group)))
        saved[zoneName] = {
            side      = entry.side,
            isDead    = not isGroupAlive(entry.group),
            spawnVec2 = entry.spawnVec2,
        }
    end
    local count = 0; for _ in pairs(saved) do count = count + 1 end
    dbg("saveData: total zones saved = " .. count)
    return saved
end

function baseGarrison.loadMission()
    local theData = persistence.getSavedDataForModule("baseGarrison")
    if not theData then
        dbg("no saved garrison data, fresh start")
        return
    end
    for zoneName, entry in pairs(theData) do
        if not entry.isDead and entry.spawnVec2 then
            local template = entry.side == 1 and baseGarrison.redTemplate or baseGarrison.blueTemplate
            local alias = template .. "_" .. zoneName .. "_" .. tostring(math.floor(timer.getTime()))
            local spawnedGroup
            local ok, err = pcall(function()
                spawnedGroup = SPAWN:NewWithAlias(template, alias):SpawnFromVec2(entry.spawnVec2)
            end)
            if ok and spawnedGroup then
                baseGarrison.activeGroups[zoneName] = { group = spawnedGroup, side = entry.side, spawnVec2 = entry.spawnVec2 }
                dbg("garrison restored — side=" .. entry.side .. " zone='" .. zoneName .. "'")
            else
                dbg("garrison restore FAILED for zone='" .. zoneName .. "': " .. tostring(err))
            end
        else
            dbg("garrison for zone='" .. zoneName .. "' was dead at last save, not restoring")
        end
    end
end

function baseGarrison.start()
    local cfg = cfxZones.getZoneByName("baseGarrisonConfig")
    if cfg then
        baseGarrison.spawnRadius  = cfg:getNumberFromZoneProperty("spawnRadius",  baseGarrison.spawnRadius)
        baseGarrison.redTemplate  = cfg:getStringFromZoneProperty("redTemplate",  baseGarrison.redTemplate)
        baseGarrison.blueTemplate = cfg:getStringFromZoneProperty("blueTemplate", baseGarrison.blueTemplate)
        baseGarrison.verbose      = cfg:getBoolFromZoneProperty("verbose",        false)
    end

    cfxOwnedZones.addCallBack(baseGarrison.onZoneCaptured)

    if persistence and persistence.active then
        persistence.registerModule("baseGarrison", { persistData = baseGarrison.saveData })
        if persistence.hasData then
            -- Defer restore by one second so MOOSE (SPAWN) is fully initialized
            timer.scheduleFunction(baseGarrison.loadMission, nil, timer.getTime() + 1)
        end
    end

    missionCommands.addCommand("Save Mission", nil, persistence.doSaveMission)

    env.info("baseGarrison v" .. baseGarrison.version .. " started. radius=" ..
             baseGarrison.spawnRadius .. " red='" .. baseGarrison.redTemplate ..
             "' blue='" .. baseGarrison.blueTemplate .. "'")
end

baseGarrison.start()
