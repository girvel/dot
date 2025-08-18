local level = require("engine.tech.level")
local combat = require("engine.state.combat")
local base_player = require("engine.state.player").base
local animated    = require("engine.tech.animated")
local shaders     = require("engine.tech.shaders")


local solids_entities = {}

--- @class player: base_player

solids_entities.player = function()
  return Table.extend(base_player(), {
    transparent_flag = true,
    sprite = {
      type = "image",
      image = love.graphics.newImage("engine/assets/sprites/moose_dude.png"),
    },
  })
end

solids_entities.ai_tester = function()
  return {
    codename = "ai_tester",
    transparent_flag = true,
    sprite = {
      type = "image",
      image = love.graphics.newImage("engine/assets/sprites/moose_dude.png"),
    },
    ai = {
      run = function(entity, dt)
        -- if not State.combat then
        --   State.combat = combat.new({entity, State.player})
        --   coroutine.yield()
        -- end

        if Random.chance(1 / 60) then
          level.safe_move(entity, entity.position + Random.choice(Vector.directions))
        end
      end,
    },
  }
end

solids_entities.water = function()
  local result = Table.extend({
    transparent_flag = true,
    low_flag = true,
    water_velocity = Vector.up * 4,
    shader = shaders.water("assets/sprites/palette.png", 39),
  }, animated.mixin("assets/sprites/animations/water"))

  return result
end

return solids_entities
