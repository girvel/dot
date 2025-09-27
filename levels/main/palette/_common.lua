local animated = require "engine.tech.animated"
local water    = require "engine.tech.shaders.water"


local _common = {}

_common.water = function(velocity)
  return function()
    local result = Table.extend({
      codename = "water",
      transparent_flag = true,
      low_flag = true,
      boring_flag = true,
      water_velocity = velocity,
      shader = water.new("assets/sprites/palette.png", 39),
    }, animated.mixin("assets/sprites/animations/water", 1))

    return result
  end
end

return _common
