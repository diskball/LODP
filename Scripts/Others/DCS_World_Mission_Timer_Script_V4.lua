-- ======================================================================
-- DCS WORLD MISSION TIMER SCRIPT V4 - FIXED
-- Fixes: welcomeMessageDuration undefined, warnings never firing,
--        warningsIssued never written, missing regular time checks,
--        missing final warning logic, missing autosave logic
-- ======================================================================

-- ================= CONFIG =================

local missionName = "Lock-on Greece Dynamic Playground by =GR= Diskball"

local countdownDuration        = 10 * 60
local countdownFirstWarning    = 5 * 60
local countdownWarningInterval = 60
local countdownFinalWarnings   = {30, 10, 5}

local countdownWarningMessage  = "Attention: %s remaining until action clearance!"
local countdownCompleteMessage = "=== FIGHT is ON! Cleared to take off ==="
local countdownCompleteSound   = "Fight Is On.ogg"

local fonFlagName = "FON"

local welcomeMessageDuration = 30   -- FIX: was undefined in original

local missionDuration            = 4 * 3600
local missionStartMessage        = "=== Mission Started ===\nDuration: %s\nUse F10 menu to check remaining time"
local missionStartMessageDuration = 45

local regularTimeCheckInterval  = 30 * 60
local regularTimeMessage        = "Time remaining: %s"
local regularTimeMessageDuration = 15

local finalWarningThreshold     = 30 * 60
local finalWarningStartTime     = 15 * 60
local finalWarningInterval      = 60
local finalWarningFinalSeconds  = {30, 10, 5}

local finalWarningMessage        = "Attention: Only %s remaining!"
local finalWarningMessageDuration = 20
local finalWarningSoundFile      = "Radio squelch.ogg"

local autoSaveInterval  = 30 * 60
local autoSaveFlagName  = "saveScore"

local missionEndFlagName        = "missionend"
local missionEndMessage         = "=== Mission ended. The winner will be announced by the saved scores. ==="
local missionEndMessageDuration = 55
local missionEndSoundFile       = "taps.ogg"

local restartFlagName      = "simpleMissionRestart"
local restartFlagDelay     = 60
local restartFlagStayActive = true

local enableF10Menu    = true
local f10MenuName      = "Check Remaining Time"
local f10MenuSubmenu   = nil

local enableSoundWarnings = true
local defaultWarningSound = "warning.ogg"

-- ================= STATE =================

startTime    = timer.getTime()
currentMode  = "countdown"
missionEnded = false

-- FIX: warningsIssued is now actually used — keys are threshold values
-- e.g. warningsIssued["countdown_300"] = true means the 5-min warning fired
warningsIssued = {}

-- Tracks the last regular time-check that was announced (in mission mode)
lastRegularCheck = 0

-- Tracks the last autosave that fired
lastAutoSave = 0

-- ================= UTIL =================

local function formatTime(seconds)
    seconds = math.floor(seconds)
    if seconds <= 0 then return "00:00" end
    if seconds >= 3600 then
        return string.format("%02d:%02d:%02d",
            math.floor(seconds / 3600),
            math.floor((seconds % 3600) / 60),
            math.floor(seconds % 60))
    elseif seconds >= 60 then
        return string.format("%02d:%02d",
            math.floor(seconds / 60),
            math.floor(seconds % 60))
    else
        return seconds .. " sec"
    end
end

local function getRemainingTime()
    local elapsed   = timer.getTime() - startTime
    local duration  = (currentMode == "countdown") and countdownDuration or missionDuration
    return math.max(0, duration - elapsed)
end

local function playSound(sound)
    if enableSoundWarnings and sound then
        pcall(function() trigger.action.outSound(sound) end)
    end
end

local function safeSchedule(func, delay)
    timer.scheduleFunction(func, nil, timer.getTime() + delay)
end

-- ================= F10 MENU =================

local function createF10Menu()
    if not enableF10Menu then return end

    local function menuCallback()
        local remaining = getRemainingTime()
        local formatted = formatTime(remaining)

        if currentMode == "countdown" then
            trigger.action.outText("Countdown remaining: " .. formatted, 15)
        else
            trigger.action.outText("Mission time remaining: " .. formatted, 15)
        end
    end

    if f10MenuSubmenu then
        missionCommands.addCommand(f10MenuName, f10MenuSubmenu, menuCallback)
    else
        missionCommands.addCommand(f10MenuName, nil, menuCallback)
    end
end

-- ================= COUNTDOWN WARNINGS =================

local function checkCountdownWarnings(remaining)
    -- Interval warnings (every countdownWarningInterval seconds, starting at countdownFirstWarning)
    if remaining <= countdownFirstWarning and remaining > 0 then
        -- Round to nearest interval bucket
        local bucket = math.ceil(remaining / countdownWarningInterval) * countdownWarningInterval
        local key    = "countdown_interval_" .. tostring(bucket)

        if not warningsIssued[key] and remaining <= bucket then
            warningsIssued[key] = true
            trigger.action.outText(
                string.format(countdownWarningMessage, formatTime(remaining)), 15)
            playSound(defaultWarningSound)
        end
    end

    -- Final-seconds warnings (e.g. 30, 10, 5)
    for _, threshold in ipairs(countdownFinalWarnings) do
        local key = "countdown_final_" .. tostring(threshold)
        if not warningsIssued[key] and remaining <= threshold and remaining > 0 then
            warningsIssued[key] = true
            trigger.action.outText(
                string.format(countdownWarningMessage, formatTime(remaining)), 15)
            playSound(defaultWarningSound)
        end
    end
