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

return items
