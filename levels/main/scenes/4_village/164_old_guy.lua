local interactive = require("engine.tech.interactive")
local api = require("engine.tech.api")
local screenplay = require("engine.tech.screenplay")


return {
  --- @type scene
  _164_old_guy = {
    enabled = true,
    mode = "sequential",
    characters = {
      old_guy = {},
      player = {},
    },

    on_add = function(self, ch, ps)
      State:add(ch.old_guy, interactive.mixin(), {name = "Шонед"})
    end,

    start_predicate = function(self, dt, ch, ps)
      return ch.old_guy.was_interacted_by == ch.player
    end,

    run = function(self, ch, ps)
      local sp = screenplay.new("assets/screenplay/164_old_guy.ms", ch)
        sp:lines()

        if api.options(sp:start_options()) == 2 then return end
        sp:finish_options()

        sp:lines()

        if api.options(sp:start_options()) == 2 then
          State.runner:remove(self)
          ch.old_guy.interact = nil
          return
        end
        sp:finish_options()

        sp:lines()

        if api.options(sp:start_options()) == 2 then
          State.runner:remove(self)
          ch.old_guy.interact = nil
          return
        end
        sp:finish_options()

        sp:lines()
        State.runner:remove(self)
        ch.old_guy.interact = nil
      sp:finish()
    end,
  },
}
