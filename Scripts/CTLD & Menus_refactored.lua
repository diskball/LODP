-- ==================
-- CTLD BUG FIXES
-- ==================
-- Fix MOOSE CTLD loading bugs where empty strings in saved templates crash the script
-- AND bypass the stock check so saved units always spawn regardless of current warehouse stock
local old_InjectVehicles = CTLD.InjectVehicles
function CTLD:InjectVehicles(Zone, Cargo, Surfacetypes, PreciseLocation, Structure, TimeStamp)
    local new_templates = {}
    for _, t in pairs(Cargo.Templates or {}) do
        if type(t) == "string" and t ~= "" then
            table.insert(new_templates, t)
        end
    end
    Cargo.Templates = new_templates

    local name = Cargo:GetName()
    if name then
        for _, _cgo in pairs(self.Cargo_Crates or {}) do
            if _cgo:GetName() == name then
                local stock = _cgo:GetStock()
                if stock ~= -1 and stock ~= nil then
                    _cgo:AddStock(1)
                end
                break
            end
        end
    end

    return old_InjectVehicles(self, Zone, Cargo, Surfacetypes, PreciseLocation, Structure, TimeStamp)
end

local old_InjectTroops = CTLD.InjectTroops
function CTLD:InjectTroops(Zone, Cargo, Surfacetypes, PreciseLocation, Structure, TimeStamp)
    local new_templates = {}
    for _, t in pairs(Cargo.Templates or {}) do
        if type(t) == "string" and t ~= "" then
            table.insert(new_templates, t)
        end
    end
    Cargo.Templates = new_templates

    local name = Cargo:GetName()
    if name then
        for _, _cgo in pairs(self.Cargo_Troops or {}) do
            if _cgo:GetName() == name then
                local stock = _cgo:GetStock()
                if stock ~= -1 and stock ~= nil then
                    _cgo:AddStock(1)
                end
                break
            end
        end
    end

    return old_InjectTroops(self, Zone, Cargo, Surfacetypes, PreciseLocation, Structure, TimeStamp)
end

-- ==================
-- CONFIGURATION
-- ==================

_SETTINGS:SetPlayerMenuOff()
_SETTINGS:SetEraModern()

