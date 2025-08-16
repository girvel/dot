local factoring = require("engine.tech.factoring")
local config = require("levels.main.config")

-- TODO! cell_size should be in level definition
return factoring.from_atlas("assets/sprites/atlases/tiles.png", config.cell_size, {
  "grass_1", "grass_2",
})
