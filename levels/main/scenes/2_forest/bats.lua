local wildlife = require "levels.main.palette.wildlife"


return {
  --- @type scene|table
  bats_1 = {
    enabled = true,
    characters = {
      player = {},
    },

    start_predicate = function(self, dt, ch, ps)
      return (ch.player.position - ps.bats_1):abs2() <= 3
    end,

    run = function(self, ch, ps)
      local counter = 0
      for p in State.grids.solids:find_free_positions(State.player.position) do
        if Random.chance(.3) then
          State
            :add(wildlife.bat(), {position = p, grid_layer = "solids"})
            :animate("appear")
          counter = counter + 1

          if counter == 7 then break end
        end
      end
    end,
  },
}
