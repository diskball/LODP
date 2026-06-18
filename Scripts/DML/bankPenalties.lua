bankPenalties = {}
bankPenalties.version = "1.3.0"
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
	-- Attack/Combat helicopters and heavy cargo aircraft (same penalty tier)
	["AH-64D_BLK_II"] = true,
	["Ka-50"] = true,
	["Ka-50_3"] = true,
	["Mi-28N"] = true,
	["Mi-24P"] = true,
	["OH58D"] = true,
	["CH-47Fbl1"] = true,   -- heavy cargo heli
	["C-130J-30"] = true,   -- cargo fixed-wing
}

bankPenalties.transportHelis = {
	-- Transport/Utility helicopters
	["UH-1H"] = true,
	["UH-60L"] = true,
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
		if bankPenalties.attackHelis[unitTypeName] then
			return "attackHeli", "Cargo Transport"
		elseif bankPenalties.modernMultirolePlanes[unitTypeName] then
			return "modernMultirolePlane", "Modern/Multi-role"
		elseif bankPenalties.coldWarBomberPlanes[unitTypeName] then
			return "coldWarBomberPlane", "Cold War/Bomber"
		else
			-- Default to cold war tier if not categorized
			return "coldWarBomberPlane", "Cold War/Bomber (uncategorized)"
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

-- Public function called by cfxBaseEnforcer (and any other module) to apply
-- a loss penalty directly. Handles units not yet in activePlayers by
-- reconstructing playerData from the live unit object.
function bankPenalties.penalizeUnit(unit, reason)
	if not unit then return end
	local success, uName = pcall(unit.getName, unit)
	if not success or not uName then return end
	local normalizedUName = string.lower(uName)
	local playerData = bankPenalties.activePlayers[normalizedUName]
	if not playerData then
		local pSuccess, pName = pcall(unit.getPlayerName, unit)
		if not pSuccess or not pName then return end
		local dSuccess, desc = pcall(unit.getDesc, unit)
		if not dSuccess or not desc then return end
		if desc.category ~= Unit.Category.AIRPLANE and desc.category ~= Unit.Category.HELICOPTER then return end
		local coa = unit:getCoalition()
		local coaName = coa == 1 and "red" or coa == 2 and "blue" or "neutral"
		if coaName == "neutral" then return end
		local category, displayName = bankPenalties.categorizeAircraft(desc, desc.typeName or "unknown")
		playerData = { coaName = coaName, category = category, displayName = displayName, playerName = pName }
	end
	-- Unregister immediately to prevent double-charging from subsequent events (e.g. PLAYER_LEAVE_UNIT)
	bankPenalties.activePlayers[normalizedUName] = nil
	local penaltyAmt = bankPenalties.getPenaltyAmount(playerData.category)
	local successBank = bank.withdawFunds(playerData.coaName, penaltyAmt)
	local coaId = (playerData.coaName == "red") and 1 or 2
	if successBank then
		local balanceSuccess, newBalance = bank.getBalance(playerData.coaName)
		local balanceStr = balanceSuccess and tostring(newBalance) or "unknown"
		local msg = "⚠️ Penalty! " .. playerData.playerName .. " [" .. playerData.displayName .. "] "
			.. (reason or "violated base rules") .. ". "
			.. string.upper(playerData.coaName) .. " lost §" .. penaltyAmt .. " (Balance: §" .. balanceStr .. ")"
		trigger.action.outTextForCoalition(coaId, msg, 15)
	else
		trigger.action.outTextForCoalition(coaId, "❌ Penalty system error: could not charge penalty", 15)
	end
	if bankPenalties.verbose then
		trigger.action.outText("[DEBUG] bankPenalties.penalizeUnit: penalized " .. uName .. " for: " .. (reason or "?"), 10)
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

	-- Process Safe Landing Bonus (Fixed-wing planes only)
	if id == world.event.S_EVENT_LAND then
		local unit = event.initiator
		local airbase = event.place
		
		local success, uName = pcall(unit.getName, unit)
		if success and uName then
			local normalizedUName = string.lower(uName)
			local playerData = bankPenalties.activePlayers[normalizedUName]
			
			-- Check if player is tracked and is NOT a helicopter
			if playerData and playerData.category ~= "attackHeli" and playerData.category ~= "transportHeli" then
				-- Ensure they landed on a valid airbase/carrier that has a getCoalition function
				if airbase and type(airbase.getCoalition) == "function" then
					local abCoa = airbase:getCoalition()
					local unitCoa = unit:getCoalition()
					
					if abCoa == unitCoa then
						local now = timer.getTime()
						-- 60 second debounce to prevent bouncing/touch-and-go exploits
						if not playerData.lastLandTime or (now - playerData.lastLandTime) > 60 then
							playerData.lastLandTime = now
							
							local bonusAmt = 10
							local successBank = bank.addFunds(playerData.coaName, bonusAmt)
							if successBank then
								local balanceSuccess, newBalance = bank.getBalance(playerData.coaName)
								local balanceStr = balanceSuccess and tostring(newBalance) or "unknown"
								local msg = "🛬 Safe Return! " .. playerData.playerName .. " [" .. playerData.displayName .. "] landed safely at a friendly base. " .. string.upper(playerData.coaName) .. " received a bonus of §" .. bonusAmt .. " (Balance: §" .. balanceStr .. ")"
								local coaId = (playerData.coaName == "red") and 1 or 2
								trigger.action.outTextForCoalition(coaId, msg, 15)
							end
						end
					end
				end
			end
		end
	end

	-- Clean up tracking on any loss/leave event.
	-- No coalition bank penalty: aircraft loss affects player score only (via armamentCost).
	if id == world.event.S_EVENT_PLAYER_LEAVE_UNIT or
	   id == world.event.S_EVENT_EJECTION or
	   id == world.event.S_EVENT_CRASH or
	   id == world.event.S_EVENT_DEAD or
	   id == world.event.S_EVENT_PILOT_DEAD then

		local unit = event.initiator
		local success, uName = pcall(unit.getName, unit)
		if not success or not uName then return end

		local normalizedUName = string.lower(uName)
		if bankPenalties.activePlayers[normalizedUName] then
			if bankPenalties.verbose then
				local pd = bankPenalties.activePlayers[normalizedUName]
				trigger.action.outText("bankPenalties: unregistered " .. (pd.playerName or uName)
					.. " (event " .. id .. ") — no bank penalty", 10)
			end
			bankPenalties.activePlayers[normalizedUName] = nil
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

	local verboseMsg = bankPenalties.verbose and " (VERBOSE)" or ""
	trigger.action.outText("bankPenalties v" .. bankPenalties.version .. " loaded"
		.. verboseMsg .. " | Safe-landing bank bonus active | Aircraft loss: player score only (no bank penalty)", 15)
	return true 
end

if not bankPenalties.start() then 
	trigger.action.outText("bankPenalties aborted: missing libraries", 30)
	bankPenalties = nil 
end
