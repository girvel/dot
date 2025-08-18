local factoring = require("engine.tech.factoring")
local config = require("levels.main.config")

return factoring.from_atlas("assets/sprites/atlases/tiles.png", config.cell_size, {
  "grass_1", "grass_2", "dirt_1", "dirt_2", "leaves", "roots", "flowers_1", "planks",
  false, false, "gravel_1", "gravel_2", "snow", false, "flowers_2", false,
  false, false, false, false, false, false, "flowers_3", false,
  false, false, false, false, false, false, "flowers_4", false,
})
