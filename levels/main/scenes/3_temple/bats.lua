local health = require("engine.mech.health")
local wildlife = require "levels.main.palette.wildlife"


local BATS_NS = {7, 5, 6, 11}

return {
  --- @type scene
  bats = {
    enabled = true,
    mode = "sequential",

    characters = {
      player = {},
    },

    _ps = {},

    on_add = function(self, ch, ps)
      for name, p in pairs(ps) do
        if name:starts_with("bats_") then
          self._ps[tonumber(name:sub(6))] = p
        end
      end
    end,

    start_predicate = function(self, dt, ch, ps)
      for i, p in pairs(self._ps) do
        if (ch.player.position - p):abs2() <= 3 then
          return i, p
        end
      end
    end,

    run = function(self, ch, ps, i, activated_p)
      self._ps[i] = nil
      if Table.count(self._ps) == 0 then
        self.enabled = false
      end

      local counter = 0
      local to_combat = {ch.player}
      local bfs = State.grids.solids:bfs(activated_p)
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

          if counter == BATS_NS[i] then break end
        end

        ::continue::
      end

      if i == 1 then
        health.damage(ch.player, 1)
      end

      coroutine.yield()
      State:start_combat(to_combat)  -- to prevent aggression FX
      if State.period:once(self, "enable_healing_scene") then
        State.runner.scenes._110_healing_player_starter.enabled = true
      end
    end,
  },
}
