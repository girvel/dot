local level = require("engine.tech.level")
local api = require("engine.tech.api")
local screenplay = require("engine.tech.screenplay")


return {
  --- @type scene
  _160_entering_village = {
    enabled = true,
    mode = "sequential",
    characters = {
      player = {},
    },

    start_predicate = function(self, dt, ch, ps)
      return ps.ev_start <= ch.player.position and ch.player.position <= ps.ev_start_end
    end,

    run = function(self, ch, ps)
      local sp = screenplay.new("assets/screenplay/160_entering_village.ms", ch)
        local n = State.rails.fruit_source and 1
          or State.rails.seen_rotten_fruit and 2
          or 3

        sp:start_single_branch(n)
          sp:lines()
        sp:finish_single_branch()
      sp:finish()

      sp:lines()

      if api.options(sp:start_options()) == 1 then
        api.travel_scripted(ch.player, ch.player.position + Vector.down):wait()
        return
      end
      sp:finish_options()

      State.runner:remove(self)

      -- NEXT fade travel
      level.unsafe_move(ch.player, ps.ev_tp)
      State.rails:location_village()
    end,
  },
}
