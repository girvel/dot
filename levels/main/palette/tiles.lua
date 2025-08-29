local factoring = require("engine.tech.factoring")
local config = require("levels.main.config")
local sound  = require("engine.tech.sound")

local walk_sounds = {
  walkway = sound.multiple("assets/sounds/walk/walkway", .1),
}

return factoring.from_atlas("assets/sprites/atlases/tiles.png", config.cell_size, {
  "grass_1",  "grass_2",  "dirt",      "sand",      "leaves", "roots", "flowers_1", "planks",
  false,      false,      "walkway_1", "walkway_2", "snow",   false,   "flowers_2", false,
  "bricks_1", "bricks_2", false,       false,       false,    false,   "flowers_3", false,
  "bricks_3", "bricks_4", false,       false,       false,    false,   "flowers_4", false,
}, function(codename)
  local s = walk_sounds[codename]
  return {
    boring_flag = true,
    sounds = s and {walk = s}
  }
end)
