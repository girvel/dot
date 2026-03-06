local async = require("engine.tech.async")
local screenplay = require("engine.tech.screenplay")
local api = require("engine.tech.api")


return {
  --- @type scene
  _190_getting_out = {
    enabled = true,
    characters = {
      player = {},
    },

    start_predicate = function(self, dt, ch, ps)
      return api.distance(ch.player, ps.go_start) <= 1
    end,

    run = function(self, ch, ps)
      if not State.rails.question_i then return end

      local sp = screenplay.new("assets/screenplay/190_getting_out.ms", ch)
        sp:lines()

        sp:start_single_branch(State.rails.question_i)
          if State.rails.question_i == 5 then
            sp:start_single_branch(State.rails.has_blessing and 2 or 1)
              sp:lines()
            sp:finish_single_branch()
          else
            sp:lines()
          end
        sp:finish_single_branch()

        sp:start_single_branch()
          if State.rails.has_blessing then
            async.sleep(1)
            sp:lines()
          end
        sp:finish_single_branch()
      sp:finish()
    end,
  },
}
