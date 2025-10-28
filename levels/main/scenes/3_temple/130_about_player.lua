local api = require("engine.tech.api")
local core = require("levels.main.core")
local screenplay = require("engine.tech.screenplay")


return {
  --- @type scene
  _130_about_player = {
    characters = {
      player = {},
      likka = {},
    },

    start_predicate = function(self, dt, ch, ps)
      return (State.player.position - ps.ap_start):abs2() <= 3
        or State.player.position.x >= ps.ap_start.x
    end,

    run = function(self, ch, ps)
      State.runner.scenes._132_noticing_shard.enabled = true

      local sp = screenplay.new("assets/screenplay/130_about_player.ms", ch)
        core.bring_likka()

        api.travel_scripted(ch.likka, ch.player.position + Vector.right * 2, 7):wait()
        api.rotate(ch.likka, ch.player)

        sp:lines()
        api.rotate(ch.player, ch.likka)

        local n = api.options(sp:start_options())
        sp:start_option(n)
          sp:start_single_branch(State.rails.empathy == "present" and 1 or 2)
            sp:lines()
          sp:finish_single_branch()
        sp:finish_option()
        sp:finish_options()
      sp:finish()
    end,
  },
}
