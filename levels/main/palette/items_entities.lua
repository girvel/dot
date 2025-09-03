local animated = require("engine.tech.animated")
local weapons  = require "engine.mech.weapons"


local items = {}

items.knife = weapons.knife

items.head_tatoo_1 = function()
  return Table.extend(animated.mixin("assets/sprites/animations/head_tatoo_1"), {
    codename = "head_tatoo_1",
    slot = "tatoo",
    anchor = "head",
  })
end

items.bag = function()
  return Table.extend(animated.mixin("assets/sprites/animations/bag"), {
    codename = "bag",
    slot = "bag",
    anchor = "right_pocket",
  })
end

items.ritual_mask = function()
  return Table.extend(animated.mixin("assets/sprites/animations/ritual_mask"), {
    codename = "ritual_mask",
    slot = "head",
  })
end

items.invader_helmet = function()
  return Table.extend(animated.mixin("assets/sprites/animations/invader_helmet"), {
    codename = "invader_helmet",
    slot = "head",
  })
end

items.invader_armor = function()
  return Table.extend(animated.mixin("assets/sprites/animations/invader_armor"), {
    codename = "invader_armor",
    slot = "body",
  })
end

return items
