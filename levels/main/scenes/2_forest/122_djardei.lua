local core = require("levels.main.core")
local screenplay = require("engine.tech.screenplay")


return {
  --- @type scene
  _122_djardei = {
    enabled = true,
    characters = {
      sign_djardei = {},
      player = {},
    },

    on_add = function(self, ch, ps)
      core.activator(ch.sign_djardei, "табличка")
    end,

    start_predicate = function(self, dt, ch, ps)
      return ch.sign_djardei.was_interacted_by == ch.player
    end,

    run = function(self, ch, ps)
      ch.sign_djardei.interact = nil
      local sp = screenplay.new("assets/screenplay/122_djardei.ms", ch)
        sp:lines()
      sp:finish()
    end,
  },
}