end

-- ================= MISSION WARNINGS =================

local function checkMissionWarnings(remaining)
    -- Regular interval announcements (every regularTimeCheckInterval)
    local elapsed          = missionDuration - remaining
    local intervalsPassed  = math.floor(elapsed / regularTimeCheckInterval)

    if intervalsPassed > lastRegularCheck and remaining > 0 then
        lastRegularCheck = intervalsPassed
        trigger.action.outText(
            string.format(regularTimeMessage, formatTime(remaining)),
            regularTimeMessageDuration)
    end

    -- Final warning phase: every finalWarningInterval once below finalWarningThreshold,
    -- switching to finalWarningStartTime for tighter warnings
    if remaining <= finalWarningThreshold and remaining > finalWarningStartTime then
        local bucket = math.ceil(remaining / finalWarningInterval) * finalWarningInterval
        local key    = "mission_final_interval_" .. tostring(bucket)

        if not warningsIssued[key] and remaining <= bucket then
            warningsIssued[key] = true
            trigger.action.outText(
                string.format(finalWarningMessage, formatTime(remaining)),
                finalWarningMessageDuration)
            playSound(finalWarningSoundFile)
        end
    end

    -- Tight final warnings once inside finalWarningStartTime
    if remaining <= finalWarningStartTime and remaining > 0 then
        local bucket = math.ceil(remaining / finalWarningInterval) * finalWarningInterval
        local key    = "mission_tight_" .. tostring(bucket)

        if not warningsIssued[key] and remaining <= bucket then
            warningsIssued[key] = true
            trigger.action.outText(
                string.format(finalWarningMessage, formatTime(remaining)),
                finalWarningMessageDuration)
            playSound(finalWarningSoundFile)
        end
    end

    -- Final-seconds warnings (e.g. 30, 10, 5)
    for _, threshold in ipairs(finalWarningFinalSeconds) do
        local key = "mission_final_" .. tostring(threshold)
        if not warningsIssued[key] and remaining <= threshold and remaining > 0 then
            warningsIssued[key] = true
            trigger.action.outText(
                string.format(finalWarningMessage, formatTime(remaining)),
                finalWarningMessageDuration)
            playSound(finalWarningSoundFile)
        end
    end
end

-- ================= AUTOSAVE =================

local function checkAutoSave()
    if currentMode ~= "mission" then return end

    local elapsed        = timer.getTime() - startTime
    local savesPassed    = math.floor(elapsed / autoSaveInterval)

    if savesPassed > lastAutoSave then
        lastAutoSave = savesPassed
        trigger.action.setUserFlag(autoSaveFlagName, 1)
        -- Reset the flag after 1 second so it can fire again
        safeSchedule(function()
            trigger.action.setUserFlag(autoSaveFlagName, 0)
        end, 1)
    end
end

-- ================= MAIN LOOP =================

local function checkWarnings()
    if missionEnded then return end

    local remaining = getRemainingTime()

    if currentMode == "countdown" then

        if remaining <= 0 then
            -- Countdown finished — start the mission
            trigger.action.outText(countdownCompleteMessage, 20)
            playSound(countdownCompleteSound)
            trigger.action.setUserFlag(fonFlagName, 1)

            currentMode      = "mission"
            startTime        = timer.getTime()
            warningsIssued   = {}
            lastRegularCheck = 0
            lastAutoSave     = 0

            trigger.action.outText(
                string.format(missionStartMessage, formatTime(missionDuration)),
                missionStartMessageDuration)
        else
            -- FIX: actually fire countdown warnings
            checkCountdownWarnings(remaining)
        end

    else -- mission mode

        if remaining <= 0 then
            -- Mission over
            missionEnded = true
            trigger.action.setUserFlag(missionEndFlagName, 1)
            trigger.action.outText(missionEndMessage, missionEndMessageDuration)
            playSound(missionEndSoundFile)

            safeSchedule(function()
                trigger.action.setUserFlag(restartFlagName, 1)
            end, restartFlagDelay)

            return  -- Stop the loop
        else
            -- FIX: fire mission warnings and autosave
            checkMissionWarnings(remaining)
            checkAutoSave()
        end

    end

    safeSchedule(checkWarnings, 1)
end

-- ================= INIT =================

trigger.action.outText(
    "=== Welcome to Lock-On Greece Server ===\n" ..
    "Mission: " .. missionName .. "\n" ..
    "Countdown: " .. formatTime(countdownDuration),
    welcomeMessageDuration   -- FIX: now defined
)

trigger.action.outText(
    "=== STARTUP COUNTDOWN STARTED ===\nFight is On in " ..
    formatTime(countdownDuration),
    15
)

-- Create F10 menu at mission start
createF10Menu()

-- Start the main loop
safeSchedule(checkWarnings, 1)
