local screenplay = require("engine.tech.screenplay")


return {
  _011_exiting_house = {
    characters = {
      player = {},
    },

    --- @param self scene
    --- @param dt number
    --- @param ch rails_characters
    start_predicate = function(self, dt, ch)
      return ch.player.position == Runner.positions.start_location_exit
    end,

    --- @param self scene
    --- @param ch rails_characters
    run = function(self, ch)
      if ch.player.inventory.hand
        or ch.player.inventory.offhand and ch.player.inventory.offhand.tags.ranged
      then return end
      local sp = screenplay.new("assets/screenplay/011_exiting_house.ms", ch)
        sp:lines()
      sp:finish()
    end,
  },
}
