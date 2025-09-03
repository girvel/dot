local factoring = require("engine.tech.factoring")
local config = require("levels.main.config")

local lows = Table.set {
  "slope_2", "slope_3", "slope_5", "slope_6",
}

local transparents = Table.set {
  "slope_1", "slope_2", "slope_3", "slope_4", "slope_5", "slope_6",
  "bush_1", "bush_2", "bush_3", "bush_4",
  "statue_1", "statue_2", "statue_3", "statue_4", "statue_5", "statue_6",
}

return factoring.from_atlas(
  "assets/sprites/atlases/solids.png", config.cell_size,
  {
    "wall_1",    "wall_2",    "wall_3",   "wall_4",   "hutwall_1",  "hutwall_2",  "hutwall_3",  "hutwall_4",
    "wall_5",    "wall_6",    "wall_7",   "wall_8",   "hutwall_5",  "hutwall_6",  "hutwall_7",  "hutwall_8",
    "wall_9",    "wall_10",   "wall_11",  "wall_12",  "hutwall_9",  "hutwall_10", "hutwall_11", "hutwall_12",
    "wall_13",   "wall_14",   "wall_15",  "wall_16",  "hutwall_13", "hutwall_14", "hutwall_15", "hutwall_16",
    "slope_1",   "slope_2",   false,      "trunk_1",  "trunk_2",    "bush_1",     "bush_2",     "bush_5",
    "slope_3",   "slope_4",   "slope_5",  "trunk_3",  "trunk_4",    "bush_3",     "bush_4",     "bush_6",
    false,       "slope_6",   false,      "trunk_5",  "trunk_6",    "rock_1",     "rock_2",     false,
    false,       false,       false,      "statue_1", "statue_2",   false,        false,        false,
    false,       false,       false,      false,      false,        false,        false,        false,
    "shrooms_1", "shrooms_2", false,      false,      false,        false,        false,        false,
    "shrooms_3", "shrooms_4", false,      false,      false,        false,        false,        false,
  },
  function(codename)
    return {
      transparent_flag = transparents[codename],
      boring_flag = true,
      low_flag = lows[codename],
    }
  end
)
