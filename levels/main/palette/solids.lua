local factoring = require("engine.tech.factoring")
local config = require("levels.main.config")

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
  )
end

return factoring.from_atlas(
  "assets/sprites/atlases/solids.png", config.cell_size,
  {
    "wall_1",    "wall_2",    "wall_3",   "wall_4",   "hutwall_1",  "hutwall_2",  "hutwall_3",  "hutwall_4",
    "wall_5",    "wall_6",    "wall_7",   "wall_8",   "hutwall_5",  "hutwall_6",  "hutwall_7",  "hutwall_8",
    "wall_9",    "wall_10",   "wall_11",  "wall_12",  "hutwall_9",  "hutwall_10", "hutwall_11", "hutwall_12",
    "wall_13",   "wall_14",   "wall_15",  "wall_16",  "hutwall_13", "hutwall_14", "hutwall_15", "hutwall_16",
    "slope_1",   "slope_2",   "godfruit", "trunk_1",  "trunk_2",    "bush_1",     "bush_2",     "bush_5",
    "slope_3",   "slope_4",   "slope_5",  "trunk_3",  "trunk_4",    "bush_3",     "bush_4",     "bush_6",
    false,       "slope_6",   "stool",    "trunk_5",  "trunk_6",    "rock_1",     "rock_2",     "table_1",
    false,       false,       false,      "statue_1", "statue_2",   "statue_3",   "statue_4",   "table_2",
    false,       false,       false,      false,      "table_5",    "table_6",    "table_7",    "table_3",
    "owall_1",   "owall_2",   "owall_3",  "owall_4",  false,        "chest",      "chest_open", "table_4",
    "owall_5",   "owall_6",   "owall_7",  "owall_8",  false,        false,        false,        false,
    "owall_9",   "owall_10",  "owall_11", "owall_12", false,        false,        false,        false,
    "owall_13",  "owall_14",  "owall_15", "owall_16", false,        false,        false,        false,
    "stage_1",   "stage_2",   "stage_3",  "stage_4",  false,        false,        false,        false,
    "stage_5",   "stage_6",   "stage_7",  "stage_8",  false,        false,        false,        false,
    "stage_9",   "stage_10",  "stage_11", "stage_12", false,        false,        false,        false,
    "stage_13",  "stage_14",  "stage_15", "stage_16", false,        false,        false,        false,
  },
  function(codename)
    return {
      transparent_flag = is_low(codename),
      boring_flag = true,
      low_flag = is_low(codename),
    }
  end
)
