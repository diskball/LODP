_SETTINGS:SetPlayerMenuOff()
_SETTINGS:SetEraModern()

local my_ctld = CTLD:New(coalition.side.RED,{"R_Cargo"})

my_ctld:AddTroopsCargo("Anti-Air",{"AAR"},CTLD_CARGO.Enum.TROOPS,2,90,0)
my_ctld:AddTroopsCargo("Infantry",{"RIFLER"},CTLD_CARGO.Enum.TROOPS,6,90,0)
my_ctld:AddCratesCargo("M-113",{"RED SCOUT"},CTLD_CARGO.Enum.VEHICLE,1,1000,0)
my_ctld:AddCratesCargo("Leopard",{"RED TANK"},CTLD_CARGO.Enum.VEHICLE,1,1000,0)
my_ctld:AddCratesCargo("SA-8",{"RED SA8"},CTLD_CARGO.Enum.VEHICLE,1,1000,0)
my_ctld:AddCratesCargo("SA-15",{"RED SA15"},CTLD_CARGO.Enum.VEHICLE,1,1000,0)
my_ctld:AddCratesCargo("EWR",{"RED EWR"},CTLD_CARGO.Enum.VEHICLE,1,1000,0)
my_ctld:AddCratesCargo("SA-10",{"RED SA10"},CTLD_CARGO.Enum.VEHICLE,1,1000,0)
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

my_ctld2:AddTroopsCargo("Anti-Air",{"AAB"},CTLD_CARGO.Enum.TROOPS,2,90,0)
my_ctld2:AddTroopsCargo("Infantry",{"RIFLEB"},CTLD_CARGO.Enum.TROOPS,6,90,0)
my_ctld2:AddCratesCargo("M-113",{"BLUE SCOUT"},CTLD_CARGO.Enum.VEHICLE,1,1000,0)
my_ctld2:AddCratesCargo("Leopard",{"BLUE TANK"},CTLD_CARGO.Enum.VEHICLE,1,1000,0)
my_ctld2:AddCratesCargo("SA-8",{"BLUE SA8"},CTLD_CARGO.Enum.VEHICLE,1,1000,0)
my_ctld2:AddCratesCargo("SA-15",{"BLUE SA15"},CTLD_CARGO.Enum.VEHICLE,1,1000,0)
my_ctld2:AddCratesCargo("EWR",{"BLUE EWR"},CTLD_CARGO.Enum.VEHICLE,1,1000,0)
my_ctld2:AddCratesCargo("SA-10",{"BLUE SA10"},CTLD_CARGO.Enum.VEHICLE,1,1000,0)
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
-- COST CONFIG
-- ==================

local COSTS = {
    MANPADS  = 100,
    Infantry = 50,
    Scout    = 150,
    Leopard  = 250,
    SA8      = 300,
    SA15     = 350,
    EWR      = 250,
    SA10     = 1250,
}

-- ==================
-- HELPER FUNCTION
-- ==================

local function refreshCTLDMenus(ctld)
    for unitname, _ in pairs(ctld.MenusDone) do
        ctld.MenusDone[unitname] = nil
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
-- BLUE BUY FUNCTIONS (my_ctld2)
-- ==================

function buyMANPADSBlue()
    local success, balance = bank.getBalance("blue")
    if success and balance >= COSTS.MANPADS then
        my_ctld2:AddStockTroops("Anti-Air", 1)
        refreshCTLDMenus(my_ctld2)
        bank.withdawFunds(2, COSTS.MANPADS)
        MESSAGE:New("Purchase complete. MANPADS added.", 10):ToCoalition(coalition.side.BLUE)
    else
        MESSAGE:New("Insufficient funds. Credits needed: " .. COSTS.MANPADS .. ".", 10):ToCoalition(coalition.side.BLUE)
    end
end

function buyInfantryBlue()
    local success, balance = bank.getBalance("blue")
    if success and balance >= COSTS.Infantry then
        my_ctld2:AddStockTroops("Infantry", 1)
        refreshCTLDMenus(my_ctld2)
        bank.withdawFunds(2, COSTS.Infantry)
        MESSAGE:New("Purchase complete. Infantry added.", 10):ToCoalition(coalition.side.BLUE)
    else
        MESSAGE:New("Insufficient funds. Credits needed: " .. COSTS.Infantry .. ".", 10):ToCoalition(coalition.side.BLUE)
    end
end

