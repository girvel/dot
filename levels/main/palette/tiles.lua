local factoring = require("engine.tech.factoring")

-- TODO! cell_size should be in level definition
return factoring.from_atlas("assets/sprites/atlases/tiles.png", 16, {
  "light_grass", "dark_grass",
})
