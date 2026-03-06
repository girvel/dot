local screenplay = require("engine.tech.screenplay")


return {
  _011_exiting_house = {
    enabled = true,

    characters = {
      player = {},
    },

    --- @param self scene
    --- @param dt number
    --- @param ch runner_characters
    --- @param ps runner_positions
    start_predicate = function(self, dt, ch, ps)
      return ch.player.position == ps.start_location_exit
    end,

    --- @param self scene
    --- @param ch runner_characters
    --- @param ps runner_positions
    run = function(self, ch, ps)
      if ch.player.inventory.hand
        or ch.player.inventory.offhand and ch.player.inventory.offhand.tags.ranged
      then return end
      local sp = screenplay.new("assets/screenplay/011_exiting_house.ms", ch)
        sp:lines()
      sp:finish()
    end,
  },
}
