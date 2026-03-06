local poisoned = require("engine.mech.conditions.poisoned")
local api = require("engine.tech.api")
local screenplay = require("engine.tech.screenplay")


return {
  --- @type scene
  _145_rotten_fruit = {
    enabled = true,
    characters = {
      player = {},
      rotten_fruit = {dynamic = true},
    },

    start_predicate = function(self, dt, ch, ps)
      return ch.rotten_fruit.was_interacted_by == ch.player
    end,

    run = function(self, ch, ps)
      ch.rotten_fruit.interact = nil
      State.rails:rotten_fruit_touch()
      local sp = screenplay.new("assets/screenplay/145_rotten_fruit.ms", ch)
        sp:lines()

        if api.options(sp:start_options()) ~= 4 then return end
        sp:finish_options()

        sp:lines()

        if api.options(sp:start_options()) ~= 1 then return end
        sp:finish_options()

        sp:lines()

        if api.options(sp:start_options()) ~= 5 then return end
        sp:finish_options()

        State.rails:rotten_fruit_eat(ch.rotten_fruit)
        sp:lines()

        local success = State.player:saving_throw("con", 15)
        sp:start_single_branch(success and 1 or 2)
          sp:lines()
          if success then
            table.insert(State.player.conditions, poisoned.new(5))
          end
        sp:finish_single_branch()

        sp:lines()
      sp:finish()
    end,
  },
}
