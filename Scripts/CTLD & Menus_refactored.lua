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
    { id = "Infantry",       menuName = "Infantry",       ctldName = "Infantry",       type = CTLD_CARGO.Enum.TROOPS,  redGroup = "RIFLER",             blueGroup = "RIFLEB",              size = 4, mass = 90,   subcategory = "Troops",         cost = 50 },
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
    { id = "Gaz66",          menuName = "Gaz-66 Truck",   ctldName = "Gaz-66 Truck",   type = CTLD_CARGO.Enum.VEHICLE, redGroup = "Truck_Red",          blueGroup = "Truck_Blue",          size = 1, mass = 1000, subcategory = "Transport",      cost = 100 },
    { id = "FARP_logistics", menuName = "FARP_logistics", ctldName = "FARP_logistics", type = CTLD_CARGO.Enum.VEHICLE, redGroup = "FARP_logistics_red", blueGroup = "FARP_logistics_blue", size = 1, mass = 1000, subcategory = "FARP Logistics", cost = 50 },
}

local CHOPPER_CONFIG = {
    { type = "Mi-24P",        troops = true,  crates = true,  maxCrates = 1, maxTroops = 6,  length = 20, mass = 3000 },
    { type = "UH-1H",         troops = true,  crates = true,  maxCrates = 1, maxTroops = 6,  length = 15, mass = 1600 },
    { type = "Mi-8MTV2",      troops = true,  crates = true,  maxCrates = 1, maxTroops = 12, length = 15, mass = 3000 },
    { type = "CH-47Fbl1",     troops = true,  crates = true,  maxCrates = 2, maxTroops = 31, length = 20, mass = 8000 },
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
    ctldInstance.pilotmustopendoors = false
    ctldInstance.enableChinookGCLoading = false
    ctldInstance.movecratesbeforebuild = false
    ctldInstance.nobuildinloadzones = true
    ctldInstance.ChinookTroopCircleRadius = 5
    ctldInstance.onestepmenu = true
    ctldInstance.enableLoadSave = true
    ctldInstance.saveinterval = 180
    ctldInstance.filename = (coalitionSide == coalition.side.RED) and "missionsave_red.csv" or "missionsave_blue.csv"
    ctldInstance.filepath = lfs.writedir() .. "Missions\\LODP_DML_1_0_CTLD_Saves\\"

    -- ==================
    -- CA TRUCK SUPPORT
    -- ==================

    -- Create SET_CLIENT for RED CA vehicles (player-driven trucks)
    -- In mission editor: Create client slots named "Truck_Red_*" with vehicle type "M 818" or "Gaz-66"
    local redTruckers = SET_CLIENT:New():HandleCASlots():FilterCoalitions("red"):FilterPrefixes("Truck_Red"):FilterStart()
    ctldInstance:AllowCATransport(true, redTruckers)

    -- Create SET_CLIENT for BLUE CA vehicles (player-driven trucks)
    -- In mission editor: Create client slots named "Truck_Blue_*" with vehicle type "M 818" or "Gaz-66"
    local blueTruckers = SET_CLIENT:New():HandleCASlots():FilterCoalitions("blue"):FilterPrefixes("Truck_Blue")
        :FilterStart()
    ctldInstance:AllowCATransport(true, blueTruckers)

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
