local core = require("levels.main.core")
local screenplay = require("engine.tech.screenplay")


return {
  --- @type scene
  _124_endildei = {
    enabled = true,
    characters = {
      sign_endildei = {},
      player = {},
    },

    on_add = function(self, ch, ps)
      core.activator(ch.sign_endildei, "табличка")
    end,

    start_predicate = function(self, dt, ch, ps)
      return ch.sign_endildei.was_interacted_by == ch.player
    end,

    run = function(self, ch, ps)
      ch.sign_endildei.interact = nil
      local sp = screenplay.new("assets/screenplay/124_endildei.ms", ch)
        sp:lines()
      sp:finish()
    end,
  },
}
