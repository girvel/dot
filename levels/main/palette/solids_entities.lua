local level = require("engine.tech.level")


local solids_entities = {}

solids_entities.player = function()
  return {
    codename = "player",
    player_flag = true,
    transparent_flag = true,
    fov_r = 15,
    sprite = {
      type = "image",
      image = love.graphics.newImage("engine/assets/sprites/moose_dude.png"),
    },
  }
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
        if Random.chance(1 / 60) then
          level.safe_move(entity, entity.position + Random.choice(Vector.directions))
        end
      end,
    },
  }
end

return solids_entities
