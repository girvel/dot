local on_solids = require("levels.main.palette.on_solids")
local factoring = require("engine.tech.factoring")
local config = require("levels.main.config")
local interactive = require("engine.tech.interactive")

local solids

local lows = Table.set {
  "stool", "godfruit",
}

--- @param codename string
local is_low = function(codename)
  return (
    lows[codename]
    or codename:starts_with("slope")
    or codename:starts_with("stage")
    or codename:starts_with("statue")
    or codename:starts_with("table")
    or codename:starts_with("chest")
    or codename:starts_with("bush")
    or codename:starts_with("bed")
    or codename:starts_with("fence")
    or codename:starts_with("candles")
    or codename:starts_with("hutwallt")
    or codename:starts_with("cabinet")
    or codename:starts_with("shelf")
  )
end

local open_door = function(self)
  self.on_remove = function(self)
    State:add(on_solids.dooro(), {position = self.position, grid_layer = "on_solids"})
  end
  State:remove(self)
end

local open_chest = function(self)
  self.on_remove = function(self)
    State:add(solids.chesto(), {position = self.position, grid_layer = "solids"})
  end
  State:remove(self)
end

local open_shelf = function(self)
  self.on_remove = function(self)
    State:add(solids.shelfo(), {position = self.position, grid_layer = "solids"})
  end
  State:remove(self)
end

local open_cabinet = function(self)
  self.on_remove = function(self)
    State:add(solids.cabineto(), {position = self.position, grid_layer = "solids"})
  end
  State:remove(self)
end

local get_base = function(codename)
  if codename == "doorc" then
    local result = interactive.mixin(open_door)
    result.name = "дверь"
    return result
  elseif codename == "chestc" then
    local result = interactive.mixin(open_chest)
    result.name = "сундук"
    return result
  elseif codename == "shelfc" then
    local result = interactive.mixin(open_shelf)
    result.name = "полки"
    return result
  elseif codename == "cabinetc" then
    local result = interactive.mixin(open_cabinet)
    result.name = "шкаф"
    return result
  end
  return {}
end

solids = factoring.from_atlas(
  "assets/sprites/atlases/solids.png", config.cell_size,
  {
    "wall_1",    "wall_2",    "wall_3",   "wall_4",   "hutwall_1",  "hutwall_2",  "hutwall_3",  "hutwall_4",
    "wall_5",    "wall_6",    "wall_7",   "wall_8",   "hutwall_5",  "hutwall_6",  "hutwall_7",  "hutwall_8",
    "wall_9",    "wall_10",   "wall_11",  "wall_12",  "hutwall_9",  "hutwall_10", "hutwall_11", "hutwall_12",
    "wall_13",   "wall_14",   "wall_15",  "wall_16",  "hutwall_13", "hutwall_14", "hutwall_15", "hutwall_16",
    "slope_1",   "slope_2",   "godfruit", "trunk_1",  "trunk_2",    "bush_1",     "bush_2",     "bush_5",
    "slope_3",   "slope_4",   "slope_5",  "trunk_3",  "trunk_4",    "bush_3",     "bush_4",     "bush_6",
    "slope_h",   "slope_6",   "stool",    "trunk_5",  "trunk_6",    "rock_1",     "rock_2",     "table_1",
    false,       "slope",     "slope",    "statue_1", "statue_2",   "statue_3",   "statue_4",   "table_2",
    false,       "slope",     "slope",    false,      "table_5",    "table_6",    "table_7",    "table_3",
    "owall_1",   "owall_2",   "owall_3",  "owall_4",  false,        "chestc",     "chesto",     "table_4",
    "owall_5",   "owall_6",   "owall_7",  "owall_8",  false,        "bed_1",      "bed_2",      false,
    "owall_9",   "owall_10",  "owall_11", "owall_12", "candles_1",  "candles_2",  "candles_3",  false,
    "owall_13",  "owall_14",  "owall_15", "owall_16", "doorc",      false,        false,        false,
    "stage_1",   "stage_2",   "stage_3",  "stage_4",  "fence",      "fence",      "fence",      "fence",
    "stage_5",   "stage_6",   "stage_7",  "stage_8",  "fence",      "fence",      "fence",      "fence",
    "stage_9",   "stage_10",  "stage_11", "stage_12", "fence",      "fence",      "fence",      "fence",
    "stage_13",  "stage_14",  "stage_15", "stage_16", "fence",      "fence",      "fence",      "fence",
    "cabinetc",  "cabineto",  "shelfc",   "shelfo",   "hutwallt",   "hutwallt",   false,        false,
  },
  function(codename)
    local result = get_base(codename)
    result.transparent_flag = is_low(codename)
    result.low_flag = is_low(codename)
    result.boring_flag = true
    return result
  end
)

return solids
