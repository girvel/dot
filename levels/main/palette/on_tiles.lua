local sound = require("engine.tech.sound")
local factoring = require("engine.tech.factoring")
local config = require("levels.main.config")

local get_walk_sounds = function(codename)
  if codename:starts_with("snow") then
    return sound.multiple("assets/sounds/walk/snow", .4)
  end
end

return factoring.from_atlas("assets/sprites/atlases/on_tiles.png", config.cell_size, {
  "snow_1",  "snow_2",  "snow_3",  "snow_4",  "fern",  false, false, false,
  "snow_5",  "snow_6",  "snow_7",  "snow_8",  "bones", false, false, false,
  "snow_9",  "snow_10", "snow_11", "snow_12", "bonef", false, false, false,
  "snow_13", "snow_14", "snow_15", "snow_16", false,   false, false, false,
  "carpet_1",  "carpet_2",  "carpet_3",  "carpet_4",  false, false, false, false,
  "carpet_5",  "carpet_6",  "carpet_7",  "carpet_8",  false, false, false, false,
  "carpet_9",  "carpet_10", "carpet_11", "carpet_12", false, false, false, false,
  "carpet_13", "carpet_14", "carpet_15", "carpet_16", false, false, false, false,
}, function(codename)
  local walk_sounds = get_walk_sounds(codename)
  return {
    boring_flag = true,
    sounds = walk_sounds and {
      walk = walk_sounds,
    },
  }
end)
