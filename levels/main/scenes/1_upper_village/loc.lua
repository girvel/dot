local core = require("levels.main.core")
local items_entities = require "levels.main.palette.items_entities"


return {
  loc_1_drop_knife = {
    enabled = true,
    in_combat_flag = true,

    --- @param self scene
    --- @param dt number
    start_predicate = function(self, dt)
      return not State:exists(State.runner.entities.knife_chest)
    end,

    --- @param self scene
    run = function(self)
      core.drops(State.runner.entities.knife_chest.position, items_entities.knife())
    end,
  },

  weapon_found = {
    enabled = true,
    in_combat_flag = true,

    --- @param self scene
    --- @param dt number
    --- @param ch runner_characters
    start_predicate = function(self, dt, ch)
      local hand = State.player.inventory.hand
      local offhand = State.player.inventory.offhand
      return hand and hand.damage_roll or offhand and offhand.damage_roll
    end,

    --- @param self scene
    --- @param ch runner_characters
    run = function(self, ch)
      State.rails:feast_weapon_found()
    end,
  },
}
