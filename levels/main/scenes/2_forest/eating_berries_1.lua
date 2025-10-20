local screenplay = require("engine.tech.screenplay")
local api = require("engine.tech.api")


return {
  --- @type scene
  eating_berries_1 = {
    characters = {
      player = {},
    },

    --- @param self scene
    --- @param dt number
    --- @param ch runner_characters
    --- @param ps runner_positions
    start_predicate = function(self, dt, ch, ps)
      return false  -- manually triggered scene
    end,

    --- @param self scene
    --- @param ch runner_characters
    --- @param ps runner_positions
    run = function(self, ch, ps)
      local sp = screenplay.new("assets/screenplay/eating_berries_1.ms", ch)
        sp:lines()

        if api.options(sp:start_options()) ~= 1 then return false end
        sp:finish_options()

        sp:start_branches()
          local branch
          if ch.player:ability_check("survival", 16) then
            branch = 1
          elseif ch.player:ability_check("medicine", 12) then
            branch = 2
          else
            branch = 3
          end
          sp:start_branch(branch)
            sp:lines()
          sp:finish_branch()
        sp:finish_branches()

        if api.options(sp:start_options()) ~= 5 then return false end
        sp:finish_options()

        sp:lines()

        if api.options(sp:start_options()) ~= 1 then return false end
        sp:finish_options()

        sp:lines()
      sp:finish()
      return true
    end,
  },
}
