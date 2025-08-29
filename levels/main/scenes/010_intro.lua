local api = require("engine.tech.api")
local screenplayer = require("engine.tech.screenplayer")


return {
  _010_intro = {
    characters = {
      player = {},
      khaned = {},
    },

    start_predicate = function(self, dt, ch)
      return State.player
    end,

    run = function(self, ch)
      local player = screenplayer.new("assets/screenplay/010_intro.ms", ch)
        player:lines()
        local options = player:start_options()
        for _ = 1, 3 do
          local n = api.options(options, true)
          player:start_option(n)
            player:lines()
          player:finish_option()
        end
        player:finish_options()
      player:finish()
    end,
  },
}
