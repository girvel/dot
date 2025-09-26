local api = require("engine.tech.api")
local screenplay = require("engine.tech.screenplay")


return {
  _010_intro = {
    enabled = true,

    characters = {
      player = {},
      khaned = {},
      likka = {},
      red_priest = {},
    },

    --- @param self scene
    --- @param dt number
    --- @param ch rails_characters
    start_predicate = function(self, dt, ch)
      return State.is_loaded
    end,

    --- @param self scene
    --- @param ch rails_characters
    run = function(self, ch)
      local sp = screenplay.new("assets/screenplay/010_intro.ms", ch)
        ch.khaned:rotate(Vector.up)
        ch.likka:rotate(Vector.up)

        sp:lines()
        local options = sp:start_options()
        for _ = 1, 3 do
          local n = api.options(options, true)
          sp:start_option(n)
            sp:lines()
          sp:finish_option()
        end
        sp:finish_options()
        sp:lines()

        ch.khaned:rotate(Vector.right)
        sp:lines()

        api.rotate(ch.likka, ch.khaned)
        sp:lines()

        api.rotate(ch.khaned, ch.likka)
        sp:lines()

        ch.khaned:rotate(Vector.right)

        local n = api.options(sp:start_options())
          if n == 1 then
            sp:start_option(n)
            sp:start_branches()
              sp:start_branch(ch.player:ability_check("investigation", 10) and 1 or 2)
                sp:lines()
              sp:finish_branch()
            sp:finish_branches()
            sp:finish_option()
          end
        sp:finish_options()

        sp:lines()
        api.travel_scripted(ch.red_priest, Runner.positions.red_priest_1):await()
        sp:lines()
        api.travel_scripted(ch.red_priest, Runner.positions.ceremony_red_priest)
          :next(function() ch.red_priest:rotate(Vector.up) end)
        api.wait(2)

        sp:lines()
        api.wait(2)

        sp:lines()

        State.rails:location_upper_village()
        State.rails:feast_start()
      sp:finish()
    end,
  },
}
