-- =============================================================
--  DCSWeaponEventsHook.lua
--  Place in: Saved Games\DCS.openbeta\Scripts\Hooks\
--
--  Drains _dwe_queue (written by the mission DO SCRIPT handler)
--  via net.dostring_in every ~0.5 s and sends each JSON line
--  over UDP to listener.py.
--
--  Both this hook and the mission script share the same mission
--  Lua state _G, so _dwe_queue is visible to both.
-- =============================================================

local function _log(msg)
    log.write("DCSWeaponEvents", log.INFO, tostring(msg))
end

-- ── Socket ────────────────────────────────────────────────────────────────────

local _udp       = nil
local _socket_ok = false

local function _init_socket()
    local ok, result = pcall(function()
        local u = require("socket").udp()
        assert(u:setpeername("127.0.0.1", 9876))
        return u
    end)
    if ok then
        _udp       = result
        _socket_ok = true
        _log("UDP socket open → 127.0.0.1:9876")
    else
        _log("Failed to open UDP socket: " .. tostring(result))
    end
end

_init_socket()

local function _send(json_str)
    if _socket_ok and _udp then
        local ok, err = pcall(function() _udp:send(json_str) end)
        if not ok then
            _log("UDP send error: " .. tostring(err))
        end
    end
end

-- ── Hook callbacks ────────────────────────────────────────────────────────────

local DCSWeaponEventsHook = {}

local _frame = 0

function DCSWeaponEventsHook.onSimulationStart()
    _frame = 0
    if not _socket_ok then
        _init_socket()
    end
    _log("Simulation started")
end

function DCSWeaponEventsHook.onSimulationFrame()
    _frame = _frame + 1
    if not _socket_ok then return end

    -- Drain queue ~2× per second (every 30 frames).
    if _frame % 30 ~= 0 then return end

    local batch = net.dostring_in("mission", [[
        if not _dwe_queue or #_dwe_queue == 0 then return "" end
        local out = table.concat(_dwe_queue, "\n")
        for i = #_dwe_queue, 1, -1 do _dwe_queue[i] = nil end
        return out
    ]])

    if batch and batch ~= "" then
        _log("Draining " .. #batch .. " bytes from queue")
        for line in batch:gmatch("[^\n]+") do
            _send(line)
        end
    end
end

function DCSWeaponEventsHook.onSimulationStop()
    _frame = 0
    _log("Simulation stopped")
    -- Keep socket open — it works across mission reloads within the same DCS session.
end

-- ── Register ──────────────────────────────────────────────────────────────────

local ok, err = pcall(function()
    DCS.setUserCallbacks(DCSWeaponEventsHook)
end)
if ok then
    _log("Hook registered")
else
    _log("Hook registration failed: " .. tostring(err))
end
