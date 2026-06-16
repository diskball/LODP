-- cfxScoreTable.lua
-- Score table for cfxPlayerScore. Load this script BEFORE cfxPlayerScore in the mission triggers.
-- Edit values here freely without touching the Mission Editor.
--
-- Keys match against unit name, group name, or DCS type name (case-insensitive).
-- Append * to match any name starting with that prefix (e.g. "RED T55*" catches "RED T55 #001-01").
-- Priority: unit name > group name > type name. First match wins.

cfxScoreTableData = {

    -- TROOPS (scored per individual soldier spawned)
    ["AAR*"]            = 8,    -- RED MANPADS
    ["AAB*"]            = 8,    -- BLUE MANPADS
    ["RIFLER*"]         = 3,    -- RED Infantry
    ["RIFLEB*"]         = 3,    -- BLUE Infantry

    -- SCOUTS / SUPPORT
    ["RED SCOUT*"]      = 15,   -- M-113
    ["BLUE SCOUT*"]     = 15,
    ["RED JTAC*"]       = 20,
    ["BLUE JTAC*"]      = 20,
    ["RED SBORKA*"]     = 20,   -- Sborka EWR (light)
    ["BLUE SBORKA*"]    = 20,
    ["RED EWR*"]        = 40,   -- 55G6 EWR (heavy)
    ["BLUE EWR*"]       = 40,
    ["FARP_LOGISTICS*"] = 8,    -- catches both _red and _blue suffix
    ["AMMO_TRUCK*"]     = 5,    -- catches both _Red and _Blue suffix

    -- MBT
    ["RED T55*"]        = 30,
    ["BLUE T55*"]       = 30,
    ["RED TANK*"]       = 50,   -- Leopard-2
    ["BLUE TANK*"]      = 50,

    -- SHORAD (single-vehicle systems)
    ["RED SHILKA*"]     = 25,
    ["BLUE SHILKA*"]    = 25,
    ["RED CHAPARRAL*"]  = 30,
    ["BLUE CHAPARRAL*"] = 30,
    ["RED SA13*"]       = 35,
    ["BLUE SA13*"]      = 35,
    ["RED SA8*"]        = 40,
    ["BLUE SA8*"]       = 40,
    ["RED SA19*"]       = 40,   -- Tunguska
    ["BLUE SA19*"]      = 40,
    ["RED SA15M1*"]     = 60,   -- Tor-M1
    ["BLUE SA15M1*"]    = 60,
    ["RED C-RAM*"]      = 80,
    ["BLUE C-RAM*"]     = 80,

    -- SAM SYSTEMS (multi-component groups, score is per unit killed)
    ["RED SA6*"]        = 25,   -- ~4 units per group → ~100 pts full system
    ["BLUE SA6*"]       = 25,
    ["RED SA15M2*"]     = 60,   -- Tor-M2
    ["BLUE SA15M2*"]    = 60,
    ["RED HAWK*"]       = 30,   -- ~5 units per group → ~150 pts full system
    ["BLUE HAWK*"]      = 30,
    ["RED SA11*"]       = 40,   -- ~5 units per group → ~200 pts full system
    ["BLUE SA11*"]      = 40,
    ["RED SA10*"]       = 60,   -- ~5+ units per group → ~300 pts full system
    ["BLUE SA10*"]      = 60,
}