function buyScoutBlue()
    local success, balance = bank.getBalance("blue")
    if success and balance >= COSTS.Scout then
        my_ctld2:AddStockCrates("M-113", 1)
        refreshCTLDMenus(my_ctld2)
        bank.withdawFunds(2, COSTS.Scout)
        MESSAGE:New("Purchase complete. M-113 added.", 10):ToCoalition(coalition.side.BLUE)
    else
        MESSAGE:New("Insufficient funds. Credits needed: " .. COSTS.Scout .. ".", 10):ToCoalition(coalition.side.BLUE)
    end
end

function buyLeopardBlue()
    local success, balance = bank.getBalance("blue")
    if success and balance >= COSTS.Leopard then
        my_ctld2:AddStockCrates("Leopard", 1)
        refreshCTLDMenus(my_ctld2)
        bank.withdawFunds(2, COSTS.Leopard)
        MESSAGE:New("Purchase complete. Leopard added.", 10):ToCoalition(coalition.side.BLUE)
    else
        MESSAGE:New("Insufficient funds. Credits needed: " .. COSTS.Leopard .. ".", 10):ToCoalition(coalition.side.BLUE)
    end
end

function buySA8Blue()
    local success, balance = bank.getBalance("blue")
    if success and balance >= COSTS.SA8 then
        my_ctld2:AddStockCrates("SA-8", 1)
        refreshCTLDMenus(my_ctld2)
        bank.withdawFunds(2, COSTS.SA8)
        MESSAGE:New("Purchase complete. SA-8 added.", 10):ToCoalition(coalition.side.BLUE)
    else
        MESSAGE:New("Insufficient funds. Credits needed: " .. COSTS.SA8 .. ".", 10):ToCoalition(coalition.side.BLUE)
    end
end

function buySA15Blue()
    local success, balance = bank.getBalance("blue")
    if success and balance >= COSTS.SA15 then
        my_ctld2:AddStockCrates("SA-15", 1)
        refreshCTLDMenus(my_ctld2)
        bank.withdawFunds(2, COSTS.SA15)
        MESSAGE:New("Purchase complete. SA-15 added.", 10):ToCoalition(coalition.side.BLUE)
    else
        MESSAGE:New("Insufficient funds. Credits needed: " .. COSTS.SA15 .. ".", 10):ToCoalition(coalition.side.BLUE)
    end
end

function buyEWRBlue()
    local success, balance = bank.getBalance("blue")
    if success and balance >= COSTS.EWR then
        my_ctld2:AddStockCrates("EWR", 1)
        refreshCTLDMenus(my_ctld2)
        bank.withdawFunds(2, COSTS.EWR)
        MESSAGE:New("Purchase complete. EWR added.", 10):ToCoalition(coalition.side.BLUE)
    else
        MESSAGE:New("Insufficient funds. Credits needed: " .. COSTS.EWR .. ".", 10):ToCoalition(coalition.side.BLUE)
    end
end

function buySA10Blue()
    local success, balance = bank.getBalance("blue")
    if success and balance >= COSTS.SA10 then
        my_ctld2:AddStockCrates("SA-10", 1)
        refreshCTLDMenus(my_ctld2)
        bank.withdawFunds(2, COSTS.SA10)
        MESSAGE:New("Purchase complete. SA-10 added.", 10):ToCoalition(coalition.side.BLUE)
    else
        MESSAGE:New("Insufficient funds. Credits needed: " .. COSTS.SA10 .. ".", 10):ToCoalition(coalition.side.BLUE)
    end
end

-- ==================
-- RED BUY FUNCTIONS (my_ctld)
-- ==================

function buyMANPADSRed()
    local success, balance = bank.getBalance("red")
    if success and balance >= COSTS.MANPADS then
        my_ctld:AddStockTroops("Anti-Air", 1)
        refreshCTLDMenus(my_ctld)
        bank.withdawFunds(1, COSTS.MANPADS)
        MESSAGE:New("Purchase complete. MANPADS added.", 10):ToCoalition(coalition.side.RED)
    else
        MESSAGE:New("Insufficient funds. Credits needed: " .. COSTS.MANPADS .. ".", 10):ToCoalition(coalition.side.RED)
    end
end

function buyInfantryRed()
    local success, balance = bank.getBalance("red")
    if success and balance >= COSTS.Infantry then
        my_ctld:AddStockTroops("Infantry", 1)
        refreshCTLDMenus(my_ctld)
        bank.withdawFunds(1, COSTS.Infantry)
        MESSAGE:New("Purchase complete. Infantry added.", 10):ToCoalition(coalition.side.RED)
    else
        MESSAGE:New("Insufficient funds. Credits needed: " .. COSTS.Infantry .. ".", 10):ToCoalition(coalition.side.RED)
    end
