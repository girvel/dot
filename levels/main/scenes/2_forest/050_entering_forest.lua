local screenplay = require("engine.tech.screenplay")


return {
  --- @type scene|table
  _050_entering_forest = {
    enabled = true,

    characters = {
      player = {},
    },

    --- @param self scene|table
    --- @param dt number
    --- @param ch runner_characters
    --- @param ps runner_positions
    start_predicate = function(self, dt, ch, ps)
      return not (ch.player.position >= ps.beach_start and ch.player.position <= ps.beach_end)
    end,

    --- @param self scene|table
    --- @param ch runner_characters
    --- @param ps runner_positions
    run = function(self, ch, ps)
      local sp = screenplay.new("assets/screenplay/050_entering_forest.ms", ch)
        sp:lines()
      sp:finish()
    end,
  },
}
