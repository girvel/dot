local sound = require("engine.tech.sound")
local factoring = require("engine.tech.factoring")
local config = require("levels.main.config")

local get_walk_sounds = function(codename)
  if codename:starts_with("snow") then
    return sound.multiple("assets/sounds/walk/snow", .4)
  end
end

return factoring.from_atlas("assets/sprites/atlases/on_tiles.png", config.cell_size, {
  "snow",   "snow",   "snow",   "snow",   "fern",    false,     false, false,
  "snow",   "snow",   "snow",   "snow",   "bones",   false,     false, false,
  "snow",   "snow",   "snow",   "snow",   "bonef",   false,     false, false,
  "snow",   "snow",   "snow",   "snow",   "scastle", "scastle", false, false,
  "carpet", "carpet", "carpet", "carpet", "carpet", "carpet", "carpet", "carpet",
  "carpet", "carpet", "carpet", "carpet", "carpet", "carpet", "carpet", "carpet",
  "carpet", "carpet", "carpet", "carpet", "carpet", "carpet", "carpet", "carpet",
  "carpet", "carpet", "carpet", "carpet", "carpet", "carpet", "carpet", "carpet",
}, function(codename)
  local walk_sounds = get_walk_sounds(codename)
  return {
    boring_flag = true,
    sounds = walk_sounds and {
      walk = walk_sounds,
    },
  }
end)