local UNIT_CONFIG = {
    { id = "MANPADS",        menuName = "MANPADS",        ctldName = "Anti-Air",       type = CTLD_CARGO.Enum.TROOPS,  redGroup = "AAR",                blueGroup = "AAB",                 size = 1, mass = 90,   subcategory = "Anti-Air",       cost = 100 },
    { id = "Infantry Group", menuName = "Infantry Group", ctldName = "Infantry Group", type = CTLD_CARGO.Enum.TROOPS,  redGroup = "RIFLER",             blueGroup = "RIFLEB",              size = 4, mass = 90,   subcategory = "Troops",         cost = 50 },
    { id = "Scout",          menuName = "M-113",          ctldName = "M-113",          type = CTLD_CARGO.Enum.VEHICLE, redGroup = "RED SCOUT",          blueGroup = "BLUE SCOUT",          size = 1, mass = 1000, subcategory = "Scout",          cost = 100 },
    { id = "JTAC",           menuName = "JTAC",           ctldName = "JTAC",           type = CTLD_CARGO.Enum.VEHICLE, redGroup = "RED JTAC",           blueGroup = "BLUE JTAC",           size = 1, mass = 1000, subcategory = "Scout",          cost = 150 },
    { id = "T55",            menuName = "T-55",           ctldName = "T-55",           type = CTLD_CARGO.Enum.VEHICLE, redGroup = "RED T55",            blueGroup = "BLUE T55",            size = 1, mass = 1000, subcategory = "MBT",            cost = 150 },
    { id = "Shilka",         menuName = "Shilka",         ctldName = "Shilka",         type = CTLD_CARGO.Enum.VEHICLE, redGroup = "RED Shilka",         blueGroup = "BLUE Shilka",         size = 1, mass = 1000, subcategory = "Anti-Air",       cost = 180 },
    { id = "Chaparral",      menuName = "Chaparral",      ctldName = "Chaparral",      type = CTLD_CARGO.Enum.VEHICLE, redGroup = "RED Chaparral",      blueGroup = "BLUE Chaparral",      size = 1, mass = 1000, subcategory = "Anti-Air",       cost = 200 },
    { id = "Leopard",        menuName = "Leopard",        ctldName = "Leopard",        type = CTLD_CARGO.Enum.VEHICLE, redGroup = "RED TANK",           blueGroup = "BLUE TANK",           size = 1, mass = 1000, subcategory = "MBT",            cost = 400 },
    { id = "SA13",           menuName = "SA-13",          ctldName = "SA-13",          type = CTLD_CARGO.Enum.VEHICLE, redGroup = "RED SA13",           blueGroup = "BLUE SA13",           size = 1, mass = 1000, subcategory = "Anti-Air",       cost = 400 },
    { id = "SA8",            menuName = "SA-8",           ctldName = "SA-8",           type = CTLD_CARGO.Enum.VEHICLE, redGroup = "RED SA8",            blueGroup = "BLUE SA8",            size = 1, mass = 1000, subcategory = "Anti-Air",       cost = 400 },
    { id = "SA15M1",         menuName = "SA-15M1",        ctldName = "SA-15M1",        type = CTLD_CARGO.Enum.VEHICLE, redGroup = "RED SA15M1",         blueGroup = "BLUE SA15M1",         size = 2, mass = 1000, subcategory = "Anti-Air",       cost = 1550 },
    { id = "SA15M2",         menuName = "SA-15M2",        ctldName = "SA-15M2",        type = CTLD_CARGO.Enum.VEHICLE, redGroup = "RED SA15M2",         blueGroup = "BLUE SA15M2",         size = 3, mass = 1000, subcategory = "Anti-Air",       cost = 3000 },
    { id = "EWR",            menuName = "EWR",            ctldName = "EWR",            type = CTLD_CARGO.Enum.VEHICLE, redGroup = "RED EWR",            blueGroup = "BLUE EWR",            size = 1, mass = 1000, subcategory = "Anti-Air",       cost = 550 },
    { id = "SA10",           menuName = "SA-10",          ctldName = "SA-10",          type = CTLD_CARGO.Enum.VEHICLE, redGroup = "RED SA10",           blueGroup = "BLUE SA10",           size = 4, mass = 1000, subcategory = "Anti-Air",       cost = 10000 },
    --{ id = "Gaz66",          menuName = "Gaz-66 Truck",   ctldName = "Gaz-66 Truck",   type = CTLD_CARGO.Enum.VEHICLE, redGroup = "Truck_Red",          blueGroup = "Truck_Blue",          size = 1, mass = 1000, subcategory = "Transport",      cost = 100 },
    { id = "FARP_logistics", menuName = "FARP_logistics", ctldName = "FARP_logistics", type = CTLD_CARGO.Enum.VEHICLE, redGroup = "FARP_logistics_red", blueGroup = "FARP_logistics_blue", size = 1, mass = 1000, subcategory = "FARP Logistics", cost = 50 },
    { id = "Ammo truck",     menuName = "Ammo truck",     ctldName = "Ammo truck",     type = CTLD_CARGO.Enum.VEHICLE, redGroup = "Ammo_Truck_Red",     blueGroup = "Ammo_Truck_Blue",     size = 1, mass = 1000, subcategory = "FARP Logistics", cost = 25 },
}

local CHOPPER_CONFIG = {
    { type = "Mi-24P",        troops = true,  crates = true,  maxCrates = 1, maxTroops = 6,  length = 20, mass = 3000 },
    { type = "UH-1H",         troops = true,  crates = true,  maxCrates = 1, maxTroops = 6,  length = 15, mass = 1600 },
    { type = "UH-60L",        troops = true,  crates = true,  maxCrates = 2, maxTroops = 6,  length = 20, mass = 2600 },
    { type = "Mi-8MTV2",      troops = true,  crates = true,  maxCrates = 1, maxTroops = 12, length = 15, mass = 3000 },
    { type = "CH-47Fbl1",     troops = true,  crates = true,  maxCrates = 2, maxTroops = 31, length = 20, mass = 8000 },
    { type = "C-130J-30",     troops = true,  crates = true,  maxCrates = 7, maxTroops = 36, length = 35, mass = 21000 },
    { type = "AH-64D_BLK_II", troops = false, crates = false, maxCrates = 0, maxTroops = 0,  length = 17, mass = 200 },
    { type = "OH58D",         troops = false, crates = false, maxCrates = 0, maxTroops = 0,  length = 14, mass = 400 },
}

