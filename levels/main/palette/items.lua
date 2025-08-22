local animated = require "engine.tech.animated"
local items = {}

items.knife = function()
  return Table.extend(animated.mixin("engine/assets/sprites/animations/knife"), {
    name = "кухонный нож",
    direction = Vector.right,
    -- damage_roll = D(2),
    -- bonus = 1,
    -- tags = {
    --   finesse = true,
    --   light = true,
    -- },
    -- slot = "hands",
  })
end

return items
