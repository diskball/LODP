--[[
    cfxBaseEnforcer.lua
    Version: 1.0.0

    PURPOSE:
    Monitors player SPAWN (birth) and LANDING events.
    If a player spawns or lands at an airbase that is controlled by a
    cfxOwnedZones zone AND that zone is owned by the ENEMY coalition,
    the player is immediately kicked to spectators.

    DEPENDENCY:
    - cfxOwnedZones_modified.lua (must be loaded BEFORE this script)
    - dcsCommon, cfxZones (loaded as part of cfxOwnedZones dependencies)

    HOW IT WORKS:
    1. On S_EVENT_BIRTH  : A player just spawned into a unit.
    2. On S_EVENT_LAND   : A player-controlled aircraft just landed.
    In both cases we:
      a) Get the unit's position and find the nearest DCS Airbase.
      b) Walk cfxOwnedZones.zones to find any zone whose 'controlsAirport'
         property matches that airbase name.
      c) If found, compare zone.owner to the player's coalition.
         owner 0 = neutral  (block both sides – configurable)
         owner 1 = RED
         owner 2 = BLUE
         owner 3 = contested (block both sides – configurable)
      d) If the base belongs to the enemy (or is neutral/contested when
         cfxBaseEnforcer.blockNeutral / .blockContested is true), the
         player is kicked to spectators via net.force_player_slot.

    CONFIGURATION (set these before loading this script or edit below):
    cfxBaseEnforcer.blockNeutral   = true   -- kick players from neutral bases
    cfxBaseEnforcer.blockContested = true   -- kick players from contested bases
    cfxBaseEnforcer.searchRadius   = 3000   -- metres; how close to a base counts as "at that base"
    cfxBaseEnforcer.verbose        = true   -- print debug messages to all players
    cfxBaseEnforcer.warnMessage    = true   -- show a message to the kicked player
    cfxBaseEnforcer.warnSeconds    = 15     -- seconds the warning is shown

    INSTALLATION:
    Add this script as a DO SCRIPT FILE (or DO SCRIPT) action in the
    Mission Editor, AFTER cfxOwnedZones_modified.lua has been loaded.
--]]

cfxBaseEnforcer = {}
cfxBaseEnforcer.version        = "1.0.0"
cfxBaseEnforcer.blockNeutral   = true
cfxBaseEnforcer.blockContested = false
cfxBaseEnforcer.searchRadius   = 3000   -- metres
cfxBaseEnforcer.verbose        = true
cfxBaseEnforcer.warnMessage    = true
cfxBaseEnforcer.warnSeconds    = 15

-- Unit types ALLOWED to land at NEUTRAL bases (cargo-capable only).
-- Must stay in sync with CHOPPER_CONFIG entries where troops=true or crates=true
-- in CTLD & Menus_refactored.lua. Attack helis (AH-64D, OH58D) are intentionally absent.
-- Spawn at neutral bases is always blocked regardless of this list.
cfxBaseEnforcer.neutralWhitelist = {
    ["Mi-24P"]    = true,   -- cargo heli (CTLD)
    ["UH-1H"]     = true,   -- cargo heli (CTLD)
    ["UH-60L"]    = true,   -- cargo heli (CTLD)
    ["Mi-8MTV2"]  = true,   -- cargo heli (CTLD)
    ["CH-47Fbl1"] = true,   -- cargo heli (CTLD)
    ["C-130J-30"] = true,   -- cargo fixed-wing
}

-- ──────────────────────────────────────────────────────────────────────────────
-- HELPERS
-- ──────────────────────────────────────────────────────────────────────────────

--- Return distance (metres) between two DCS Vec3 points (ignores Y/altitude).
local function dist2D(a, b)
    local dx = a.x - b.x
    local dz = a.z - b.z
    return math.sqrt(dx * dx + dz * dz)
end

--- Return a human-readable coalition name.
local function coalName(side)
    if side == 1 then return "REDFOR"
    elseif side == 2 then return "BLUEFOR"
    elseif side == 3 then return "CONTESTED"
    else return "NEUTRAL" end
end

