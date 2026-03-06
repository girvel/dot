local api = require("engine.tech.api")
local appearance_editor = require("engine.state.mode.appearance_editor")
local core = require("level.core")
local items_entities = require "level.palette.items_entities"


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

  --- @type scene
  test_scaling = {
    characters = {},

    start_predicate = function(self, dt, ch, ps)
      return true
    end,

    run = function(self, ch, ps)
      State.camera.target_override = setmetatable({}, {
        __index = function(_, index)
          assert(index == "position")
          return State.player.position + V(.5, 0):mul_mut(
            (appearance_editor.w + appearance_editor.padding)
            / State.camera.SCALE
            / Constants.cell_size
          )
        end,
      })

      api.scale(10):wait()
      State.mode:open_menu("appearance_editor")

      while State.mode._mode.type ~= "game" do
        coroutine.yield()
      end
      api.scale():wait()
      State.camera.target_override = nil
    end,
  },
}
