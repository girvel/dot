local api = require("engine.tech.api")
local screenplay = require("engine.tech.screenplay")


return {
  --- @type scene
  eating_berries_2 = {
    characters = {
      player = {},
    },

    start_predicate = function(self, dt, ch, ps)
      return false
    end,

    run = function(self, ch, ps)
      local sp = screenplay.new("assets/screenplay/eating_berries_2.ms", ch)
        sp:lines()

        if api.options(sp:start_options()) ~= 3 then return false end
        sp:finish_options()

        sp:lines()

        if api.options(sp:start_options()) ~= 3 then return false end
        sp:finish_options()

        sp:lines()

        if api.options(sp:start_options()) ~= 3 then return false end
        sp:finish_options()

      sp:finish()
      return true
    end,
  },
}