end

function buyScoutRed()
    local success, balance = bank.getBalance("red")
    if success and balance >= COSTS.Scout then
        my_ctld:AddStockCrates("M-113", 1)
        refreshCTLDMenus(my_ctld)
        bank.withdawFunds(1, COSTS.Scout)
        MESSAGE:New("Purchase complete. M-113 added.", 10):ToCoalition(coalition.side.RED)
    else
        MESSAGE:New("Insufficient funds. Credits needed: " .. COSTS.Scout .. ".", 10):ToCoalition(coalition.side.RED)
    end
end

function buyLeopardRed()
    local success, balance = bank.getBalance("red")
    if success and balance >= COSTS.Leopard then
        my_ctld:AddStockCrates("Leopard", 1)
        refreshCTLDMenus(my_ctld)
        bank.withdawFunds(1, COSTS.Leopard)
        MESSAGE:New("Purchase complete. Leopard added.", 10):ToCoalition(coalition.side.RED)
    else
        MESSAGE:New("Insufficient funds. Credits needed: " .. COSTS.Leopard .. ".", 10):ToCoalition(coalition.side.RED)
    end
end

function buySA8Red()
    local success, balance = bank.getBalance("red")
    if success and balance >= COSTS.SA8 then
        my_ctld:AddStockCrates("SA-8", 1)
        refreshCTLDMenus(my_ctld)
        bank.withdawFunds(1, COSTS.SA8)
        MESSAGE:New("Purchase complete. SA-8 added.", 10):ToCoalition(coalition.side.RED)
    else
        MESSAGE:New("Insufficient funds. Credits needed: " .. COSTS.SA8 .. ".", 10):ToCoalition(coalition.side.RED)
    end
end

function buySA15Red()
    local success, balance = bank.getBalance("red")
    if success and balance >= COSTS.SA15 then
        my_ctld:AddStockCrates("SA-15", 1)
        refreshCTLDMenus(my_ctld)
        bank.withdawFunds(1, COSTS.SA15)
        MESSAGE:New("Purchase complete. SA-15 added.", 10):ToCoalition(coalition.side.RED)
    else
        MESSAGE:New("Insufficient funds. Credits needed: " .. COSTS.SA15 .. ".", 10):ToCoalition(coalition.side.RED)
    end
end

function buyEWRRed()
    local success, balance = bank.getBalance("red")
    if success and balance >= COSTS.EWR then
        my_ctld:AddStockCrates("EWR", 1)
        refreshCTLDMenus(my_ctld)
        bank.withdawFunds(1, COSTS.EWR)
        MESSAGE:New("Purchase complete. EWR added.", 10):ToCoalition(coalition.side.RED)
    else
        MESSAGE:New("Insufficient funds. Credits needed: " .. COSTS.EWR .. ".", 10):ToCoalition(coalition.side.RED)
    end
end

function buySA10Red()
    local success, balance = bank.getBalance("red")
    if success and balance >= COSTS.SA10 then
        my_ctld:AddStockCrates("SA-10", 1)
        refreshCTLDMenus(my_ctld)
        bank.withdawFunds(1, COSTS.SA10)
        MESSAGE:New("Purchase complete. SA-10 added.", 10):ToCoalition(coalition.side.RED)
    else
        MESSAGE:New("Insufficient funds. Credits needed: " .. COSTS.SA10 .. ".", 10):ToCoalition(coalition.side.RED)
    end
end

-- ==================
-- BLUE MENU
-- ==================

local mainMenuBlue = MENU_COALITION:New(coalition.side.BLUE, "Support and Upgrades")

local bankMenuBlue = MENU_COALITION:New(coalition.side.BLUE, "Check Budget", mainMenuBlue)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Show Available Budget", bankMenuBlue, displayBankBalanceBlue)

local suppliesMenuBlue = MENU_COALITION:New(coalition.side.BLUE, "Buy CTLD Crates", mainMenuBlue)

local manpadsMenuBlue = MENU_COALITION:New(coalition.side.BLUE, "Buy MANPADS ("..COSTS.MANPADS..")", suppliesMenuBlue)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Complete Purchase", manpadsMenuBlue, buyMANPADSBlue)

