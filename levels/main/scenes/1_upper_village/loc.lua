local iteration = require("engine.tech.iteration")
local items_entities = require "levels.main.palette.items_entities"
local api            = require "engine.tech.api"


return {
  loc_1_drop_knife = {
    enabled = true,

    --- @param self scene
    --- @param dt number
    start_predicate = function(self, dt)
      return not State:exists(State.runner.entities.knife_chest)
    end,

    --- @param self scene
    run = function(self)
      local placement
      for d in iteration.rhombus(5) do
        local p = d:add_mut(State.runner.entities.knife_chest.position)
        if not State.grids.solids:slow_get(p, true) and not State.grids.items:slow_get(p) then
          placement = p
          break
        end
      end

      State:add(items_entities.knife(), {position = placement, grid_layer = "items"})
    end,
  },

  weapon_found = {
    enabled = true,

    --- @param self scene|table
    --- @param dt number
    --- @param ch runner_characters
    start_predicate = function(self, dt, ch)
      local hand = State.player.inventory.hand
      local offhand = State.player.inventory.offhand
      return hand and hand.damage_roll or offhand and offhand.damage_roll
    end,

    --- @param self scene|table
    --- @param ch runner_characters
    run = function(self, ch)
      State.rails:feast_weapon_found()
    end,
  },
}
