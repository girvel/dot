local screenplay = require("engine.tech.screenplay")


return {
  _018_getting_sword = {
    enabled = true,

    characters = {
      player = {},
      plus_one_sword = {},
    },

    --- @param self scene
    --- @param dt number
    --- @param ch rails_characters
    start_predicate = function(self, dt, ch)
      return ch.player.inventory.hand == ch.plus_one_sword
    end,

    --- @param self scene
    --- @param ch rails_characters
    run = function(self, ch)
      local sp = screenplay.new("assets/screenplay/018_getting_sword.ms", ch)
        sp:lines()
      sp:finish()
    end,
  },
}