local infantryMenuBlue = MENU_COALITION:New(coalition.side.BLUE, "Buy Infantry ("..COSTS.Infantry..")", suppliesMenuBlue)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Complete Purchase", infantryMenuBlue, buyInfantryBlue)

local scoutMenuBlue = MENU_COALITION:New(coalition.side.BLUE, "Buy M-113 ("..COSTS.Scout..")", suppliesMenuBlue)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Complete Purchase", scoutMenuBlue, buyScoutBlue)

local leopardMenuBlue = MENU_COALITION:New(coalition.side.BLUE, "Buy Leopard ("..COSTS.Leopard..")", suppliesMenuBlue)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Complete Purchase", leopardMenuBlue, buyLeopardBlue)

local sa8MenuBlue = MENU_COALITION:New(coalition.side.BLUE, "Buy SA-8 ("..COSTS.SA8..")", suppliesMenuBlue)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Complete Purchase", sa8MenuBlue, buySA8Blue)

local sa15MenuBlue = MENU_COALITION:New(coalition.side.BLUE, "Buy SA-15 ("..COSTS.SA15..")", suppliesMenuBlue)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Complete Purchase", sa15MenuBlue, buySA15Blue)

local ewrMenuBlue = MENU_COALITION:New(coalition.side.BLUE, "Buy EWR ("..COSTS.EWR..")", suppliesMenuBlue)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Complete Purchase", ewrMenuBlue, buyEWRBlue)

local sa10MenuBlue = MENU_COALITION:New(coalition.side.BLUE, "Buy SA-10 ("..COSTS.SA10..")", suppliesMenuBlue)
MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Complete Purchase", sa10MenuBlue, buySA10Blue)

-- ==================
-- RED MENU
-- ==================

local mainMenuRed = MENU_COALITION:New(coalition.side.RED, "Support and Upgrades")

local bankMenuRed = MENU_COALITION:New(coalition.side.RED, "Check Budget", mainMenuRed)
MENU_COALITION_COMMAND:New(coalition.side.RED, "Show Available Budget", bankMenuRed, displayBankBalanceRed)

local suppliesMenuRed = MENU_COALITION:New(coalition.side.RED, "Buy CTLD Crates", mainMenuRed)

local manpadsMenuRed = MENU_COALITION:New(coalition.side.RED, "Buy MANPADS ("..COSTS.MANPADS..")", suppliesMenuRed)
MENU_COALITION_COMMAND:New(coalition.side.RED, "Complete Purchase", manpadsMenuRed, buyMANPADSRed)

local infantryMenuRed = MENU_COALITION:New(coalition.side.RED, "Buy Infantry ("..COSTS.Infantry..")", suppliesMenuRed)
MENU_COALITION_COMMAND:New(coalition.side.RED, "Complete Purchase", infantryMenuRed, buyInfantryRed)

local scoutMenuRed = MENU_COALITION:New(coalition.side.RED, "Buy M-113 ("..COSTS.Scout..")", suppliesMenuRed)
MENU_COALITION_COMMAND:New(coalition.side.RED, "Complete Purchase", scoutMenuRed, buyScoutRed)

local leopardMenuRed = MENU_COALITION:New(coalition.side.RED, "Buy Leopard ("..COSTS.Leopard..")", suppliesMenuRed)
MENU_COALITION_COMMAND:New(coalition.side.RED, "Complete Purchase", leopardMenuRed, buyLeopardRed)

local sa8MenuRed = MENU_COALITION:New(coalition.side.RED, "Buy SA-8 ("..COSTS.SA8..")", suppliesMenuRed)
MENU_COALITION_COMMAND:New(coalition.side.RED, "Complete Purchase", sa8MenuRed, buySA8Red)

local sa15MenuRed = MENU_COALITION:New(coalition.side.RED, "Buy SA-15 ("..COSTS.SA15..")", suppliesMenuRed)
MENU_COALITION_COMMAND:New(coalition.side.RED, "Complete Purchase", sa15MenuRed, buySA15Red)

local ewrMenuRed = MENU_COALITION:New(coalition.side.RED, "Buy EWR ("..COSTS.EWR..")", suppliesMenuRed)
MENU_COALITION_COMMAND:New(coalition.side.RED, "Complete Purchase", ewrMenuRed, buyEWRRed)

local sa10MenuRed = MENU_COALITION:New(coalition.side.RED, "Buy SA-10 ("..COSTS.SA10..")", suppliesMenuRed)
MENU_COALITION_COMMAND:New(coalition.side.RED, "Complete Purchase", sa10MenuRed, buySA10Red)