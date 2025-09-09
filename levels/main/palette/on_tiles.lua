local factoring = require("engine.tech.factoring")
local config = require("levels.main.config")

return factoring.from_atlas("assets/sprites/atlases/on_tiles.png", config.cell_size, {
  "snow_1",  "snow_2",  "snow_3",  "snow_4",  "fern", false, false, false,
  "snow_5",  "snow_6",  "snow_7",  "snow_8",  false,  false, false, false,
  "snow_9",  "snow_10", "snow_11", "snow_12", false,  false, false, false,
  "snow_13", "snow_14", "snow_15", "snow_16", false,  false, false, false,
  "carpet_1",  "carpet_2",  "carpet_3",  "carpet_4",  false, false, false, false,
  "carpet_5",  "carpet_6",  "carpet_7",  "carpet_8",  false, false, false, false,
  "carpet_9",  "carpet_10", "carpet_11", "carpet_12", false, false, false, false,
  "carpet_13", "carpet_14", "carpet_15", "carpet_16", false, false, false, false,
}, function(codename)
  return {boring_flag = true}
end)
