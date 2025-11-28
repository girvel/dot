local api = require("engine.tech.api")


return {
  --- @type scene
  _182_enable_sound = {
    enabled = true,
    characters = {
      player = {}
    },

    start_predicate = function(self, dt, ch, ps)
      return api.distance(ch.player, ps.es_start) <= 1
    end,

    run = function(self, ch, ps)
      if State.rails.has_blessing then
        ch.player.is_deaf = nil
      end
    end,
  },
}
