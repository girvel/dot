local level = require("engine.tech.level")
local combat = require("engine.state.combat")
local base_player = require("engine.state.player").base
local animated    = require("engine.tech.animated")


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
  return Table.extend({
    transparent_flag = true,
    shader = {
      love_shader = love.graphics.newShader [[
        uniform bool reflects;
        uniform Image reflection;

        vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
        {
          vec4 it = Texel(tex, texture_coords);
          if (!reflects) return it;
          texture_coords.y = 1 - texture_coords.y;
          vec4 it2 = Texel(reflection, texture_coords);
          if (it2.a == 0) return it;
          return it2;
        }
      ]],

      preprocess = function(self, entity, dt)
        local image = self:_get_reflection_image(entity)
        self.love_shader:send("reflects", image ~= nil)
        if not image then return end
        self.love_shader:send("reflection", image)
      end,

      _get_reflection_image = function(_, entity)
        local reflected = State.grids.solids:safe_get(entity.position + Vector.up)
        if not reflected then return nil end
        return reflected.sprite.image
      end
    },
  }, animated.mixin("assets/sprites/animations/water"))
end

return solids_entities