--- Find the closest DCS Airbase (airfield, FARP, carrier) to a Vec3 position.
--- Returns (airbase object, distance) or (nil, math.huge).
local function findNearestAirbase(pos)
    local nearest  = nil
    local bestDist = math.huge

    -- Check all three coalitions (red=1, blue=2, neutral=0)
    for _, side in ipairs({0, 1, 2}) do
        local bases = coalition.getAirbases(side)
        if bases then
            for _, ab in ipairs(bases) do
                local abPos = ab:getPoint()
                local d = dist2D(pos, abPos)
                if d < bestDist then
                    bestDist = d
                    nearest  = ab
                end
            end
        end
    end

    return nearest, bestDist
end

--- Walk cfxOwnedZones.zones and find a zone whose 'controlsAirport' property
--- matches the given airbase name (case-insensitive).
--- Returns the zone table or nil.
local function findOwnedZoneForAirbase(airbaseName)
    if not cfxOwnedZones or not cfxOwnedZones.zones then
        return nil
    end

    local lowerName = string.lower(airbaseName)
    for _, zone in pairs(cfxOwnedZones.zones) do
        if zone.controlsAirport and zone.controlsAirport ~= "none" then
            if string.lower(zone.controlsAirport) == lowerName then
                return zone
            end
        end
    end
    return nil
end

--- Kick a player to spectators.
--- playerID  : net player ID (number)
--- unitName  : name of the unit (for messaging)
--- reason    : short string explaining why
local function kickToSpectators(playerID, unitName, reason)
    if cfxBaseEnforcer.verbose then
        trigger.action.outText(
            "+++BaseEnf: kicking player " .. tostring(playerID) ..
            " (unit: " .. tostring(unitName) .. ") – " .. reason, 10)
    end

    if cfxBaseEnforcer.warnMessage then
        -- Send a message to the specific player only.
        -- net.send_chat_to is server-side only; outTextForGroup needs a groupID.
        -- We use trigger.action.outText as a fallback visible to all since
        -- player-specific messaging requires more infrastructure.
        -- If you have MOOSE or a similar framework you can replace this with
        -- MESSAGE:New(...):ToClient(CLIENT:FindByPlayerName(...))
        trigger.action.outText(
            "ENFORCER: You have been moved to spectators.\n" .. reason,
            cfxBaseEnforcer.warnSeconds)
    end

    -- net.force_player_slot(playerID, sideID, slotID)
    -- sideID = 0 and slotID = "" sends the player to spectators.
    -- This call is only available server-side (multiplayer). In single-player
    -- it is a no-op, which is fine – single-player missions don't need
    -- faction enforcement.
    if net and net.force_player_slot then
        net.force_player_slot(playerID, 0, "")
    end
end

-- ──────────────────────────────────────────────────────────────────────────────
-- CORE CHECK
-- ──────────────────────────────────────────────────────────────────────────────

