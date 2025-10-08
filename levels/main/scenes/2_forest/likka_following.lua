local api = require("engine.tech.api")
local async = require("engine.tech.async")


local NEUTRAL_DISTANCE = 4

return {
  --- @type scene|table
  likka_following = {
    boring_flag = true,
    mode = "sequential",

    characters = {
      likka = {},
    },

    start_predicate = function(self, dt, ch, ps)
      if State.combat then return false end
      local distance = (ch.likka.position - State.player.position):abs2()
      return distance <= 1 or distance > NEUTRAL_DISTANCE
    end,

    run = function(self, ch, ps)
      local target = State.player.position
      local norm = (target - ch.likka.position):normalized2()
      api.travel(ch.likka, target - norm * 2)
    end,
  },
}
