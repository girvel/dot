local shaders = require "engine.tech.shaders"
local animated = require "engine.tech.animated"


local _common = {}

_common.water = function(velocity)
  return function()
    local result = Table.extend({
      transparent_flag = true,
      low_flag = true,
      water_velocity = velocity,
      shader = shaders.water("assets/sprites/palette.png", 39),
    }, animated.mixin("assets/sprites/animations/water"))

    return result
  end
end

return _common
