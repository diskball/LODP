_SETTINGS:SetPlayerMenuOff()
_SETTINGS:SetEraModern()

local my_ctld = CTLD:New(coalition.side.RED,{"R_Cargo"})

-- Configure RED coalition cargo from centralized CARGO_TYPES
for _, cargo in ipairs(CARGO_TYPES) do
    if cargo.type == "troops" then
        my_ctld:AddTroopsCargo(cargo.red.name, {cargo.red.groupName}, CTLD_CARGO.Enum.TROOPS, cargo.count, 90, 0)
    else
        my_ctld:AddCratesCargo(cargo.red.name, {cargo.red.groupName}, CTLD_CARGO.Enum.VEHICLE, cargo.count, 1000, 0)
    end
end

my_ctld.EngineerSearch = 2000 -- teams will search for crates in this radius.
my_ctld.useprefix = true -- (DO NOT SWITCH THIS OFF UNLESS YOU KNOW WHAT YOU ARE DOING!) Adjust **before** starting CTLD. If set to false, *all* choppers of the coalition side will be enabled for CTLD.
my_ctld.CrateDistance = 100 -- List and Load crates in this radius only.
my_ctld.PackDistance = 100 -- Pack crates in this radius only
my_ctld.dropcratesanywhere = true -- Option to allow crates to be dropped anywhere.
my_ctld.dropAsCargoCrate = false
my_ctld.forcehoverload = false
my_ctld.placeCratesAhead = false
my_ctld.repairtime = 120 -- Number of seconds it takes to repair a unit.
my_ctld.buildtime = 180 -- Number of seconds it takes to build a unit. Set to zero or nil to build instantly.
my_ctld.basetype = "container_cargo"
my_ctld.enableslingload = false -- will set cargo items as sling-loadable
my_ctld.pilotmustopendoors = true 
my_ctld.enableChinookGCLoading = false
my_ctld.movecratesbeforebuild = false
my_ctld.nobuildinloadzones = true
my_ctld.ChinookTroopCircleRadius = 5
my_ctld.onestepmenu = true
my_ctld.enableLoadSave = true -- allow auto-saving and loading of files
my_ctld.saveinterval = 600 -- save every 10 minutes
my_ctld.filename = "missionsave.csv" -- example filename
my_ctld.filepath = "C:\\Users\\myname\\Saved Games\\DCS\Missions\\MyMission" -- example path


my_ctld:AddCTLDZone("Loadzone RED",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)
--my_ctld:AddCTLDZone("Loadzone RED 2",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)
--my_ctld:AddCTLDZone("Loadzone RED 3",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)
--my_ctld:AddCTLDZone("Loadzone RED 4",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)
--my_ctld:AddCTLDZone("Loadzone RED 5",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)
--my_ctld:AddCTLDZone("Loadzone RED 6",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)


my_ctld:SetUnitCapabilities("Mi-24P", true, true, 1, 6, 20, 3000)
my_ctld:SetUnitCapabilities("UH-1H", true, true, 1, 6, 15, 1600)
my_ctld:SetUnitCapabilities("Mi-8MTV2", true, true, 1, 12, 15, 3000)
my_ctld:SetUnitCapabilities("CH-47Fbl1", true, true, 2, 31, 20, 8000)
my_ctld:SetUnitCapabilities("AH-64D_BLK_II", false, false, 0, 0, 17, 200)
my_ctld:SetUnitCapabilities("OH58D", false, false, 0, 0, 14, 400)

my_ctld:__Start(5)

local my_ctld2 = CTLD:New(coalition.side.BLUE,{"B_Cargo"})

-- Configure BLUE coalition cargo from centralized CARGO_TYPES
for _, cargo in ipairs(CARGO_TYPES) do
    if cargo.type == "troops" then
        my_ctld2:AddTroopsCargo(cargo.blue.name, {cargo.blue.groupName}, CTLD_CARGO.Enum.TROOPS, cargo.count, 90, 0)
    else
        my_ctld2:AddCratesCargo(cargo.blue.name, {cargo.blue.groupName}, CTLD_CARGO.Enum.VEHICLE, cargo.count, 1000, 0)
    end
end

