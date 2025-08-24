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


local solids_entities = {}
local modname = ...

--- @class player: base_player

solids_entities.player = function()
  local result = Table.extend(base_player(), humanoid.mixin(), {
    inventory = {
      hand = items.knife(),
    },
    base_abilities = abilities.new(10, 10, 10, 10, 10, 10),  -- NEXT!
    perks = {
      {
        modify_resources = function(self, entity, resources, rest_type)
          if rest_type == "short" or rest_type == "long" then
            resources.action_surge = (resources.action_surge or 0) + 1
          end
          return resources
        end,

        modify_attack_roll = function(self, entity, roll, slot)
          return roll + 2  -- proficiency
        end,
      }
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
    ai = {
      control = function(entity, dt)
        while Period(.5, modname .. "::attack", entity) do
          actions.hand_attack:act(entity)
        end
        -- if not State.combat then
        --   State.combat = combat.new({entity, State.player})
        --   coroutine.yield()
        -- end

        -- if Random.chance(1 / 60) then
        --   actions.move(Random.choice(Vector.directions)):act(entity)
        -- end
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
