--[[
    loadzoneMarks.lua
    Version: 1.0.0

    PURPOSE:
    Scans cfxZones.zones for every zone whose name starts with "Loadzone "
    and places a read-only F10 map mark visible to both RED and BLUE coalitions.

    DEPENDENCY:
    - cfxZones (must be loaded before this script)

    INSTALLATION:
    Load AFTER cfxZones in the Mission Editor trigger sequence.
    (It can safely run before or after CTLD — it does its own zone discovery.)

    MARK ID RANGE:
    Uses IDs [markIdBase, markIdBase + N - 1] where N = number of load zones.
    With 20 zones that is IDs 55000–55019. Adjust markIdBase if another script
    occupies that range.
--]]

loadzoneMarks = {}
loadzoneMarks.version  = "1.0.0"
loadzoneMarks.markIdBase = 55000  -- starting mark ID

local function addMarks()
    if not cfxZones or not cfxZones.zones then
        trigger.action.outText("loadzoneMarks: cfxZones not loaded — no marks placed.", 15)
        return
    end

    local markId = loadzoneMarks.markIdBase
    local count  = 0

    for _, zone in pairs(cfxZones.zones) do
        local name = zone.name
        -- Match any zone whose name begins with "Loadzone " (9 characters)
        if name and string.sub(name, 1, 9) == "Loadzone " then
            local dcsZone = trigger.misc.getZone(name)
            if dcsZone then
                local pos   = { x = dcsZone.point.x, y = 0, z = dcsZone.point.z }
                local label = "CTLD Load Zone\n" .. name

                trigger.action.markToAll(markId, label, pos, true, "")

                markId = markId + 1
                count  = count  + 1
            end
        end
    end

    trigger.action.outText("loadzoneMarks: placed " .. count .. " load zone marks on F10 map.", 10)
end

-- Delay 5 s to ensure cfxZones has fully parsed all mission trigger zones
timer.scheduleFunction(addMarks, {}, timer.getTime() + 5)

trigger.action.outText("loadzoneMarks v" .. loadzoneMarks.version .. " loaded.", 5)