--- Main enforcement logic called for both BIRTH and LAND events.
--- unit      : DCS Unit object
--- eventType : string label for logging ("SPAWN" or "LAND")
local function checkUnit(unit, eventType)
    if not unit or not Unit.isExist(unit) then return end

    -- Only care about player-controlled units.
    local playerName = unit:getPlayerName()
    if not playerName or playerName == "" then return end

    local unitName        = unit:getName()
    local playerCoalition = unit:getCoalition()  -- 1=red, 2=blue
    local pos             = unit:getPoint()

    -- Find nearest airbase.
    local airbase, distance = findNearestAirbase(pos)
    if not airbase then return end
    if distance > cfxBaseEnforcer.searchRadius then return end  -- not close enough to any base

    local airbaseName = airbase:getName()

    -- Find if this airbase is managed by an ownedZone.
    local zone = findOwnedZoneForAirbase(airbaseName)
    if not zone then
        -- This airbase is not managed by cfxOwnedZones; no restriction.
        if cfxBaseEnforcer.verbose then
            trigger.action.outText(
                "+++BaseEnf: " .. eventType .. " at '" .. airbaseName ..
                "' – not managed by cfxOwnedZones, no action.", 8)
        end
        return
    end

    local owner = zone.owner  -- 0=neutral, 1=red, 2=blue, 3=contested

    if cfxBaseEnforcer.verbose then
        trigger.action.outText(
            "+++BaseEnf: " .. eventType .. " – player '" .. playerName ..
            "' (" .. coalName(playerCoalition) .. ") at '" .. airbaseName ..
            "' owned by " .. coalName(owner), 10)
    end

    -- Decide whether to kick.
    local shouldKick = false
    local reason     = ""

    if owner == 0 then
        if cfxBaseEnforcer.blockNeutral then
            -- On LAND, check if this unit type is whitelisted for neutral bases.
            -- On SPAWN, always kick regardless of type – players may not spawn at neutral bases.
            if eventType == "LAND" then
                local unitType = unit:getTypeName()
                if cfxBaseEnforcer.neutralWhitelist[unitType] then
                    if cfxBaseEnforcer.verbose then
                        trigger.action.outText(
                            "+++BaseEnf: NEUTRAL base '" .. airbaseName ..
                            "' – unit type '" .. unitType .. "' is whitelisted for landing, allowing.", 8)
                    end
                    return  -- whitelisted type landing at neutral base, no kick
                end
            end
            shouldKick = true
            reason = "Base '" .. airbaseName .. "' is NEUTRAL.\n" ..
                     "Only designated cargo/transport aircraft may land here.\n" ..
                     "No faction may spawn here."
        end
    elseif owner == 3 then
        if cfxBaseEnforcer.blockContested then
            shouldKick = true
            reason = "Base '" .. airbaseName .. "' is CONTESTED. Access is denied."
        end
    elseif owner ~= playerCoalition then
        -- The base belongs to the enemy.
        shouldKick = true
        reason = "Base '" .. airbaseName .. "' is controlled by " ..
                 coalName(owner) .. ". You (" .. coalName(playerCoalition) ..
                 ") may not use enemy-controlled bases."
    end

    if not shouldKick then return end

    -- Resolve the net player ID from the player name.
    -- net.get_player_list() returns a table of IDs; net.get_name(id) returns the name.
    local playerID = nil
    if net and net.get_player_list then
        for _, id in ipairs(net.get_player_list()) do
            if net.get_name(id) == playerName then
                playerID = id
                break
            end
        end
    end

    if playerID then
        -- Apply bank penalty before the kick so the unit still exists for lookup.
        -- This unregisters the unit from bankPenalties to prevent a double-charge
        -- from the PLAYER_LEAVE_UNIT event that fires when the slot is cleared.
        if bankPenalties and bankPenalties.penalizeUnit then
            local penaltyReason = (eventType == "LAND" and "landed" or "spawned")
                .. " at a " .. coalName(owner):lower() .. " base (" .. airbaseName .. ")"
            bankPenalties.penalizeUnit(unit, penaltyReason)
        end
        kickToSpectators(playerID, unitName, reason)
    else
        -- Single-player or net API unavailable.
        if cfxBaseEnforcer.verbose then
            trigger.action.outText(
                "+++BaseEnf: Cannot kick – net API not available " ..
                "(single-player or mission not on a server).", 10)
        end
        -- Still show the warning so the player is aware.
        if cfxBaseEnforcer.warnMessage then
            trigger.action.outText(
                "ENFORCER WARNING: " .. reason, cfxBaseEnforcer.warnSeconds)
        end
    end
end

-- ──────────────────────────────────────────────────────────────────────────────
-- EVENT HANDLER
-- ──────────────────────────────────────────────────────────────────────────────

local baseEnforcerEventHandler = {}

function baseEnforcerEventHandler:onEvent(event)
    -- S_EVENT_BIRTH  (id = 15) – unit has just spawned / taken a slot
    -- S_EVENT_LAND   (id = 9)  – aircraft has just landed
    if event.id == world.event.S_EVENT_BIRTH then
        -- Small delay to allow DCS to fully initialise the unit before we query it.
        -- Without this, getPlayerName() can return nil on the exact frame of birth.
        local unit = event.initiator
        timer.scheduleFunction(function()
            checkUnit(unit, "SPAWN")
        end, {}, timer.getTime() + 0.5)

    elseif event.id == world.event.S_EVENT_LAND then
        local unit = event.initiator
        checkUnit(unit, "LAND")
    end
end

-- Register the event handler with the DCS world engine.
world.addEventHandler(baseEnforcerEventHandler)

trigger.action.outText("cfxBaseEnforcer v" .. cfxBaseEnforcer.version .. " loaded.", 10)
