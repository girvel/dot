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
  local result = Table.extend({
    transparent_flag = true,
    low_flag = true,
    water_velocity = Vector.up * 4,
    shader = {
      _offset = Vector.zero,  -- TODO reuse shaders
      love_shader = love.graphics.newShader [[
        uniform vec4 palette[39];

        vec4 match(vec4 color) {
          float min_distance = 1;
          vec4 closest_color;
          for (int i = 0; i < 39; i++) {
              vec4 current_color = palette[i];
              float distance = (
                  pow(current_color.r - color.r, 2) +
                  pow(current_color.g - color.g, 2) +
                  pow(current_color.b - color.b, 2)
              );

              if (distance < min_distance) {
                  min_distance = distance;
                  closest_color = current_color;
              }
          }
          return closest_color;
        }

        uniform bool reflects;
        uniform Image reflection;
        uniform vec2 offset;

        vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
        {
          texture_coords = mod(texture_coords - offset, 1);
          vec4 it = Texel(tex, texture_coords);
          if (!reflects) return it;
          texture_coords.y = 1 - texture_coords.y;
          vec4 it2 = Texel(reflection, texture_coords);
          if (it2.a == 0) return it;
          return match((it + it2) / 2.5);
        }
      ]],

      preprocess = function(self, entity, dt)
        local offset = ((love.timer.getTime() * entity.water_velocity) % 16):map(math.floor) / 16
        self.love_shader:send("offset", offset)
        local image = self:_get_reflection_image(entity)
        self.love_shader:send("reflects", image ~= nil)
        if not image then return end
        self.love_shader:send("reflection", image)
      end,

      _get_reflection_image = function(_, entity)
        local reflected = State.grids.solids:safe_get(entity.position + Vector.up)
        if not reflected or reflected.low_flag then return nil end
        return reflected.sprite.image
      end
    },
  }, animated.mixin("assets/sprites/animations/water"))

  do
    local palette = {}
    local palette_image_data = love.image.newImageData("assets/sprites/palette.png")
    local w, h = palette_image_data:getDimensions()
    for x = 0, w - 1 do
      for y = 0, h - 1 do
        table.insert(palette, {palette_image_data:getPixel(x, y)})
      end
    end
    result.shader.love_shader:send("palette", unpack(palette))
  end

  return result
end

return solids_entities
