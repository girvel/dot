local iteration = require("engine.tech.iteration")
local items_entities = require "levels.main.palette.items_entities"


return {
  loc_1_drop_knife = {
    --- @param self scene
    --- @param dt number
    start_predicate = function(self, dt)
      return not State:exists(Runner.entities.knife_chest)
    end,

    --- @param self scene
    run = function(self)
      local placement
      for d in iteration.rhombus(5) do
        local p = d:add_mut(Runner.entities.knife_chest.position)
        if not State.grids.solids:slow_get(p, true) and not State.grids.items:slow_get(p) then
          placement = p
          break
        end
      end

      State:add(items_entities.knife(), {position = placement, grid_layer = "items"})
    end,
  },
}
