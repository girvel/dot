local item = require("engine.tech.item")
local interactive = require("engine.tech.interactive")


return {
  --- @type scene
  _139_exiting_ruins = {
    characters = {
      player = {},
      likka = {optional = true},
      temple_exit = {},
    },

    on_add = function(self, ch, ps)
      State:add(ch.temple_exit, interactive.mixin(), {name = "склон"})
      item.set_cue(ch.temple_exit, "highlight", false)
    end,

    start_predicate = function(self, dt, ch, ps)
      return ch.temple_exit.interacted_by == ch.player
    end,

    run = function(self, ch, ps)
      
    end,
  },
}
