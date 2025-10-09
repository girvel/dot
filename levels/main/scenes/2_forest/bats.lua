local health = require("engine.mech.health")
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
      local to_combat = {ch.player}
      local bfs = State.grids.solids:bfs(ch.player.position)
      bfs()

      for p, e in bfs do
        if e then
          bfs:discard()
          goto continue
        end

        if Random.chance(.3) then
          e = State:add(wildlife.bat(), {position = p, grid_layer = "solids"})
          e:animate("appear")
          table.insert(to_combat, e)
          counter = counter + 1

          if counter == 7 then break end
        end

        ::continue::
      end
      health.damage(ch.player, 1)
      coroutine.yield()
      State:start_combat(to_combat)  -- to prevent aggression FX
    end,
  },
}
