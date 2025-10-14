local async = require("engine.tech.async")
local screenplay = require("engine.tech.screenplay")
local api = require("engine.tech.api")


return {
  --- @type scene|table
  _116_walking_corridor = {
    enabled = true,
    characters = {
      player = {},
      likka = {},
    },

    start_predicate = function(self, dt, ch, ps)
      return (State.player.position - ps.wc_start):abs2() <= 1
    end,

    run = function(self, ch, ps)
      local sp = screenplay.new("assets/screenplay/116_walking_corridor.ms", ch)
        if not api.is_visible(ch.likka) then
          api.travel_scripted(ch.likka, ch.player.position):wait()
        end

        sp:lines()

        local n = api.options(sp:start_options())
        sp:finish_options()
        if n == 3 then
          State.rails:empathy_lower()
        end

        api.rotate(ch.likka, ch.player)
        api.rotate(ch.player, ch.likka)

        sp:lines()

        n = api.options(sp:start_options())
          if n == 2 then
            sp:start_branch(2)
              sp:lines()
            sp:finish_branch()
          elseif n == 4 then
            State.rails:empathy_lower()
          end
        sp:finish_options()

        async.sleep(1.5)
        sp:lines()
      sp:finish()
    end,
  },
}
