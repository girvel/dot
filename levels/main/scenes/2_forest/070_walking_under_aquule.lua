local screenplay = require("engine.tech.screenplay")
local aquule     = require("engine.tech.shaders.aquule")


local is_under_aquule = function()
  local ps = State.runner.positions
  return Math.inside_polygon(State.player.position, {
    ps.aquule_1,
    ps.aquule_2,
    ps.aquule_3,
    ps.aquule_4,
    ps.aquule_5,
    ps.aquule_6,
    ps.aquule_7,
    ps.aquule_8,
    ps.aquule_9,
    ps.aquule_10,
    ps.aquule_11,
    ps.aquule_12,
  })
end

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
      if is_under_aquule() then
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
      return is_under_aquule()
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
