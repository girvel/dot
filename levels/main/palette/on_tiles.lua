local sound = require("engine.tech.sound")
local factoring = require("engine.tech.factoring")
local config = require("levels.main.config")

local get_walk_sounds = function(codename)
  if codename:starts_with("snow") then
    return sound.multiple("assets/sounds/walk/snow", .4)
  end
end

local get_base = function(codename)
  if codename:starts_with("snow") then
    return {winter_flag = true}
  end
  return {}
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
  local result = get_base(codename)
  result.boring_flag = true

  local walk_sounds = get_walk_sounds(codename)
  if walk_sounds then
    result.sounds = {
      walk = walk_sounds,
    }
  end

  return result
end)
