local screenplay = require "engine.tech.screenplay"
local api        = require "engine.tech.api"
return {
  _020_feast = {
    enabled = true,

    characters = {
      player = {},
    },

    --- @param self scene
    --- @param dt number
    --- @param ch rails_characters
    start_predicate = function(self, dt, ch)
      return ch.player.position >= State.rails.runner.positions.feast_start
        and ch.player.position <= State.rails.runner.positions.feast_finish
    end,

    --- @param self scene
    --- @param ch rails_characters
    run = function(self, ch)
      local sp = screenplay.new("assets/screenplay/020_feast.ms", ch)
        api.travel_scripted(ch.player, State.rails.runner.positions.feast_observe):await()
        api.move_camera(State.rails.runner.positions.feast_camera)

        sp:lines()
      sp:finish()
    end,
  },
}
