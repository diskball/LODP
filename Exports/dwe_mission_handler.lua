-- =============================================================
--  dwe_mission_handler.lua
--  Add to mission: trigger ONCE / TIME MORE 0 / DO SCRIPT (inline)
--
--  Writes events to _dwe_queue which the hook drains via
--  net.dostring_in — both share the same mission Lua state _G.
-- =============================================================

env.info("[DWE] script start")

-- Write to root _G so net.dostring_in (which runs in root _G, not the DO SCRIPT
-- sandbox) can see it. Plain `_dwe_queue = {}` would only set it in the sandbox.
_G._dwe_queue = _G._dwe_queue or {}
env.info("[DWE] queue table addr: " .. tostring(_G._dwe_queue))

local function _json(tbl)
    local ok, JSON = pcall(require, "JSON")
    if ok and JSON then return JSON.encode(tbl) end
    local parts = {}
    for k, v in pairs(tbl) do
        local val
        if type(v) == "number" then val = tostring(v)
        elseif type(v) == "boolean" then val = v and "true" or "false"
        else val = '"' .. tostring(v):gsub('\\', '\\\\'):gsub('"', '\\"') .. '"'
        end
        parts[#parts + 1] = '"' .. k .. '":' .. val
    end
    return "{" .. table.concat(parts, ",") .. "}"
end

local function _pilot(u)
    if not u then return "AI" end
    local ok, n = pcall(function() return u:getPlayerName() end)
    if ok and n and n ~= "" then return n end
    return "AI"
end

local function _uname(u)
    if not u then return "unknown" end
    local ok, n = pcall(function() return u:getName() end)
    return (ok and n) or "unknown"
end

local function _utype(u)
    if not u then return "unknown" end
    local ok, t = pcall(function() return u:getTypeName() end)
    return (ok and t) or "unknown"
end

local function _wtype(w)
    if not w then return "unknown" end
    local ok, n = pcall(function() return w:getTypeName() end)
    return (ok and n) or "unknown"
end

local function _base(p)
    if not p then return "unknown" end
    local ok, n = pcall(function() return p:getName() end)
    return (ok and n) or "unknown"
end

env.info("[DWE] helpers defined, registering handler")

local _dwe_handler = {}
function _dwe_handler:onEvent(e)
    if not e or not e.id then return end
    local id = e.id

    local ok, err = pcall(function()
        local t = timer.getAbsTime()

        if id == 1 then
            local entry = _json({ type = "SHOT", mission_time = t,
                pilot = _pilot(e.initiator), unit = _uname(e.initiator),
                unit_type = _utype(e.initiator), weapon = _wtype(e.weapon) })
            table.insert(_dwe_queue, entry)
            env.info("[DWE] SHOT queued: " .. entry)

        elseif id == 2 then
            local entry = _json({ type = "HIT", mission_time = t,
                pilot = _pilot(e.initiator), unit = _uname(e.initiator),
                unit_type = _utype(e.initiator), weapon = _wtype(e.weapon),
                target = _uname(e.target), target_type = _utype(e.target) })
            table.insert(_dwe_queue, entry)
            env.info("[DWE] HIT queued: " .. entry)

        elseif id == 3 then
            local p = _pilot(e.initiator)
            if p ~= "AI" then
                local entry = _json({ type = "TAKEOFF", mission_time = t,
                    pilot = p, unit = _uname(e.initiator),
                    unit_type = _utype(e.initiator), airbase = _base(e.place) })
                table.insert(_dwe_queue, entry)
                env.info("[DWE] TAKEOFF queued: " .. entry)
            end

        elseif id == 4 then
            local p = _pilot(e.initiator)
            if p ~= "AI" then
                local entry = _json({ type = "LAND", mission_time = t,
                    pilot = p, unit = _uname(e.initiator),
                    unit_type = _utype(e.initiator), airbase = _base(e.place) })
                table.insert(_dwe_queue, entry)
                env.info("[DWE] LAND queued: " .. entry)
            end

        elseif id == 15 then
            local p = _pilot(e.initiator)
            if p ~= "AI" then
                local entry = _json({ type = "SLOT_IN", mission_time = t,
                    pilot = p, unit = _uname(e.initiator),
                    unit_type = _utype(e.initiator) })
                table.insert(_dwe_queue, entry)
                env.info("[DWE] SLOT_IN queued: " .. entry)
            end
        end
    end)

    if not ok then
        env.error("[DWE] onEvent error id=" .. tostring(id) .. ": " .. tostring(err))
    end
end

local ok, err = pcall(function()
    world.addEventHandler(_dwe_handler)
end)
if ok then
    env.info("[DWE] world.addEventHandler SUCCESS")
else
    env.error("[DWE] world.addEventHandler FAILED: " .. tostring(err))
end
