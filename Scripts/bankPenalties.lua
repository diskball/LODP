bankPenalties = {}
bankPenalties.version = "1.2.0"
bankPenalties.requiredLibs = {
	"dcsCommon",
	"cfxZones",
	"bank"
}

-- Default penalties if config zone is not found
bankPenalties.planePenalty = 100
bankPenalties.heliPenalty = 50
bankPenalties.verbose = false

-- Keep track of active players: key = unitName, value = {coaName, isPlane}
bankPenalties.activePlayers = {} 

function bankPenalties.readConfigZone()
	local theZone = cfxZones.getZoneByName("bankPenaltyConfig") 
	if not theZone then 
		theZone = cfxZones.createSimpleZone("bankPenaltyConfig") 
	end 
	
	bankPenalties.planePenalty = theZone:getNumberFromZoneProperty("planePenalty", 100)
	bankPenalties.heliPenalty = theZone:getNumberFromZoneProperty("heliPenalty", 50)
	bankPenalties.verbose = theZone:getBoolFromZoneProperty("verbose", false)
end

bankPenalties.eventHandler = {}
function bankPenalties.eventHandler:onEvent(event)
	if not event.initiator then return end
	
	local id = event.id
	
	-- Register players when they spawn or enter a slot
	if id == world.event.S_EVENT_BIRTH or id == world.event.S_EVENT_PLAYER_ENTER_UNIT then
		local unit = event.initiator
		local eventName = (id == world.event.S_EVENT_BIRTH) and "BIRTH" or "PLAYER_ENTER_UNIT"
		
		-- Safely get unit name
		local success, uName = pcall(unit.getName, unit)
		if not success or not uName then
			if bankPenalties.verbose then
				trigger.action.outText("bankPenalties: " .. eventName .. " event - could not get unit name", 10)
			end
			return
		end
		
		-- Check if it's a unit with a player
		local hasGetPlayerName = type(unit.getPlayerName) == "function"
		local playerName = nil
		if hasGetPlayerName then
			local pSuccess, pName = pcall(unit.getPlayerName, unit)
			if pSuccess then playerName = pName end
		end
		
		if playerName then
			local desc = unit:getDesc()
			if desc and (desc.category == Unit.Category.AIRPLANE or desc.category == Unit.Category.HELICOPTER) then
				local coa = unit:getCoalition()
				local coaName = "neutral"
				if coa == 1 then coaName = "red" end
				if coa == 2 then coaName = "blue" end
				
				if coaName ~= "neutral" then
					local airframeType = (desc.category == Unit.Category.AIRPLANE) and "plane" or "heli"
					-- Normalize unit name to lowercase to handle DCS case inconsistencies
					local normalizedUName = string.lower(uName)
					bankPenalties.activePlayers[normalizedUName] = {
						coaName = coaName,
						isPlane = (desc.category == Unit.Category.AIRPLANE),
						playerName = playerName
					}
					if bankPenalties.verbose then
						trigger.action.outText("bankPenalties: registered " .. playerName .. " (" .. normalizedUName .. ") " .. airframeType .. " for tracking", 10)
					end
				else
					if bankPenalties.verbose then
						trigger.action.outText("bankPenalties: " .. eventName .. " " .. uName .. " - neutral coalition, ignoring", 10)
					end
				end
			else
				if bankPenalties.verbose then
					local catStr = desc and desc.category or "unknown"
					trigger.action.outText("bankPenalties: " .. eventName .. " " .. uName .. " - not an aircraft (cat=" .. tostring(catStr) .. "), ignoring", 10)
				end
			end
		else
			if bankPenalties.verbose then
				trigger.action.outText("bankPenalties: " .. eventName .. " " .. uName .. " - no player found", 10)
			end
		end
		return
	end

	-- Process events that could lead to a penalty
	if id == world.event.S_EVENT_PLAYER_LEAVE_UNIT or 
	   id == world.event.S_EVENT_EJECTION or
	   id == world.event.S_EVENT_CRASH or 
	   id == world.event.S_EVENT_DEAD or 
	   id == world.event.S_EVENT_PILOT_DEAD then
		
		local unit = event.initiator
		
		-- Safely get the name of the unit, even if it's destroyed
		local success, uName = pcall(unit.getName, unit)
		if not success or not uName then 
			if bankPenalties.verbose then
				trigger.action.outText("bankPenalties: could not get unit name for event " .. id, 10)
			end
			return 
		end
		
		-- Normalize unit name to lowercase to match registration
		local normalizedUName = string.lower(uName)
		
		-- If this unit wasn't being flown by a player (or was already penalized), ignore it
		if not bankPenalties.activePlayers[normalizedUName] then 
			if bankPenalties.verbose then
				trigger.action.outText("bankPenalties: unit " .. normalizedUName .. " not in tracking (event " .. id .. ")", 10)
			end
			return 
		end
		
		local playerData = bankPenalties.activePlayers[normalizedUName]
		local applyPenalty = false
		local reason = ""
		
		if id == world.event.S_EVENT_PLAYER_LEAVE_UNIT then
			-- For leaving the unit, we only penalize if they are not safely on the ground
			local inAir = false
			local isSafe = true
			
			if Object.isExist(unit) then
				if type(unit.inAir) == "function" and unit:inAir() then
					inAir = true
					isSafe = false
				else
					-- Check altitude / speed
					local sPt, point = pcall(unit.getPoint, unit)
					local sVel, vel = pcall(unit.getVelocity, unit)
					
					if sPt and point then
						local surfaceHeight = land.getHeight({x = point.x, y = point.z})
						if (point.y - surfaceHeight) > 5 then
							inAir = true
							isSafe = false
						end
					end
					
					-- If they are moving faster than 5 m/s (~10 knots) on the ground, not safe
					if isSafe and sVel and vel then
						local speed = math.sqrt(vel.x^2 + vel.y^2 + vel.z^2)
						if speed > 5 then
							isSafe = false
						end
					end
				end
			else
				-- If the object doesn't exist, it's not safe to assume they were on the ground
				isSafe = false
			end
			
			if not isSafe then
				applyPenalty = true
				reason = "disconnected mid-air or while moving"
			else
				-- Safe disconnect on the ground, just unregister without penalty
				if bankPenalties.verbose then
					trigger.action.outText("bankPenalties: " .. playerData.playerName .. " (" .. normalizedUName .. ") disconnected safely on ground, unregistering", 10)
				end
				bankPenalties.activePlayers[normalizedUName] = nil
				return
			end
		elseif id == world.event.S_EVENT_EJECTION then
			applyPenalty = true
			reason = "ejected"
			if bankPenalties.verbose then
				trigger.action.outText("bankPenalties: " .. playerData.playerName .. " (" .. normalizedUName .. ") EJECTED", 10)
			end
		elseif id == world.event.S_EVENT_CRASH then
			applyPenalty = true
			reason = "crashed"
			if bankPenalties.verbose then
				trigger.action.outText("bankPenalties: " .. playerData.playerName .. " (" .. normalizedUName .. ") CRASHED", 10)
			end
		elseif id == world.event.S_EVENT_DEAD then
			applyPenalty = true
			reason = "was destroyed"
			if bankPenalties.verbose then
				trigger.action.outText("bankPenalties: " .. playerData.playerName .. " (" .. normalizedUName .. ") DEAD", 10)
			end
		elseif id == world.event.S_EVENT_PILOT_DEAD then
			applyPenalty = true
			reason = "was killed in action"
			if bankPenalties.verbose then
				trigger.action.outText("bankPenalties: " .. playerData.playerName .. " (" .. normalizedUName .. ") PILOT_DEAD", 10)
			end
		end
		
		if applyPenalty then
			-- IMMEDIATELY unregister to prevent double-charging (e.g., Ejection -> Crash cascade)
			bankPenalties.activePlayers[normalizedUName] = nil
			
			local penaltyAmt = playerData.isPlane and bankPenalties.planePenalty or bankPenalties.heliPenalty
			
			-- Withdraw funds using the public bank API
			local successBank = bank.withdawFunds(playerData.coaName, penaltyAmt)
			
			if successBank then
				-- Get updated balance
				local balanceSuccess, newBalance = bank.getBalance(playerData.coaName)
				local balanceStr = balanceSuccess and tostring(newBalance) or "unknown"
				
				local airframeType = playerData.isPlane and "plane" or "helicopter"
				local msg = "⚠️ Penalty! " .. playerData.playerName .. "'s " .. airframeType .. " " .. reason .. ". " .. string.upper(playerData.coaName) .. " lost §" .. penaltyAmt .. " (Balance: §" .. balanceStr .. ")"
				
				local coaId = (playerData.coaName == "red") and 1 or 2
				
				-- ALWAYS send penalty message to coalition (regardless of verbose setting)
				trigger.action.outTextToCoalition(coaId, msg, 15)
				
				-- Additional debug logging when verbose enabled
				if bankPenalties.verbose then
					trigger.action.outText("[DEBUG] bankPenalties: penalized " .. playerData.playerName .. " (" .. playerData.coaName .. ") §" .. penaltyAmt .. " for " .. reason .. " | New balance: §" .. balanceStr, 10)
				end
			else
				-- Bank withdrawal failed - still notify coalition
				local coaId = (playerData.coaName == "red") and 1 or 2
				local errMsg = "❌ Penalty system error: insufficient funds or account error"
				trigger.action.outTextToCoalition(coaId, errMsg, 15)
				
				if bankPenalties.verbose then
					trigger.action.outText("[DEBUG] bankPenalties: FAILED to withdraw §" .. penaltyAmt .. " from " .. playerData.coaName, 10)
				end
			end
		end
	end
end

function bankPenalties.start()
	if not dcsCommon.libCheck then 
		trigger.action.outText("bankPenalties requires dcsCommon", 30)
		return false 
	end 
	if not dcsCommon.libCheck("bankPenalties", bankPenalties.requiredLibs) then
		return false 
	end
	
	bankPenalties.readConfigZone()
	world.addEventHandler(bankPenalties.eventHandler)

	local verboseMsg = bankPenalties.verbose and " (VERBOSE MODE)" or ""
	trigger.action.outText("bankPenalties v" .. bankPenalties.version .. " started." .. verboseMsg .. " Plane penalty: §" .. bankPenalties.planePenalty .. ", Heli penalty: §" .. bankPenalties.heliPenalty, 30)
	return true 
end

if not bankPenalties.start() then 
	trigger.action.outText("bankPenalties aborted: missing libraries", 30)
	bankPenalties = nil 
end
