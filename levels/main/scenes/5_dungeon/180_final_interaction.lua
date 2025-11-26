local screenplay = require("engine.tech.screenplay")
local api = require("engine.tech.api")


return {
  --- @type scene
  _180_final_interaction = {
    enabled = true,
    characters = {
      player = {},
    },

    start_predicate = function(self, dt, ch, ps)
      return api.distance(ch.player, ps.fi_start) <= 3
    end,

    run = function(self, ch, ps)
      api.travel_scripted(ch.player, ps.fi_start):wait()
      ch.player:rotate(Vector.up)

      local sp = screenplay.new("assets/screenplay/180_final_interaction.ms", ch)
        sp:lines()

        api.fade_out(.5)
        sp:lines()

        -- SOUND ominous

        local n = api.options(sp:start_options())
          if n == 2 then
            sp:start_option(n)
              sp:lines()

              n = api.options(sp:start_options())
                sp:start_option(n)
                  if n == 2 then
                    sp:lines()

                    local check = ch.player:ability_check("athletics", 12)
                    sp:start_single_branch(check and 1 or 2)
                      sp:lines()
                      local running_away = api.travel_scripted(ch.player, ps.fi_away)
                      sp:lines()
                      running_away:wait()
                    sp:finish_single_branch()
                    sp:lines()

                    -- NEXT! block the way back
                  end
                sp:finish_option()
              sp:finish_options()
            sp:finish_option()
          end
        sp:finish_options()

        local fade_in = api.fade_in(.5)
        sp:lines()
        fade_in:wait()
      sp:finish()
    end,
  },
}
