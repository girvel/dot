local api = require("engine.tech.api")
local screenplayer = require("engine.tech.screenplayer")


return {
  _010_intro = {
    characters = {
      player = {},
      khaned = {},
      likka = {},
    },

    start_predicate = function(self, dt, ch)
      return State.player
    end,

    run = function(self, ch)
      local player = screenplayer.new("assets/screenplay/010_intro.ms", ch)
        ch.khaned:rotate(Vector.up)
        ch.likka:rotate(Vector.up)

        player:lines()
        local options = player:start_options()
        for _ = 1, 3 do
          local n = api.options(options, true)
          player:start_option(n)
            player:lines()
          player:finish_option()
        end
        player:finish_options()
        player:lines()

        api.rotate(ch.likka, ch.khaned)

        player:lines()

        local n = api.options(player:start_options())
          if n == 1 then
            player:start_option(n)
              -- NEXT! branch
            player:finish_option()
          end
        player:finish_options()
      player:finish()
    end,
  },
}
