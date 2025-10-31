local tiles = require("levels.main.palette.tiles")
local interactive = require("engine.tech.interactive")
local solids = require("levels.main.palette.solids")
local api = require("engine.tech.api")
return {
  --- @type scene
  fruit_spawn_init = {
    enabled = true,
    start_predicate = function(self, dt)
      return true
    end,

    run = function(self)
      local accessible = Grid.new(State.level.grid_size)
      local bfs = State.grids.solids:bfs(State.player.position)
      bfs()
      for p, e in bfs do
        if e then
          bfs:discard()
        else
          accessible[p] = true
          State.debug_overlay.points[State.grids.solids:_get_inner_index(unpack(p))] = {
            view = "grid",
            position = p,
            color = Vector.red,
          }
        end
      end

      local n = Table.count(accessible._inner_array)
      Log.info("Initialized fruit spawn grid; %s cells", n)

      local fruit_spawn = State.runner.scenes.fruit_spawn
      fruit_spawn.unseen = accessible
      fruit_spawn.initial_count = n
      fruit_spawn.enabled = true
    end,
  },

  --- @type scene
  fruit_spawn = {
    mode = "sequential",
    boring_flag = true,

    _player_position = nil,
    unseen = nil,
    initial_count = nil,

    start_predicate = function(self, dt)
      local result = State.player.position ~= self._player_position
      self._player_position = State.player.position
      return result
    end,

    run = function(self)
      local new = {}

      for dx = -State.player.fov_r, State.player.fov_r do
      for dy = -State.player.fov_r, State.player.fov_r do
        local p = V(dx, dy):add_mut(State.player.position)
        if api.is_visible(p) and self.unseen[p] then
          self.unseen[p] = nil
          table.insert(new, p)
          State.debug_overlay.points[State.grids.solids:_get_inner_index(unpack(p))] = nil
        end
      end
      end

      if #new == 0 then return end

      --- NEXT sometimes make sure that all the remaining points remain accessible
      local count = Table.count(self.unseen._inner_array)
      Log.trace(count)
      if count == 0 then
        local p = Random.item(new)

        do
          local tile = State.grids.tiles[p]
          if tile.codename ~= "grassl" then
            State:remove(tile)
            State:add(tiles.grassl(), {grid_layer = "tiles", position = p})
          end
        end

        State:add(
          solids.godfruit(),
          {position = p, grid_layer = "solids"},
          interactive.mixin(function(e, other)
            State.rails:fruit_take_own(e)
          end)
        )
        State.runner:remove(self)
      elseif count / self.initial_count <= .2
        and State.period:once(self, "spawn_rotten_fruit")
      then
        Log.warn("Rotten fruit not implemented")
      end
    end,
  },
}
