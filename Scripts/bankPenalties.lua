bankPenalties = {}
bankPenalties.version = "1.2.0"
bankPenalties.requiredLibs = {
	"dcsCommon",
	"cfxZones",
	"bank"
}

-- Aircraft categorization lookup tables (flyable modules only)
-- Names match DCS warehouses file exactly
bankPenalties.modernMultirolePlanes = {
	-- Modern Fox3/Advanced fighters only
	["F-16C_50"] = true,
	["FA-18C_hornet"] = true,
	["MiG-29S"] = true,
	["JF-17"] = true,            -- JF-17 Thunder
	["J-11A"] = true,            -- J-11A (Chinese Su-27 variant)
	["F-15E"] = true,
	["F-15ESE"] = true,
	["F-15C"] = true,
}

bankPenalties.coldWarBomberPlanes = {
	-- Cold War era and Fox2 modern fighters
	["Su-25"] = true,
	["Su-25T"] = true,
	["Su-25TM"] = true,
	["MiG-29A"] = true,
	["MiG-29 Fulcrum"] = true,
	["Su-27"] = true,
	["Su-30"] = true,
	["Su-33"] = true,
	
	-- F-4 Phantom variants
	["F-4E"] = true,
	["F-4E-45MC"] = true,
	
	-- F-5 Tiger variants
	["F-5E"] = true,
	["F-5E-3"] = true,
	["F-5E-3_FC"] = true,
	
	-- Mirage 2000 variants
	["M-2000C"] = true,
	
	-- Mirage F1 variants
	["Mirage-F1AD"] = true,
	["Mirage-F1CR"] = true,
	["Mirage-F1BD"] = true,
	["Mirage-F1M-EE"] = true,
	["Mirage-F1EQ"] = true,
	["Mirage-F1C"] = true,
	["Mirage-F1CE"] = true,
	["Mirage-F1BE"] = true,
	["Mirage-F1CZ"] = true,
	["Mirage-F1M-CE"] = true,
}

bankPenalties.attackHelis = {
	-- Attack/Combat helicopters
	["AH-64D"] = true,
	["AH-64D_BLK_II"] = true,
	["Ka-50"] = true,
	["Ka-50_3"] = true,
	["Mi-28N"] = true,
	["Mi-24P"] = true,
	["Mi-24V"] = true,
	["OH-58D"] = true,
	["OH-58D(R)"] = true,
}

bankPenalties.transportHelis = {
	-- Transport/Utility helicopters
	["UH-1H"] = true,
	["Mi-8MT"] = true,
}

-- Default penalties if config zone is not found
bankPenalties.modernMultirolePlanePenalty = 100
bankPenalties.coldWarBomberPlanePenalty = 75
bankPenalties.attackHeliPenalty = 50
bankPenalties.transportHeliPenalty = 25
bankPenalties.verbose = false

-- Keep track of active players: key = unitName, value = {coaName, category, displayName}
bankPenalties.activePlayers = {}  

function bankPenalties.readConfigZone()
	local theZone = cfxZones.getZoneByName("bankPenaltyConfig") 
	if not theZone then 
		theZone = cfxZones.createSimpleZone("bankPenaltyConfig") 
	end 
	
	bankPenalties.modernMultirolePlanePenalty = theZone:getNumberFromZoneProperty("modernMultirolePlanePenalty", 150)
	bankPenalties.coldWarBomberPlanePenalty = theZone:getNumberFromZoneProperty("coldWarBomberPlanePenalty", 200)
	bankPenalties.attackHeliPenalty = theZone:getNumberFromZoneProperty("attackHeliPenalty", 100)
	bankPenalties.transportHeliPenalty = theZone:getNumberFromZoneProperty("transportHeliPenalty", 50)
	bankPenalties.verbose = theZone:getBoolFromZoneProperty("verbose", false)
end

function bankPenalties.categorizeAircraft(unitDesc, unitTypeName)
	-- Check if it's a helicopter or plane
	if unitDesc.category == Unit.Category.HELICOPTER then
		if bankPenalties.attackHelis[unitTypeName] then
			return "attackHeli", "Attack Helicopter"
		else
			return "transportHeli", "Transport Helicopter"
		end
	elseif unitDesc.category == Unit.Category.AIRPLANE then
		if bankPenalties.modernMultirolePlanes[unitTypeName] then
			return "modernMultirolePlane", "Modern/Multi-role"
		elseif bankPenalties.coldWarBomberPlanes[unitTypeName] then
			return "coldWarBomberPlane", "Cold War/Bomber"
		else
			-- Default to modern if not categorized
			return "modernMultirolePlane", "Modern/Multi-role (uncategorized)"
		end
	else
		return "unknown", "Unknown"
	end
end

function bankPenalties.getPenaltyAmount(category)
	if category == "attackHeli" then
		return bankPenalties.attackHeliPenalty
	elseif category == "transportHeli" then
		return bankPenalties.transportHeliPenalty
	elseif category == "modernMultirolePlane" then
		return bankPenalties.modernMultirolePlanePenalty
	elseif category == "coldWarBomberPlane" then
		return bankPenalties.coldWarBomberPlanePenalty
	else
		return bankPenalties.modernMultirolePlanePenalty -- fallback
	end
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
					-- Get unit type name for categorization
					local unitTypeName = desc.typeName or "unknown"
					local category, displayName = bankPenalties.categorizeAircraft(desc, unitTypeName)
					
					-- Normalize unit name to lowercase to handle DCS case inconsistencies
					local normalizedUName = string.lower(uName)
					bankPenalties.activePlayers[normalizedUName] = {
						coaName = coaName,
						category = category,
						displayName = displayName,
						playerName = playerName
					}
					if bankPenalties.verbose then
						trigger.action.outText("bankPenalties: registered " .. playerName .. " (" .. normalizedUName .. ") [" .. displayName .. "] for tracking", 10)
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
			
			local penaltyAmt = bankPenalties.getPenaltyAmount(playerData.category)
			
			-- Withdraw funds using the public bank API
			local successBank = bank.withdawFunds(playerData.coaName, penaltyAmt)
			
			if successBank then
				-- Get updated balance
				local balanceSuccess, newBalance = bank.getBalance(playerData.coaName)
				local balanceStr = balanceSuccess and tostring(newBalance) or "unknown"
				
				local msg = "⚠️ Penalty! " .. playerData.playerName .. " [" .. playerData.displayName .. "] " .. reason .. ". " .. string.upper(playerData.coaName) .. " lost §" .. penaltyAmt .. " (Balance: §" .. balanceStr .. ")"
				
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
	local penaltyInfo = "Modern/Multi: §" .. bankPenalties.modernMultirolePlanePenalty .. 
		" | CW/Bomber: §" .. bankPenalties.coldWarBomberPlanePenalty ..
		" | Attack Heli: §" .. bankPenalties.attackHeliPenalty ..
		" | Transport Heli: §" .. bankPenalties.transportHeliPenalty
	trigger.action.outText("bankPenalties v" .. bankPenalties.version .. " started." .. verboseMsg .. " | Penalties: " .. penaltyInfo, 30)
	return true 
end

if not bankPenalties.start() then 
	trigger.action.outText("bankPenalties aborted: missing libraries", 30)
	bankPenalties = nil 
end
