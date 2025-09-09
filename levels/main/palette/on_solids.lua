local factoring = require("engine.tech.factoring")
local config = require("levels.main.config")

return factoring.from_atlas("assets/sprites/atlases/on_solids.png", config.cell_size, {
  "vines", "grass_1", "grass_2", "cobweb_1", "cobweb_2", "statue_1", "statue_2", false,
  false,   false,     false,     "cobweb_3", "cobweb_4", "statue_3", "statue_4", false,
  false,   false,     false,     false,      "statue_5", "statue_6", "statue_7", false,
  false,   false,     false,     false,      false,      false,      false,      false,
}, function(codename)
  return {boring_flag = true}
end)
