-- ==================
-- CONFIGURATION
-- ==================

_SETTINGS:SetPlayerMenuOff()
_SETTINGS:SetEraModern()

local UNIT_CONFIG = {
    { id = "MANPADS",   menuName = "MANPADS",   ctldName = "Anti-Air",  type = CTLD_CARGO.Enum.TROOPS,  redGroup = "AAR",           blueGroup = "AAB",            size = 1, time = 90,   mass = 0, cost = 100 },
    { id = "Infantry",  menuName = "Infantry",  ctldName = "Infantry",  type = CTLD_CARGO.Enum.TROOPS,  redGroup = "RIFLER",        blueGroup = "RIFLEB",         size = 4, time = 90,   mass = 0, cost = 50 },
    { id = "Scout",     menuName = "M-113",     ctldName = "M-113",     type = CTLD_CARGO.Enum.VEHICLE, redGroup = "RED SCOUT",     blueGroup = "BLUE SCOUT",     size = 1, time = 1000, mass = 0, cost = 100 },
    { id = "JTAC",      menuName = "JTAC",      ctldName = "JTAC",      type = CTLD_CARGO.Enum.VEHICLE, redGroup = "RED JTAC",      blueGroup = "BLUE JTAC",      size = 1, time = 1000, mass = 0, cost = 150 },
    { id = "T55",       menuName = "T-55",      ctldName = "T-55",      type = CTLD_CARGO.Enum.VEHICLE, redGroup = "RED T55",       blueGroup = "BLUE T55",       size = 1, time = 1000, mass = 0, cost = 150 },
    { id = "Shilka",    menuName = "Shilka",    ctldName = "Shilka",    type = CTLD_CARGO.Enum.VEHICLE, redGroup = "RED Shilka",    blueGroup = "BLUE Shilka",    size = 1, time = 1000, mass = 0, cost = 180 },
    { id = "Chaparral", menuName = "Chaparral", ctldName = "Chaparral", type = CTLD_CARGO.Enum.VEHICLE, redGroup = "RED Chaparral", blueGroup = "BLUE Chaparral", size = 1, time = 1000, mass = 0, cost = 200 },
    { id = "Leopard",   menuName = "Leopard",   ctldName = "Leopard",   type = CTLD_CARGO.Enum.VEHICLE, redGroup = "RED TANK",      blueGroup = "BLUE TANK",      size = 1, time = 1000, mass = 0, cost = 400 },
    { id = "SA13",      menuName = "SA-13",     ctldName = "SA-13",     type = CTLD_CARGO.Enum.VEHICLE, redGroup = "RED SA13",      blueGroup = "BLUE SA13",      size = 1, time = 1000, mass = 0, cost = 400 },
    { id = "SA8",       menuName = "SA-8",      ctldName = "SA-8",      type = CTLD_CARGO.Enum.VEHICLE, redGroup = "RED SA8",       blueGroup = "BLUE SA8",       size = 1, time = 1000, mass = 0, cost = 400 },
    { id = "SA15M1",    menuName = "SA-15M1",   ctldName = "SA-15M1",   type = CTLD_CARGO.Enum.VEHICLE, redGroup = "RED SA15M1",    blueGroup = "BLUE SA15M1",    size = 2, time = 1000, mass = 0, cost = 550 },
    { id = "SA15M2",    menuName = "SA-15M2",   ctldName = "SA-15M2",   type = CTLD_CARGO.Enum.VEHICLE, redGroup = "RED SA15M2",    blueGroup = "BLUE SA15M",     size = 2, time = 1000, mass = 0, cost = 800 },
    { id = "EWR",       menuName = "EWR",       ctldName = "EWR",       type = CTLD_CARGO.Enum.VEHICLE, redGroup = "RED EWR",       blueGroup = "BLUE EWR",       size = 1, time = 1000, mass = 0, cost = 250 },
    { id = "SA10",      menuName = "SA-10",     ctldName = "SA-10",     type = CTLD_CARGO.Enum.VEHICLE, redGroup = "RED SA10",      blueGroup = "BLUE SA10",      size = 2, time = 1000, mass = 0, cost = 1250 },
}

local CHOPPER_CONFIG = {
    { type = "Mi-24P",        sling = true,  crates = true,  maxCrates = 1, maxTroops = 6,  length = 20, mass = 3000 },
    { type = "UH-1H",         sling = true,  crates = true,  maxCrates = 1, maxTroops = 6,  length = 15, mass = 1600 },
    { type = "Mi-8MTV2",      sling = true,  crates = true,  maxCrates = 1, maxTroops = 12, length = 15, mass = 3000 },
    { type = "CH-47Fbl1",     sling = true,  crates = true,  maxCrates = 2, maxTroops = 31, length = 20, mass = 8000 },
    { type = "AH-64D_BLK_II", sling = false, crates = false, maxCrates = 0, maxTroops = 0,  length = 17, mass = 200 },
    { type = "OH58D",         sling = false, crates = false, maxCrates = 0, maxTroops = 0,  length = 14, mass = 400 },
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
        if unit.type == CTLD_CARGO.Enum.TROOPS then
            ctldInstance:AddTroopsCargo(unit.ctldName, { groupName }, unit.type, unit.size, unit.time, unit.mass)
        else
            ctldInstance:AddCratesCargo(unit.ctldName, { groupName }, unit.type, unit.size, unit.time, unit.mass)
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
    ctldInstance.pilotmustopendoors = true
    ctldInstance.enableChinookGCLoading = false
    ctldInstance.movecratesbeforebuild = false
    ctldInstance.nobuildinloadzones = true
    ctldInstance.ChinookTroopCircleRadius = 5
    ctldInstance.onestepmenu = true
    ctldInstance.enableLoadSave = true
    ctldInstance.saveinterval = 600
    ctldInstance.filename = "missionsave.csv"
    ctldInstance.filepath = "C:\\Users\\myname\\Saved Games\\DCS\\Missions\\MyMission"

    -- Add all load zones
    for _, zoneName in ipairs(LOAD_ZONES) do
        ctldInstance:AddCTLDZone(zoneName, CTLD.CargoZoneType.LOAD, SMOKECOLOR.Blue, true, true)
    end

    for _, chop in ipairs(CHOPPER_CONFIG) do
        ctldInstance:SetUnitCapabilities(chop.type, chop.sling, chop.crates, chop.maxCrates, chop.maxTroops, chop.length,
            chop.mass)
    end

    ctldInstance:__Start(5)

    return ctldInstance
end

local my_ctld = configureCTLD(coalition.side.RED, "R_Cargo")
local my_ctld2 = configureCTLD(coalition.side.BLUE, "B_Cargo")


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

    for _, unit in ipairs(UNIT_CONFIG) do
        local buyMenu = MENU_COALITION:New(coalitionSide, "Buy " .. unit.menuName .. " (" .. unit.cost .. ")",
            suppliesMenu)
        MENU_COALITION_COMMAND:New(coalitionSide, "Complete Purchase", buyMenu, buyUnit, coalitionSide, sideName,
            ctldInstance, unit)
    end
end

buildMenus(coalition.side.RED, "red", my_ctld)
buildMenus(coalition.side.BLUE, "blue", my_ctld2)
