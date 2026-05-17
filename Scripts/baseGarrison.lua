--[[
========================================================================================
baseGarrison.lua
========================================================================================
Automatically spawns a template AI garrison group at an airbase when it is
captured by RED or BLUE. Only zones explicitly marked with garrison=true fire.

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
       spawnRadius  (number)  – metres from airbase centre, clamped to zone radius (default 300)
       redTemplate  (string)  – exact name of the RED Late Activated group  (default "GARRISON_RED")
       blueTemplate (string)  – exact name of the BLUE Late Activated group (default "GARRISON_BLUE")
       verbose      (bool)    – show on-screen errors and spawn confirmations (default false)

LOAD ORDER: after CTLD & Menus_refactored.lua, before mist
========================================================================================
]]

baseGarrison = {}
baseGarrison.version      = "1.0.0"
baseGarrison.spawnRadius  = 300        -- metres; clamped to zone.radius at spawn time
baseGarrison.redTemplate  = "GARRISON_RED"
baseGarrison.blueTemplate = "GARRISON_BLUE"
baseGarrison.verbose      = true

-- Returns the DCS native Airbase object for this zone only if it is a major
-- airdrome (not a FARP or carrier). Returns nil for all other zone types.
local function dbg(msg)
    env.info("baseGarrison: " .. msg)
    if baseGarrison.verbose then
        trigger.action.outText("[baseGarrison] " .. msg, 10)
    end
end

local function getMajorAirbase(zone)
    local name = zone.controlsAirport
    if not name or name == "none" then
        dbg("zone '" .. zone.name .. "' has no controlsAirport — skipped")
        return nil
    end
    local ab = Airbase.getByName(name)
    if not ab then
        dbg("zone '" .. zone.name .. "' controlsAirport='" .. name .. "' not found in DCS — skipped")
        return nil
    end
    return ab
end

function baseGarrison.onZoneCaptured(zone, newOwner, lastOwner)
    dbg("capture event — zone='" .. zone.name .. "' newOwner=" .. tostring(newOwner) .. " lastOwner=" .. tostring(lastOwner))
    -- Only act on definitive RED or BLUE captures, not neutral/contested transitions
    if newOwner ~= 1 and newOwner ~= 2 then return end
    -- Zone must be explicitly opted in via zone property "garrison = true"
    if not zone:getBoolFromZoneProperty("garrison", false) then
        dbg("zone '" .. zone.name .. "' has no 'garrison' property — skipped")
        return
    end

    local ab = getMajorAirbase(zone)
    if not ab then return end

    local template = newOwner == 1 and baseGarrison.redTemplate or baseGarrison.blueTemplate
    local radius   = math.min(baseGarrison.spawnRadius, zone.radius)

    -- Pick a uniformly random point inside the zone (sqrt gives uniform disc, not centre-weighted)
    local angle      = math.random() * 2 * math.pi
    local dist       = math.sqrt(math.random()) * radius
    local spawnVec2  = {
        x = zone.point.x + dist * math.cos(angle),
        y = zone.point.z + dist * math.sin(angle),
    }

    local status, err = pcall(function()
        local alias = template .. "_" .. zone.name .. "_" .. tostring(math.floor(timer.getTime()))
        SPAWN:NewWithAlias(template, alias):SpawnFromVec2(spawnVec2)
    end)

    if not status then
        dbg("spawn FAILED at '" .. zone.name .. "' template='" .. template .. "': " .. tostring(err))
    else
        dbg("garrison spawned — side=" .. newOwner .. " zone='" .. zone.name .. "' template='" .. template .. "' radius=" .. safeRadius)
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
    env.info("baseGarrison v" .. baseGarrison.version .. " started. radius=" ..
             baseGarrison.spawnRadius .. " red='" .. baseGarrison.redTemplate ..
             "' blue='" .. baseGarrison.blueTemplate .. "'")
end

baseGarrison.start()