local TRUCK_CONFIG = {
    { type = "GAZ-66", troops = true, crates = true, maxCrates = 2, maxTroops = 6, length = 9, mass = 4200 },
}

local LOAD_ZONES = {
    "Loadzone Batumi",
    "Loadzone GH02",
    "Loadzone Sukhumi",
    "Loadzone FH66",
    "Loadzone Sochi",
    "Loadzone EJ44",
    "Loadzone KQ73",
    "Loadzone FH08",
    "Loadzone GJ35",
    "Loadzone EJ08",
    "Loadzone EJ58",
    "Loadzone FK72",
    "Loadzone Maykop",
    "Loadzone GH30",
    "Loadzone KM56",
    "Loadzone Mozdok",
    "Loadzone Nalchik",
    "Loadzone Krymsk",
    "Loadzone Senaki",
    "Loadzone Tbilisi-Lockini",
}

-- ==================
-- CTLD SETUP
-- ==================

local function configureCTLD(coalitionSide, cargoPrefix)
    local ctldInstance = CTLD:New(coalitionSide, { cargoPrefix })

    for _, unit in ipairs(UNIT_CONFIG) do
        local groupName = (coalitionSide == coalition.side.RED) and unit.redGroup or unit.blueGroup

        -- Check if the group exists before adding cargo
        local groupExists = Group.getByName(groupName) ~= nil

        if groupExists then
            if unit.type == CTLD_CARGO.Enum.TROOPS then
                ctldInstance:AddTroopsCargo(unit.ctldName, { groupName }, unit.type, unit.size, unit.mass, 0,
                    unit.subcategory)
            else
                ctldInstance:AddCratesCargo(unit.ctldName, { groupName }, unit.type, unit.size, unit.mass, 0,
                    unit.subcategory)
            end
        else
            -- Log warning if group doesn't exist (especially important for trucks)
            if string.find(unit.id, "Truck") or string.find(unit.id, "939") or string.find(unit.id, "66") then
                env.info("CTLD: Warning - Truck group '" ..
                    groupName .. "' not found. Create this group in Mission Editor to use " .. unit.menuName)
            end
        end
    end

    ctldInstance.EngineerSearch = 2000
    ctldInstance.useprefix = false
    ctldInstance.CrateDistance = 2000
    ctldInstance.PackDistance = 2000
    ctldInstance.dropcratesanywhere = true
    ctldInstance.dropAsCargoCrate = false
    ctldInstance.forcehoverload = false
    ctldInstance.placeCratesAhead = false
    ctldInstance.repairtime = 120
    ctldInstance.buildtime = 30
    ctldInstance.basetype = "container_cargo"
    ctldInstance.enableslingload = false
    ctldInstance.enableFixedWing = true
    ctldInstance.pilotmustopendoors = false
    ctldInstance.enableChinookGCLoading = false
    ctldInstance.movecratesbeforebuild = false
    ctldInstance.nobuildinloadzones = true
    ctldInstance.ChinookTroopCircleRadius = 5
    ctldInstance.onestepmenu = true
    ctldInstance.enableLoadSave = (lfs ~= nil)
    if lfs then
        ctldInstance.saveinterval = 1800
        ctldInstance.filename = (coalitionSide == coalition.side.RED) and "missionsave_red_noviews.csv" or "missionsave_blue_noviews.csv"
        ctldInstance.filepath = lfs.writedir() .. "Missions\\LODP_DML_1_0_CTLD_Saves\\"
    end

    -- ==================
    -- CA TRUCK SUPPORT
    -- ==================

    -- Each CTLD instance manages only its own coalition's trucks.
    -- Calling AllowCATransport twice overwrites the first set, causing both instances
    -- to manage the same (blue) trucks and fight over F10 menu ownership.
    if coalitionSide == coalition.side.RED then
        local redTruckers = SET_CLIENT:New():HandleCASlots():FilterCoalitions("red"):FilterPrefixes("Truck_Red"):FilterStart()
        ctldInstance:AllowCATransport(true, redTruckers)
    else
        local blueTruckers = SET_CLIENT:New():HandleCASlots():FilterCoalitions("blue"):FilterPrefixes("Truck_Blue"):FilterStart()
        ctldInstance:AllowCATransport(true, blueTruckers)
    end

    -- Add all load zones
    for _, zoneName in ipairs(LOAD_ZONES) do
        ctldInstance:AddCTLDZone(zoneName, CTLD.CargoZoneType.LOAD, SMOKECOLOR.Blue, true, true)
    end

    for _, chop in ipairs(CHOPPER_CONFIG) do
        ctldInstance:SetUnitCapabilities(chop.type, chop.crates, chop.troops, chop.maxCrates, chop.maxTroops, chop
            .length,
            chop.mass)
    end

    -- Set truck capabilities BEFORE starting
    for _, truck in ipairs(TRUCK_CONFIG) do
        ctldInstance:SetUnitCapabilities(truck.type, truck.crates, truck.troops, truck.maxCrates, truck.maxTroops,
            truck.length,
            truck.mass)
    end

    -- enableFixedWing=true causes startup to filter PilotGroups by self.prefixes (which are
    -- cargo static prefixes, not pilot names). Override with a proper set that covers both
    -- helicopters and the C-130 (only types in FixedWingTypes get menus regardless).
    local _coalitionTxt = (coalitionSide == coalition.side.RED) and "red" or "blue"
    ctldInstance:SetOwnSetPilotGroups(
        SET_GROUP:New():FilterCoalitions(_coalitionTxt):FilterCategories({"helicopter", "plane"}):FilterStart()
    )

    ctldInstance:__Start(5)


    return ctldInstance