my_ctld2.EngineerSearch = 2000 -- teams will search for crates in this radius.
my_ctld2.useprefix = true -- (DO NOT SWITCH THIS OFF UNLESS YOU KNOW WHAT YOU ARE DOING!) Adjust **before** starting CTLD. If set to false, *all* choppers of the coalition side will be enabled for CTLD.
my_ctld2.CrateDistance = 100 -- List and Load crates in this radius only.
my_ctld2.PackDistance = 100 -- Pack crates in this radius only
my_ctld2.dropcratesanywhere = true -- Option to allow crates to be dropped anywhere.
my_ctld2.dropAsCargoCrate = false
my_ctld2.forcehoverload = false
my_ctld2.placeCratesAhead = false
my_ctld2.repairtime = 120 -- Number of seconds it takes to repair a unit.
my_ctld2.buildtime = 180 -- Number of seconds it takes to build a unit. Set to zero or nil to build instantly.
my_ctld2.basetype = "container_cargo"
my_ctld2.enableslingload = false -- will set cargo items as sling-loadable
my_ctld2.pilotmustopendoors = true 
my_ctld2.enableChinookGCLoading = false
my_ctld2.movecratesbeforebuild = false
my_ctld2.nobuildinloadzones = true
my_ctld2.ChinookTroopCircleRadius = 5
my_ctld2.onestepmenu = true
my_ctld2.enableLoadSave = true -- allow auto-saving and loading of files
my_ctld2.saveinterval = 600 -- save every 10 minutes
my_ctld2.filename = "missionsave.csv" -- example filename
my_ctld2.filepath = "C:\\Users\\myname\\Saved Games\\DCS\Missions\\MyMission" -- example path

my_ctld2:AddCTLDZone("Loadzone BLUE",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)
--my_ctld2:AddCTLDZone("Loadzone BLUE 2",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)
--my_ctld2:AddCTLDZone("Loadzone BLUE 3",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)
--my_ctld2:AddCTLDZone("Loadzone BLUE 4",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)
--my_ctld2:AddCTLDZone("Loadzone BLUE 5",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)
--my_ctld2:AddCTLDZone("Loadzone BLUE 6",CTLD.CargoZoneType.LOAD,SMOKECOLOR.Blue,true,true)

my_ctld2:SetUnitCapabilities("Mi-24P", true, true, 1, 6, 20, 3000)
my_ctld2:SetUnitCapabilities("UH-1H", true, true, 1, 6, 15, 1600)
my_ctld2:SetUnitCapabilities("Mi-8MTV2", true, true, 1, 12, 15, 3000)
my_ctld2:SetUnitCapabilities("CH-47Fbl1", true, true, 2, 31, 20, 8000)
my_ctld2:SetUnitCapabilities("AH-64D_BLK_II", false, false, 0, 0, 17, 200)
my_ctld2:SetUnitCapabilities("OH58D", false, false, 0, 0, 14, 400)

my_ctld2:__Start(5)

-- ==================
-- CARGO & COST CONFIGURATION
-- ==================

-- Central cargo definition for both coalitions
-- Manage all cargo types, names, and group assignments in one place
local CARGO_TYPES = {
    -- Troops
    {
        key = "MANPADS",
        displayName = "MANPADS",
        type = "troops",
        count = 2,
        cost = 100,
        red = { name = "Anti-Air", groupName = "AAR" },
        blue = { name = "Anti-Air", groupName = "AAB" }
    },
    {
        key = "Infantry",
        displayName = "Infantry",
        type = "troops",
        count = 6,
        cost = 50,
        red = { name = "Infantry", groupName = "RIFLER" },
        blue = { name = "Infantry", groupName = "RIFLEB" }
    },
    -- Vehicles
    {
        key = "Scout",
        displayName = "M-113",
        type = "crate",
        count = 1,
        cost = 150,
        red = { name = "M-113", groupName = "RED SCOUT" },
        blue = { name = "M-113", groupName = "BLUE SCOUT" }
    },
    {
        key = "Leopard",
        displayName = "Leopard",
        type = "crate",
        count = 1,
        cost = 250,
        red = { name = "Leopard", groupName = "RED TANK" },
        blue = { name = "Leopard", groupName = "BLUE TANK" }
    },
    {
        key = "SA8",
        displayName = "SA-8",
        type = "crate",
        count = 1,
        cost = 300,
        red = { name = "SA-8", groupName = "RED SA8" },
        blue = { name = "SA-8", groupName = "BLUE SA8" }
    },
    {
        key = "SA15",
        displayName = "SA-15",
        type = "crate",
        count = 1,
        cost = 350,
        red = { name = "SA-15", groupName = "RED SA15" },
        blue = { name = "SA-15", groupName = "BLUE SA15" }
    },
    {
        key = "EWR",
        displayName = "EWR",
        type = "crate",
        count = 1,
        cost = 250,
        red = { name = "EWR", groupName = "RED EWR" },
        blue = { name = "EWR", groupName = "BLUE EWR" }
    },
}

-- Legacy COSTS table for backwards compatibility (auto-generated from CARGO_TYPES)
local COSTS = {}
for _, cargo in ipairs(CARGO_TYPES) do
    COSTS[cargo.key] = cargo.cost
