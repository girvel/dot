local api = require("engine.tech.api")
local item = require("engine.tech.item")
local screenplay = require("engine.tech.screenplay")


return {
  --- @type scene
  _138_noticing_exit = {
    enabled = true,
    characters = {
      player = {},
      likka = {optional = true},
      temple_exit = {},
    },

    start_predicate = function(self, dt, ch, ps)
      return api.distance(ch.player, ch.temple_exit) <= 6
    end,

    run = function(self, ch, ps)
      local sp = screenplay.new("assets/screenplay/138_noticing_exit.ms", ch)
        sp:start_single_branch(State:exists(ch.likka) and 1 or 2)
          sp:lines()
        sp:finish_single_branch()
        item.set_cue(ch.temple_exit, "highlight", true)
      sp:finish()
    end,
  },
}
