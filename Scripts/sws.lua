--[[
### License
 This file is part of Simple Warehouse Saving.
 Copyright (C) 2023 Michael Cole

 Simple Warehouse Saving is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
--]]

SWS = {}

-- ============================================================
--  FILE PATH
-- ============================================================
SWS.filepath = lfs.writedir() .. "SimpleWarehouse.lua"

-- ============================================================
--  TIMER INTERVAL (seconds)
-- ============================================================
SWS.updateDelaySeconds = 1800

-- ============================================================
--  FILTER CONFIGURATION
--  true  = save and reload this category
--  false = ignore this category completely
-- ============================================================
SWS.filter = {
  liquids  = true,
  aircraft = true,
  weapon   = true,
}

-- ============================================================
--  BASE SELECTION
--  all = true  : process every airbase/FARP/ship (ignore list)
--  all = false : only process names in the include list
--  Use exact names as they appear in the diagnostic log
-- ============================================================
SWS.bases = {
  all = true,   -- set to false and fill include list to filter

  include = {
    -- "Kutaisi",
    -- "Batumi",
    -- "FARP ALPHA",
    -- "LHA Tarawa",
  },
}

-- ============================================================
--  COMMON FUNCTIONS
-- ============================================================
function SWS.IntegratedbasicSerialize(s)
  if s == nil then
    return "\"\""
  else
    if ((type(s) == 'number') or (type(s) == 'boolean') or (type(s) == 'function') or (type(s) == 'table') or (type(s) == 'userdata')) then
      return tostring(s)
    elseif type(s) == 'string' then
      return string.format('%q', s)
    end
  end
end

function SWS.IntegratedserializeWithCycles(name, value, saved)
  local basicSerialize = function(o)
    if type(o) == "number" then
      return tostring(o)
    elseif type(o) == "boolean" then
      return tostring(o)
    else
      return SWS.IntegratedbasicSerialize(o)
    end
  end

  local t_str = {}
  saved = saved or {}
  if ((type(value) == 'string') or (type(value) == 'number') or (type(value) == 'table') or (type(value) == 'boolean')) then
    table.insert(t_str, name .. " = ")
    if type(value) == "number" or type(value) == "string" or type(value) == "boolean" then
      table.insert(t_str, basicSerialize(value) .. "\n")
    else
      if saved[value] then
        table.insert(t_str, saved[value] .. "\n")
      else
        saved[value] = name
        table.insert(t_str, "{}\n")
        for k, v in pairs(value) do
          local fieldname = string.format("%s[%s]", name, basicSerialize(k))
          table.insert(t_str, SWS.IntegratedserializeWithCycles(fieldname, v, saved))
        end
      end
    end
    return table.concat(t_str)
  else
    return ""
  end
end

function SWS.file_exists(name)
  if lfs.attributes(name) then
    return true
  else
    return false
  end
end

function SWS.writemission(data, file)
  SWS.File = io.open(file, "w")
  SWS.File:write(data)
  SWS.File:close()
end

-- ============================================================
--  HELPER: should we process this airbase/FARP/ship?
-- ============================================================
function SWS.isIncluded(airbase)
  if SWS.bases.all then return true end
  local name = airbase:getName()
  for _, includedName in ipairs(SWS.bases.include) do
    if name == includedName then return true end
  end
  return false
end

-- ============================================================
--  DIAGNOSTIC: log all airbase/FARP/ship names to dcs.log
-- ============================================================
function SWS.runDiagnostic()
  local all = world.getAirbases()
  env.info("=== SWS DIAGNOSTIC: Found " .. #all .. " airbases/FARPs/ships ===")
  for i = 1, #all do
    local ab   = all[i]
    local name = ab:getName()
    local cat  = ab:getDesc().category
    local catName = "Unknown"
    if     cat == 0 then catName = "AIRDROME"
    elseif cat == 1 then catName = "FARP/HELIPAD"
    elseif cat == 2 then catName = "SHIP"
    end
    env.info(string.format("  [%-12s]  \"%s\"", catName, name))
  end
  env.info("=== SWS DIAGNOSTIC END ===")
end

-- ============================================================
--  SAVE
-- ============================================================
local Airbases = world.getAirbases()
SWS.airbaseContents = {}

function saveWarehouseContents()
  local saved, skipped = 0, 0
  for i = 1, #Airbases do
    if SWS.isIncluded(Airbases[i]) then
      local w   = Airbases[i]:getWarehouse()
      local Inv = w:getInventory()
      local filtered = {}

      if SWS.filter.liquids  then filtered.liquids  = Inv.liquids  end
      if SWS.filter.aircraft then filtered.aircraft = Inv.aircraft end
      if SWS.filter.weapon   then filtered.weapon   = Inv.weapon   end

      SWS.airbaseContents[Airbases[i]:getName()] = filtered
      saved = saved + 1
    else
      skipped = skipped + 1
    end
  end
  env.info(string.format("SWS: saveWarehouseContents() — saved: %d, skipped: %d", saved, skipped))
  return timer.getTime() + SWS.updateDelaySeconds
end

-- ============================================================
--  SERIALIZE
-- ============================================================
function serializeWarehouseContents()
  SWS.newMissionStr = SWS.IntegratedserializeWithCycles("SWS.SimpleWarehouse", SWS.airbaseContents)
  env.info("SWS: serializeWarehouseContents() — done")
  return timer.getTime() + SWS.updateDelaySeconds
end

-- ============================================================
--  WRITE
-- ============================================================
function writeWarehouseContents()
  SWS.writemission(SWS.newMissionStr, SWS.filepath)
  env.info("SWS: writeWarehouseContents() — written to " .. SWS.filepath)
  return timer.getTime() + SWS.updateDelaySeconds
end

-- ============================================================
--  LOAD
-- ============================================================
function loadWarehouseContents()
  dofile(SWS.filepath)
  local Airbases = world.getAirbases()
  local loaded, skipped, missing = 0, 0, 0

  for _, airbase in ipairs(Airbases) do
    if SWS.isIncluded(airbase) then
      local w    = airbase:getWarehouse()
      local name = airbase:getName()
      local data = SWS.SimpleWarehouse[name]

      if not data then
        env.info("SWS: loadWarehouseContents() — no saved data for \"" .. name .. "\", skipping")
        missing = missing + 1
        goto continue
      end

      if data.liquids then
        for liquidType, amount in pairs(data.liquids) do
          w:setLiquidAmount(liquidType, amount)
        end
      end

      if data.weapon then
        for weaponName, amount in pairs(data.weapon) do
          w:setItem(weaponName, amount)
        end
      end

      if data.aircraft then
        for aircraftName, count in pairs(data.aircraft) do
          w:setItem(aircraftName, count)
        end
      end

      loaded = loaded + 1
    else
      skipped = skipped + 1
    end
    ::continue::
  end

  env.info(string.format("SWS: loadWarehouseContents() — loaded: %d, skipped: %d, missing: %d", loaded, skipped, missing))
end

-- ============================================================
--  START
-- ============================================================
SWS.runDiagnostic()

if SWS.file_exists(SWS.filepath) then
  env.info("SWS: Save file found — loading warehouse contents ...")
  loadWarehouseContents()
else
  env.info("SWS: No save file found — writing initial warehouse contents ...")
  saveWarehouseContents()
  serializeWarehouseContents()
  writeWarehouseContents()
end

timer.scheduleFunction(saveWarehouseContents,      {}, timer.getTime() + 1)
timer.scheduleFunction(serializeWarehouseContents, {}, timer.getTime() + 2)
timer.scheduleFunction(writeWarehouseContents,     {}, timer.getTime() + 3)