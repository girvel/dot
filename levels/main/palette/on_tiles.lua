local sound = require("engine.tech.sound")
local factoring = require("engine.tech.factoring")
local level  = require("engine.tech.level")

local get_walk_sounds = function(codename)
  if codename:starts_with("snow") then
    return sound.multiple("assets/sounds/walk/snow", .4)
  end
end

local get_base = function(codename)
  if codename:starts_with("scastle") then
    return {
      ai = {
        observe = function(self, entity)
          if State.grids.solids[entity.position] then
            State:remove(entity)
          end
        end,
      }
    }
  end
  if codename:starts_with("snow") then
    return {winter_flag = true}
  end
  return {}
end

local on_tiles = factoring.from_atlas("assets/sprites/atlases/on_tiles.png", Constants.cell_size, {
  "snow",   "snow",   "snow",   "snow",   "fern",    "shroom",  "shroom", "shroom",
  "snow",   "snow",   "snow",   "snow",   "bones",   "htail",   "htail",  "htail",
  "snow",   "snow",   "snow",   "snow",   "bonef",   "poodle",  "poodle", "bonef",
  "snow",   "snow",   "snow",   "snow",   "scastle", "scastle", "bones",  "bones",
  "carpet", "carpet", "carpet", "carpet", "carpet",  "carpet",  "carpet", "carpet",
  "carpet", "carpet", "carpet", "carpet", "carpet",  "carpet",  "carpet", "carpet",
  "carpet", "carpet", "carpet", "carpet", "carpet",  "carpet",  "carpet", "carpet",
  "carpet", "carpet", "carpet", "carpet", "carpet",  "carpet",  "carpet", "carpet",
  "carpet", "carpet", "carpet", "carpet", "carpet",  "carpet",  "carpet", "carpet",
  "carpet", "carpet", "carpet", "carpet", "carpet",  "carpet",  "carpet", "carpet",
  "carpet", "carpet", "carpet", "carpet", "carpet",  "carpet",  "carpet", "carpet",
  "carpet", "carpet", "carpet", "carpet", "carpet",  "carpet",  "carpet", "carpet",
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

Ldump.mark(on_tiles, "const", ...)
return on_tiles
