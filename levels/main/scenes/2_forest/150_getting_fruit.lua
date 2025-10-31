local interactive = require("engine.tech.interactive")
local api = require("engine.tech.api")
local screenplay = require("engine.tech.screenplay")


return {
  --- @type scene
  _150_getting_fruit = {
    enabled = true,

    characters = {
      player = {},
    },

    on_add = function(self, ch, ps)
      State:add(ch.likka_fruit, interactive.mixin(function()
        State.rails:fruit_take_likkas()
      end))
    end,

    start_predicate = function(self, dt, ch, ps)
      return State.rails.fruit_source
    end,

    --- @param ch runner_characters
    --- @param ps runner_positions
    play = function(self, ch, ps)
      local sp = screenplay.new("assets/screenplay/150_getting_fruit.ms", ch)
        sp:lines()

        if api.options(sp:start_options()) ~= 3 then return end
        sp:finish_options()

        sp:start_single_branch(State.rails.fruit_source == "found" and 1 or 2)
          sp:lines()
        sp:finish_single_branch()

        if api.options(sp:start_options()) ~= 5 then return end
        sp:finish_options()

        sp:lines()
        sp:start_single_branch()
        if State.rails.ate_rotten_fruit then
          sp:lines()
        end
        sp:finish_single_branch()
        sp:lines()

        if api.options(sp:start_options()) ~= 2 then return end
        sp:finish_options()

        sp:lines()
        -- SOUND eating
        sp:lines()
        -- SOUND regret
        sp:lines()

        State.rails:fruit_eat()
      sp:finish()
      return true
    end,

    run = function(self, ch, ps)
      if self:play(ch, ps) then
        api.autosave("Фрукт съеден")
      end
    end,
  },
}
