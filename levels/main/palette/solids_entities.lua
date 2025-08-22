local level = require("engine.tech.level")
local combat = require("engine.state.combat")
local base_player = require("engine.state.player").base
local _common     = require("levels.main.palette._common")
local humanoid    = require("engine.mech.humanoid")
local creature    = require("engine.mech.creature")
local actions     = require("engine.mech.actions")


local solids_entities = {}

--- @class player: base_player

solids_entities.player = function()
  return Table.extend(base_player(), humanoid.mixin())
end

solids_entities.ai_tester = function()
  local result = Table.extend(humanoid.mixin(), creature.mixin(), {
    codename = "ai_tester",
    base_hp = 10,
    ai = {
      control = function(entity, dt)
        -- if not State.combat then
        --   State.combat = combat.new({entity, State.player})
        --   coroutine.yield()
        -- end

        -- if Random.chance(1 / 60) then
        --   actions.move(Random.choice(Vector.directions)):act(entity)
        -- end
      end,
    },
  })

  creature.init(result)
  return result
end

solids_entities.water = _common.water(Vector.down * .5)

return solids_entities
