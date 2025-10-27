local core = require("levels.main.core")
local screenplay = require("engine.tech.screenplay")


return {
  --- @type scene
  _120_kaledei = {
    enabled = true,
    characters = {
      likka = {optional = true},
      player = {},
      sign_kaledei = {},
    },

    on_add = function(self, ch, ps)
      core.activator(ch.sign_kaledei, "табличка")
    end,

    start_predicate = function(self, dt, ch, ps)
      return ch.sign_kaledei.was_interacted_by == State.player
    end,

    run = function(self, ch, ps)
      ch.sign_kaledei.interact = nil
      local sp = screenplay.new("assets/screenplay/120_kaledei.ms", ch)
        sp:lines()

        sp:start_single_branch()
          if State:exists(ch.likka) then
            sp:lines()
          end
        sp:finish_single_branch()
      sp:finish()
    end,
  },
}
