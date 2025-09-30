local screenplay = require("engine.tech.screenplay")
local aquule     = require("engine.tech.shaders.aquule")


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
      local is_under_aquule = (
        (State.player.position >= ps.aquule_start_1 and State.player.position <= ps.aquule_end_1) or
        (State.player.position >= ps.aquule_start_2 and State.player.position <= ps.aquule_end_2)
      )

      if is_under_aquule then
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
      return (
        (ch.player.position >= ps.aquule_start_1 and ch.player.position <= ps.aquule_end_1) or
        (ch.player.position >= ps.aquule_start_2 and ch.player.position <= ps.aquule_end_2)
      )
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
