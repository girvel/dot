local factoring = require("engine.tech.factoring")
local config = require("levels.main.config")

local lows = Table.set {
  "slope_2", "slope_3", "slope_5", "slope_6",
}

return factoring.from_atlas(
  "assets/sprites/atlases/solids.png", config.cell_size,
  {
    "wall_1",  "wall_2",  "wall_3",  "wall_4",  "hutwall_1",  "hutwall_2",  "hutwall_3",  "hutwall_4",
    "wall_5",  "wall_6",  "wall_7",  "wall_8",  "hutwall_5",  "hutwall_6",  "hutwall_7",  "hutwall_8",
    "wall_9",  "wall_10", "wall_11", "wall_12", "hutwall_9",  "hutwall_10", "hutwall_11", "hutwall_12",
    "wall_13", "wall_14", "wall_15", "wall_16", "hutwall_13", "hutwall_14", "hutwall_15", "hutwall_16",
    "slope_1", "slope_2", false,     "trunk_1", "trunk_2",    false,        false,        false,
    "slope_3", "slope_4", "slope_5", "trunk_3", "trunk_4",    false,        false,        false,
    false,     "slope_6", false,     "trunk_5", "trunk_6",    false,        false,        false,
  },
  function(codename)
    return {
      transparent_flag = codename:starts_with("slope") or nil,
      boring_flag = true,
      low_flag = lows[codename],
    }
  end
)
