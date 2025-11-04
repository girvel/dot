local screenplay = require("engine.tech.screenplay")


return {
  --- @type scene
  _162_empty_village = {
    enabled = true,
    characters = {
      player = {},
    },

    start_predicate = function(self, dt, ch, ps)
      return ch.player.position.y <= ps.empty_village_y.y
    end,

    run = function(self, ch, ps)
      local sp = screenplay.new("assets/screenplay/162_empty_village.ms", ch)
        sp:lines()
      sp:finish()
    end,
  },
}
