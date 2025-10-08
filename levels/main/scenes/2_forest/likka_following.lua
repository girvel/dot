local api = require("engine.tech.api")
local async = require("engine.tech.async")


local NEUTRAL_DISTANCE = 4
local ADHD_PERIOD = 15

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

      local last_action_t = love.timer.getTime()
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
              last_action_t = love.timer.getTime()
              break
            end
          end
        end

        if love.timer.getTime() - last_action_t >= ADHD_PERIOD
          and State.period:absolute(1, self, "ADHD")
          and Random.chance(.3)
        then
          last_action_t = love.timer.getTime()
          ch.likka:rotate(Random.choice(Vector.directions))
          async.sleep(Random.float(.5, 3))
          ch.likka:rotate(Random.choice(Vector.directions))
        end

        coroutine.yield()
      end
    end,
  },
}
