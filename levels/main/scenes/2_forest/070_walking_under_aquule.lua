local screenplay = require("engine.tech.screenplay")
local aquule     = require("engine.tech.shaders.aquule")


local polygon = Memoize(function()
  return Polygon.new(State.runner:position_sequence("aquule"))
end)
Ldump.ignore_size(polygon)

return {
  --- @type scene|table
  aquule_shader = {
    enabled = true,
    boring_flag = true,
    mode = "sequential",

    characters = {},

    --- @param self scene|table
    --- @param dt number
    --- @param ch runner_characters
    --- @param ps runner_positions
    start_predicate = function(self, dt, ch, ps)
      return true
    end,

    --- @param self scene|table
    --- @param ch runner_characters
    --- @param ps runner_positions
    run = function(self, ch, ps)
      if polygon():includes(State.player.position) then
        if State.shader ~= aquule then
          State.shader = aquule
        end
      else
        if State.shader == aquule then
          State.shader = nil
        end
      end
    end,
  },

  --- @type scene|table
  _070_walking_under_aquule = {
    enabled = true,

    characters = {
      player = {},
    },

    --- @param self scene|table
    --- @param dt number
    --- @param ch runner_characters
    --- @param ps runner_positions
    start_predicate = function(self, dt, ch, ps)
      return polygon():includes(State.player.position)
    end,

    --- @param self scene|table
    --- @param ch runner_characters
    --- @param ps runner_positions
    run = function(self, ch, ps)
      local sp = screenplay.new("assets/screenplay/070_walking_under_aquule.ms", ch)
        sp:lines()
      sp:finish()
    end,
  },
}
