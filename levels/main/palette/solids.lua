local factoring = require("engine.tech.factoring")
local config = require("levels.main.config")

return factoring.from_atlas("assets/sprites/atlases/solids.png", config.cell_size, {
  "wall_1",  "wall_2",  "wall_3",  "wall_4",  false, false, false, false,
  "wall_5",  "wall_6",  "wall_7",  "wall_8",  false, false, false, false,
  "wall_9",  "wall_10", "wall_11", "wall_12", false, false, false, false,
  "wall_13", "wall_14", "wall_15", "wall_16", false, false, false, false,
})
