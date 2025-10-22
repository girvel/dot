local _common     = require("levels.main.palette._common")
local player    = require("levels.main.palette.player")
local animated  = require("engine.tech.animated")
local sprite    = require("engine.tech.sprite")


local solids_entities = {}

solids_entities.player = player.new

solids_entities.water_down = _common.water(Vector.down * .5)
solids_entities.water_right = _common.water(Vector.right * .5)
solids_entities.water_still = _common.water(Vector.zero)

Table.extend(
  solids_entities,
  require("levels.main.palette.npcs"),
  require("levels.main.palette.wildlife")
)

solids_entities.pyre_3 = function()
  return Table.extend(animated.mixin("assets/sprites/animations/pyre", 3), {
    codename = "pyre_3",
    transparent_flag = true,
  })
end

solids_entities.pyre_4 = function()
  return Table.extend(animated.mixin("assets/sprites/animations/pyre", 4), {
    codename = "pyre_4",
    transparent_flag = true,
  })
end

solids_entities.path_blocker = function()
  return {
    sprite = sprite.image("assets/sprites/empty.png"),
    codename = "path_blocker",
    transparent_flag = true,
  }
end

Ldump.mark(solids_entities, "const", ...)
return solids_entities
