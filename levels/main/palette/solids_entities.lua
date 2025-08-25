local level = require("engine.tech.level")
local combat = require("engine.state.combat")
local base_player = require("engine.state.player").base
local _common     = require("levels.main.palette._common")
local humanoid    = require("engine.mech.humanoid")
local creature    = require("engine.mech.creature")
local actions     = require("engine.mech.actions")
local items = require("levels.main.palette.items_entities")
local abilities = require("engine.mech.abilities")
local health    = require("engine.mech.health")
local fighter   = require("engine.mech.class.fighter")
local async     = require("engine.tech.async")
local class     = require("engine.mech.class")


local solids_entities = {}

--- @class player: base_player

solids_entities.player = function()
  local result = Table.extend(base_player(), humanoid.mixin(), {
    inventory = {
      hand = items.knife(),
    },
    base_abilities = abilities.new(16, 14, 14, 8, 12, 10),
    base_hp = 10,
    level = 2,
    perks = {
      class.skill_proficiency("athletics"),
      fighter.hit_dice,
      fighter.action_surge,
      fighter.second_wind,
    },
  })

  creature.init(result)
  health.set_hp(result, 5)
  return result
end

solids_entities.ai_tester = function()
  local result = Table.extend(humanoid.mixin(), creature.mixin(), {
    codename = "ai_tester",
    base_abilities = abilities.new(10, 14, 10, 10, 10, 10),
    base_hp = 10,
    armor = 10,
    level = 1,
    ai = {
      control = function(entity, dt)
        if not State.combat then
          State.combat = combat.new({entity, State.player})
          return
        end

        actions.hand_attack:act(entity)
        async.sleep(0.5)
      end,
    },
    inventory = {
      offhand = items.knife(),
    },
  })

  creature.init(result)
  return result
end

solids_entities.water = _common.water(Vector.down * .5)

return solids_entities
