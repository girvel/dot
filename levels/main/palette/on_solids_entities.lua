local animated = require "engine.tech.animated"


local on_solids_entities = {}

Table.extend(on_solids_entities,
  require("levels.main.palette.insects"),
  require("levels.main.palette.items_entities")
)

on_solids_entities.pyre_1 = function()
  return Table.extend(animated.mixin("assets/sprites/animations/pyre", 1), {
    codename = "pyre_1",
    transparent_flag = true,
  })
end

on_solids_entities.pyre_2 = function()
  return Table.extend(animated.mixin("assets/sprites/animations/pyre", 2), {
    codename = "pyre_2",
    transparent_flag = true,
  })
end

Ldump.mark(on_solids_entities, "const", ...)
return on_solids_entities
