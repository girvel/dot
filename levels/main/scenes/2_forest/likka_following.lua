local api = require("engine.tech.api")
local async = require("engine.tech.async")


local NEUTRAL_DISTANCE = 4
local ADHD_PERIOD = 15

local needs_travel = function(likka)
  if State.combat then return false end
  local distance = (likka.position - State.player.position):abs2()
  return distance <= 1 or distance > NEUTRAL_DISTANCE
end

return {
  --- @type scene|table
  likka_following = {
    boring_flag = true,
    mode = "sequential",

    characters = {
      likka = {},
    },

    start_predicate = function(self, dt, ch, ps)
      -- not every tick to not potentially block cutscenes
      return State.period:absolute(.1, self, "start")
        and State.hostility:get(ch.likka, State.player) ~= "enemy"
    end,

    _last_action_t = nil,

    run = function(self, ch, ps)
      -- one iteration at a time, because needs to be disabled in cutscenes
      if needs_travel(ch.likka) then
        async.sleep(Random.float(.1, .3))

        local target = State.player.position
        local norm = (target - ch.likka.position):normalized2()
        local shift = norm:rotate()

        for _, offset in ipairs {Vector.zero, shift, -shift} do
          local path = api.build_path(ch.likka.position, target - norm * 2 + offset)
          if path then
            api.follow_path(ch.likka, path, false, 7.5)
            async.sleep(Random.float(.1, .2))
            if not needs_travel(ch.likka) then
              api.rotate(ch.likka, State.player)
            end
            self._last_action_t = love.timer.getTime()
            break
          end
        end
      end

      if love.timer.getTime() - self._last_action_t >= ADHD_PERIOD
        and State.period:absolute(1, self, "ADHD")
        and Random.chance(.3)
      then
        self._last_action_t = love.timer.getTime()
        ch.likka:rotate(Random.choice(Vector.directions))
        async.sleep(Random.float(.5, 3))
        ch.likka:rotate(Random.choice(Vector.directions))
      end
    end,
  },
}
