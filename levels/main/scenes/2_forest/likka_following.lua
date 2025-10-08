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
      return true
    end,

    run = function(self, ch, ps)
      local needs_travel = function()
        if State.combat then return false end
        local distance = (ch.likka.position - State.player.position):abs2()
        return distance <= 1 or distance > NEUTRAL_DISTANCE
      end

      while self.enabled do
        if needs_travel() then
          local target = State.player.position
          local norm = (target - ch.likka.position):normalized2()
          local shift = norm:rotate()

          for _, offset in ipairs {Vector.zero, shift, -shift} do
            local path = api.build_path(ch.likka.position, target - norm * 2 + offset)
            if path then
              api.follow_path(ch.likka, path, false, 7.5)
              api.rotate(ch.likka, State.player)
              break
            end
          end
        end

        coroutine.yield()
      end
    end,
  },
}
