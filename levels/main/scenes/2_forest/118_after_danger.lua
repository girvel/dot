local async = require("engine.tech.async")
local api = require("engine.tech.api")
local core = require("levels.main.core")
local screenplay = require("engine.tech.screenplay")


return {
  --- @type scene
  _118_after_danger = {
    characters = {
      likka = {},
      player = {},
    },

    start_predicate = function(_self, _dt, _ch, _ps)
      return true
    end,

    run = function(_self, ch, _ps)
      local sp = screenplay.new("assets/screenplay/118_after_danger.ms", ch)
        core.bring_likka()

        api.rotate(ch.likka, ch.player)
        sp:lines()

        api.rotate(ch.player, ch.likka)
        sp:start_branches()
          if ch.player:ability_check("medicine", 8) then
            sp:start_branch(1)
              sp:lines()
            sp:finish_branch()
          end

          sp:start_branch(State.rails.fought_skeleton_group and 2 or 3)
            sp:lines()
          sp:finish_branch()
        sp:finish_branches()

        sp:lines()

        async.sleep(2)
        sp:lines()

        sp:start_single_branch()
          if ch.player:ability_check("history", 12) then
            sp:lines()
          end
        sp:finish_single_branch()

        sp:lines()

        local n = api.options(sp:start_options())
        sp:start_option(n)
          if n == 2 then
            State.rails:empathy_lower()
          else
            sp:lines()
          end
        sp:finish_option()
        sp:finish_options()

        sp:start_single_branch(State.rails.empathy > 0 and 1 or 2)
          sp:lines()
        sp:finish_single_branch()

        async.sleep(1.5)

        n = api.options(sp:start_options())
        sp:start_option(n)
          sp:lines()
          if n == 1 then
            n = api.options(sp:start_options())
            sp:start_option(n)
              if n == 1 then
                sp:lines()
              end
            sp:finish_option()
            sp:finish_options()
          end
        sp:finish_option()
        sp:finish_options()

        State.rails:empathy_finalize()
      sp:finish()
    end,
  },
}