end

local my_ctld = configureCTLD(coalition.side.RED, "R_Cargo")
local my_ctld2 = configureCTLD(coalition.side.BLUE, "B_Cargo")
my_ctld:__Load(10)
my_ctld2:__Load(10)

-- ==================
-- MENUS AND BALANCE
-- ==================

local function refreshCTLDMenus(ctld)
    for unitname, _ in pairs(ctld.MenusDone) do
        ctld.MenusDone[unitname] = nil
    end
end

local function displayBankBalance(coalitionSide, sideName)
    local success, balance = bank.getBalance(sideName)
    if success then
        local capSideName = sideName:sub(1, 1):upper() .. sideName:sub(2)
        MESSAGE:New(capSideName .. " coalition budget: §" .. balance, 10):ToCoalition(coalitionSide)
    else
        local capSideName = sideName:sub(1, 1):upper() .. sideName:sub(2)
        MESSAGE:New("Error retrieving " .. capSideName .. " budget.", 10):ToCoalition(coalitionSide)
    end
end

local function buyUnit(coalitionSide, sideName, ctldInstance, unitConfig)
    local success, balance = bank.getBalance(sideName)
    if success and balance >= unitConfig.cost then
        if unitConfig.type == CTLD_CARGO.Enum.TROOPS then
            ctldInstance:AddStockTroops(unitConfig.ctldName, 1)
        else
            ctldInstance:AddStockCrates(unitConfig.ctldName, 1)
        end
        refreshCTLDMenus(ctldInstance)

        local accountId = (coalitionSide == coalition.side.RED) and 1 or 2
        bank.withdawFunds(accountId, unitConfig.cost)
        MESSAGE:New("Purchase complete. " .. unitConfig.menuName .. " added.", 10):ToCoalition(coalitionSide)
    else
        MESSAGE:New("Insufficient funds. Credits needed: " .. unitConfig.cost .. ".", 10):ToCoalition(coalitionSide)
    end
end

