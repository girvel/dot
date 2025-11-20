local sound = require("engine.tech.sound")
local factoring = require("engine.tech.factoring")

local walk_sounds = {
  snow = sound.multiple("assets/sounds/walk/snow", .1),
  carpet = sound.multiple("assets/sounds/walk/carpet", .1),
}

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
    return {
      on_add = function(self)
        table.insert(State.rails._snow, self)
      end,
    }
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

  local walk = walk_sounds[codename]
  if walk then
    result.sounds = {
      walk = walk,
    }
  end

  return result
end)

Ldump.mark(on_tiles, "const", ...)
return on_tiles
