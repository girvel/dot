local factoring = require("engine.tech.factoring")
local config = require("levels.main.config")

return factoring.from_atlas("assets/sprites/atlases/on_solids.png", config.cell_size, {
  "vines", "grass_1", "grass_2", false, false, false, false, false,
  false, false, false, false, false, false, false, false,
  false, false, false, false, false, false, false, false,
  false, false, false, false, false, false, false, false,
}, function(codename)
  return {boring_flag = true}
end)