end

-- ==================
-- GENERIC BUY FUNCTION (auto-works for both coalitions)
-- ==================

local function buyItem(ctldInstance, coalitionName, cargoKey)
    local success, balance = bank.getBalance(coalitionName)
    
    -- Find cargo definition
    local cargoDefinition = nil
    for _, cargo in ipairs(CARGO_TYPES) do
        if cargo.key == cargoKey then
            cargoDefinition = cargo
            break
        end
    end
    
    if not cargoDefinition then
        return
    end
    
    if success and balance >= cargoDefinition.cost then
        local coalition = coalitionName == "red" and coalition.side.RED or coalition.side.BLUE
        local cargoConfig = cargoDefinition[coalitionName]
        
        if cargoDefinition.type == "troops" then
            ctldInstance:AddStockTroops(cargoConfig.name, 1)
        else
            ctldInstance:AddStockCrates(cargoConfig.name, 1)
        end
        
        refreshCTLDMenus(ctldInstance)
        
        local coalitionNum = coalitionName == "red" and 1 or 2
        bank.withdawFunds(coalitionNum, cargoDefinition.cost)
        
        MESSAGE:New("Purchase complete. " .. cargoDefinition.displayName .. " added.", 10):ToCoalition(coalition)
    else
        local coalition = coalitionName == "red" and coalition.side.RED or coalition.side.BLUE
        MESSAGE:New("Insufficient funds. Credits needed: " .. cargoDefinition.cost .. ".", 10):ToCoalition(coalition)
    end
end

-- ==================
-- BALANCE FUNCTIONS
-- ==================

function displayBankBalanceBlue()
    local success, balance = bank.getBalance("blue")
    if success then
        MESSAGE:New("Blue coalition budget: §" .. balance, 10):ToCoalition(coalition.side.BLUE)
    else
        MESSAGE:New("Error retrieving Blue budget.", 10):ToCoalition(coalition.side.BLUE)
    end
end

function displayBankBalanceRed()
    local success, balance = bank.getBalance("red")
    if success then
        MESSAGE:New("Red coalition budget: §" .. balance, 10):ToCoalition(coalition.side.RED)
    else
        MESSAGE:New("Error retrieving Red budget.", 10):ToCoalition(coalition.side.RED)
    end
end

-- ==================
-- AUTO-GENERATED MENUS (from CARGO_TYPES)
-- ==================

-- BLUE COALITION MENU
local mainMenuBlue = MENU_COALITION:New(coalition.side.BLUE, "Support and Upgrades")
local bankMenuBlue = MENU_COALITION:New(coalition.side.BLUE, "Check Budget", mainMenuBlue)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Show Available Budget", bankMenuBlue, displayBankBalanceBlue)

local suppliesMenuBlue = MENU_COALITION:New(coalition.side.BLUE, "Buy CTLD Crates", mainMenuBlue)

-- Generate cargo purchase menus for BLUE
for _, cargo in ipairs(CARGO_TYPES) do
    local menuText = "Buy " .. cargo.displayName .. " (" .. cargo.cost .. ")"
    local cargoMenu = MENU_COALITION:New(coalition.side.BLUE, menuText, suppliesMenuBlue)
    MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Complete Purchase", cargoMenu, 
        function() buyItem(my_ctld2, "blue", cargo.key) end)
end

-- RED COALITION MENU
local mainMenuRed = MENU_COALITION:New(coalition.side.RED, "Support and Upgrades")
local bankMenuRed = MENU_COALITION:New(coalition.side.RED, "Check Budget", mainMenuRed)
MENU_COALITION_COMMAND:New(coalition.side.RED, "Show Available Budget", bankMenuRed, displayBankBalanceRed)

local suppliesMenuRed = MENU_COALITION:New(coalition.side.RED, "Buy CTLD Crates", mainMenuRed)

-- Generate cargo purchase menus for RED
for _, cargo in ipairs(CARGO_TYPES) do
    local menuText = "Buy " .. cargo.displayName .. " (" .. cargo.cost .. ")"
    local cargoMenu = MENU_COALITION:New(coalition.side.RED, menuText, suppliesMenuRed)
    MENU_COALITION_COMMAND:New(coalition.side.RED, "Complete Purchase", cargoMenu, 
        function() buyItem(my_ctld, "red", cargo.key) end)
end

-- ==================
-- HELPER FUNCTION
-- ==================

local function refreshCTLDMenus(ctld)
    for unitname, _ in pairs(ctld.MenusDone) do
        ctld.MenusDone[unitname] = nil
    end
end