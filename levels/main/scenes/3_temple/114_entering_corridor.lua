local async = require("engine.tech.async")
local core = require("levels.main.core")
local screenplay = require("engine.tech.screenplay")
local api = require("engine.tech.api")


return {
  --- @type scene
  _114_entering_corridor = {
    enabled = true,
    characters = {
      likka = {},
      player = {},
    },

    start_predicate = function(self, dt, ch, ps)
      return (State.player.position - ps.ec_start):abs2() <= 2
        or State.player.position.x >= ps.ec_start.x
    end,

    run = function(self, ch, ps)
      State.runner.scenes._116_walking_corridor.enabled = true

      local sp = screenplay.new("assets/screenplay/114_entering_corridor.ms", ch)
        core.bring_likka()
        api.rotate(ch.likka, ch.player)
        sp:lines()

        api.rotate(ch.player, ch.likka)
        local n = api.options(sp:start_options())
          sp:start_option(n)
            if n == 1 then
              sp:lines()
              State.rails:empathy_lower()
            elseif n == 3 then
              sp:lines()

              async.sleep(.5)
              sp:lines()

              State.rails:empathy_raise()
            end
          sp:finish_option()
        sp:finish_options()
      sp:finish()
    end,
  },
}
