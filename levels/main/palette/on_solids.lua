local factoring = require("engine.tech.factoring")
local config = require("levels.main.config")

return factoring.from_atlas("assets/sprites/atlases/on_solids.png", config.cell_size, {
  "vines", "vines",     "vines",     "cobweb_1", "cobweb_2", "statue_1", "statue_2", false,
  false,   "candles_1", "candles_2", "cobweb_3", "cobweb_4", "statue_3", "statue_4", false,
  "stage", "candles_3", "skull",     "dooro",    "statue_5", "statue_6", "statue_7", false,
  "pot_1", "pot_2",     "pot_3",     "plate",    "plate",    false,      false,      false,
  "pot_4", "pot_5",     "pot_6",     false,      false,      false,      false,      false,
}, function(codename)
  return {boring_flag = true}
end)
