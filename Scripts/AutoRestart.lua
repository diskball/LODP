-- 5 hours = 5 * 60 * 60 = 18000 seconds
local restartTime = 18000

-- Warning 10 minutes before restart
SCHEDULER:New(nil, function()
    MESSAGE:New("Server restarting in 10 minutes!", 30, "SERVER"):ToAll()
end, {}, restartTime - 600)

-- Warning 1 minute before restart
SCHEDULER:New(nil, function()
    MESSAGE:New("Server restarting in 1 minute!", 20, "SERVER"):ToAll()
end, {}, restartTime - 60)

-- Execute the restart
SCHEDULER:New(nil, function()
    MESSAGE:New("Restarting Server...", 10, "SERVER"):ToAll()
    -- Restart via DCS GUI layer so it loads the current mission file dynamically,
    -- avoiding any hardcoded path in Mission Editor triggers.
    net.dostring_in("gui", "DCS.loadMission(DCS.getMissionFilepath())")
end, {}, restartTime)