local function buildMenus(coalitionSide, sideName, ctldInstance)
    local mainMenu = MENU_COALITION:New(coalitionSide, "Support and Upgrades")

    local bankMenu = MENU_COALITION:New(coalitionSide, "Check Budget", mainMenu)
    MENU_COALITION_COMMAND:New(coalitionSide, "Show Available Budget", bankMenu, displayBankBalance, coalitionSide,
        sideName)

    local suppliesMenu = MENU_COALITION:New(coalitionSide, "Buy CTLD Crates", mainMenu)

    -- Group units by subcategory
    local categorized = {}
    for _, unit in ipairs(UNIT_CONFIG) do
        local category = unit.subcategory or "Other"
        if not categorized[category] then
            categorized[category] = {}
        end
        table.insert(categorized[category], unit)
    end

    -- Create submenu for each category
    for category, units in pairs(categorized) do
        local categoryMenu = MENU_COALITION:New(coalitionSide, category, suppliesMenu)

        for _, unit in ipairs(units) do
            local buyMenu = MENU_COALITION:New(coalitionSide, "Buy " .. unit.menuName .. " (" .. unit.cost .. ")",
                categoryMenu)
            MENU_COALITION_COMMAND:New(coalitionSide, "Complete Purchase", buyMenu, buyUnit, coalitionSide, sideName,
                ctldInstance, unit)
        end
    end
end

buildMenus(coalition.side.RED, "red", my_ctld)
buildMenus(coalition.side.BLUE, "blue", my_ctld2)

-- ==================
-- CA TRUCK CARGO FIX
-- ==================
-- Problem: CTLD:_EventHandler clears Loaded_Cargo[unitName] both when a player
-- LEAVES a CA ground slot (PlayerLeaveUnit) and when they ENTER one (PlayerEnterUnit).
-- This loses all truck cargo whenever a CA player uses F-keys to observe other units.
--
-- Why the previous world.addEventHandler approach failed: Moose registers its own
-- world.addEventHandler at startup (before our script runs), so all Moose module
-- callbacks (including CTLD's clear) fire BEFORE ours. Loaded_Cargo is already nil
-- by the time our handler reads it.
--
-- Fix: Monkey-patch CTLD._EventHandler at the class level. Since Moose calls the
-- method by name via its dispatch table (resolved at HandleEvent time, ~5s after
-- __Start), our patched version is stored as the callback. We run BEFORE the original
-- clear, capture cargo on leave, and restore it 0.1s after enter.

local _caTruckCargoBackup = {}  -- unitName → { [ctld_instance] = UTILS.DeepCopy(Loaded_Cargo) }

local _orig_CTLD_EventHandler = CTLD._EventHandler
function CTLD:_EventHandler(EventData)
    if self.allowCATransport then
        local id       = EventData.id
        local unitname = EventData.IniUnitName or "none"
        local unit     = EventData.IniUnit

        local function isGroundUnit()
            if not unit then return false end
            local ok, result = pcall(function() return unit:IsGround() end)
            return ok and result
        end

        if id == EVENTS.PlayerLeaveUnit then
            if isGroundUnit() then
                local loaded = self.Loaded_Cargo and self.Loaded_Cargo[unitname]
                if loaded and ((loaded.Cratesloaded or 0) > 0 or (loaded.Troopsloaded or 0) > 0) then
                    -- Save cargo before CTLD wipes it
                    _caTruckCargoBackup[unitname] = _caTruckCargoBackup[unitname] or {}
                    _caTruckCargoBackup[unitname][self] = UTILS.DeepCopy(loaded)
                else
                    -- Left with no cargo: clear stale backup so it isn't restored
                    if _caTruckCargoBackup[unitname] then
                        _caTruckCargoBackup[unitname][self] = nil
                    end
                end
            end

        elseif id == EVENTS.UnitLost then
            -- Truck was destroyed: discard backup (cargo is gone)
            if isGroundUnit() and _caTruckCargoBackup[unitname] then
                _caTruckCargoBackup[unitname][self] = nil
            end

        elseif id == EVENTS.PlayerEnterAircraft or id == EVENTS.PlayerEnterUnit then
            if isGroundUnit() then
                local saved = _caTruckCargoBackup[unitname] and _caTruckCargoBackup[unitname][self]
                if saved then
                    local ctldRef = self
                    -- Schedule restore 0.1s after enter so it runs after CTLD's synchronous clear
                    timer.scheduleFunction(function()
                        if ctldRef.Loaded_Cargo then
                            ctldRef.Loaded_Cargo[unitname] = saved
                        end
                    end, {}, timer.getTime() + 0.1)
                end
            end
        end
    end

    return _orig_CTLD_EventHandler(self, EventData)
end
