--[[ 
========================================================================================
Spawn and Explode from Map Labels (F10 Map Marks)
========================================================================================

HOW IT WORKS:
1. Open the F10 Map in-game.
2. Place a Mark Point (label) anywhere on the map.
3. In the text box of the mark point, type a specific command and press Enter.

AVAILABLE COMMANDS:
1. Explode
   Command: explode
   Effect: Creates a large explosion at the location of the mark. Useful for testing.
   
2. Spawn a Group
   Command: spawn-<GroupName>
   Example: spawn-RED TANK
   Effect: Spawns a clone of the Late Activated group named <GroupName> at the mark's location.
           The group MUST exist in the mission editor and be set to "Late Activation".
           It supports names with dashes, e.g., spawn-M-113.

NOTES:
- The command prefix is case-insensitive (SPAWN-RED TANK and spawn-RED TANK both work).
- The group name itself is CASE-SENSITIVE as per DCS standards.
- The script automatically removes the mark after the command is executed.
========================================================================================
]]

local MapLabelHandler = {}

function MapLabelHandler:onEvent(event)
    -- DCS Event 25 = S_EVENT_MARK_ADDED
    -- DCS Event 26 = S_EVENT_MARK_CHANGE (Triggered when text is entered/updated)
    if event.id == 25 or event.id == 26 then
        if not event.text or event.text == "" then return end

        local text = event.text
        local textLower = text:lower()

        -- 1. EXPLODE COMMAND
        -- Trim spaces and check
        if textLower:match("^%s*explode%s*$") then
            trigger.action.explosion(event.pos, 1000)
            trigger.action.removeMark(event.idx)
            return
        end

        -- 2. SPAWN COMMAND
        -- Match exactly a command word, a hyphen, and the rest (the argument)
        local cmd, arg = text:match("^%s*(%a+)%-(.+)%s*$")
        
        if cmd and cmd:lower() == "spawn" and arg then
            local groupName = arg:match("^%s*(.-)%s*$") -- Trim leading/trailing spaces from group name
            
            -- Spawn using MOOSE framework wrapped in a pcall to prevent script crashes on bad group names
            local status, err = pcall(function()
                local alias = groupName .. "_" .. tostring(math.random(1000, 9999))
                local spawnObject = SPAWN:NewWithAlias(groupName, alias)
                
                -- event.pos uses x for North/South, z for East/West. Moose Vec2 uses x and y.
                spawnObject:SpawnFromVec2({x = event.pos.x, y = event.pos.z})
            end)

            if status then
                trigger.action.removeMark(event.idx)
                MESSAGE:New("Spawned: " .. groupName, 10):ToAll()
            else
                MESSAGE:New("Error spawning '" .. groupName .. "'. Make sure the Late Activated group exists exactly with this name.", 10):ToAll()
                env.info("MapLabelHandler Error: " .. tostring(err))
            end
        end
    end
end

world.addEventHandler(MapLabelHandler)

MESSAGE:New("Map Label Spawner script loaded! See F10 map for usage.", 10):ToAll()
