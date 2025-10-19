local shadows = require("levels.main.palette.shadows")
local async = require("engine.tech.async")
local api = require("engine.tech.api")
local health = require("engine.mech.health")
local tcod   = require("engine.tech.tcod")
local item   = require("engine.tech.item")
local items_entities = require("levels.main.palette.items_entities")
local bad_trip       = require("engine.tech.shaders.bad_trip")
local actions        = require("engine.mech.actions")
local perks          = require("engine.mech.perks")


local hostile = function(a, ...)
  for i = 1, select("#", ...) do
    local b = select(i, ...)
    State.hostility:set(a, b, "enemy")
    State.hostility:set(b, a, "enemy")
  end
end

local ally = function(a, ...)
  for i = 1, select("#", ...) do
    local b = select(i, ...)
    State.hostility:set(a, b, "ally")
    State.hostility:set(b, a, "ally")
  end
end

return {
  --- @type scene|table
  init = {
    enabled = true,
    mode = "once",
    start_predicate = function(self, dt) return State.is_loaded end,

    run = function(self)
      do
        local misses = {}
        local updated_n = 0
        for entity in pairs(State._entities) do
          if entity._vision_invisible_flag then
            local target = State.grids.solids:slow_get(entity.position)
            if target then
              target.transparent_flag = nil
              updated_n = updated_n + 1
            else
              table.insert(misses, tostring(entity.position))
            end
            State:remove(entity)
          end
        end

        if #misses > 0 then
          Log.warn("Vision blocker misses: %s", table.concat(misses, ", "))
        end

        tcod.snapshot(State.grids.solids):update_transparency()
        Log.info("Blocked vision for %s cells", updated_n)
      end

      State.quests.order = {"seekers", "feast"}

      hostile("predators", "player", "likka", "khaned")
      ally("player", "khaned", "village")

      State.hostility:set("player", "likka", "ally")
      -- player is likka's ally only inside the temple

      health.set_hp(State.player, State.player:get_max_hp() - 2)

      for _, scene in pairs(State.args.enable_scenes) do
        if scene:starts_with("cp") then
          return
        end
      end

      State.rails:winter_init()
      State.rails:location_intro()
    end,
  },

  --- @type scene|table
  init_shadows = {
    enabled = true,
    mode = "once",
    start_predicate = function(self, dt)
      return true
    end,

    run = function(self)
      coroutine.yield()  -- wait for checkpoints

      local size = State.level.grid_size

      --- @type vector[]
      local trees do
        trees = {}
        for x = 1, size.x do
        for y = 1, size.y do
          local e = State.grids.solids:unsafe_get(x, y)
          if e and e._tree_flag then
            table.insert(trees, e.position)
          end
        end
        end
      end

      local R1 = 4
      local R2 = 2
      local R1_SQ = R1^2
      local R2_SQ = R2^2

      local shadow_values = Grid.new(size, function() return 0 end)
      for _, tree in ipairs(trees) do
        for x = -R1, R1 do
        for y = -R1, R1 do
          local p = V(x, y)
          local d_sq = p:square_abs() + math.random(-2, 2)
          local value
          if d_sq <= R2_SQ then
            value = 4
          elseif d_sq <= R1_SQ then
            value = 2
          else
            value = 0
          end
          p:add_mut(tree)
          if shadow_values:can_fit(p) then
            shadow_values[p] = math.max(value, shadow_values[p])
          end
        end
        end
      end

      for x = 1, size.x do
      for y = 1, size.y do
        local n = shadow_values:unsafe_get(x, y)
        if n > 0 and not State.grids.shadows:unsafe_get(x, y) then
          State:add(shadows[16 - n](), {position = V(x, y), grid_layer = "shadows"})
        end
      end
      end
    end,
  },

  --- @type scene|table
  init_debug = {
    enabled = true,
    mode = "once",
    start_predicate = function(self, dt) return State.debug end,
    in_combat_flag = true,

    run = function(self)
      coroutine.yield()  -- race condition safety
      State.player.inventory.body = State:add(items_entities.invader_armor())
      State.player.inventory.head = State:add(items_entities.invader_helmet())
    end,
  },

  --- @type scene|table
  test_scrolling = {
    characters = {
      player = {},
    },

    start_predicate = function(self, dt, ch, ps)
      return true
    end,

    run = function(self, ch, ps)
      api.line(nil, "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
    end,
  },

  --- @type scene|table
  cp1 = {
    mode = "once",
    start_predicate = function(self, dt)
      return true
    end,

    run = function(self)
      State.rails:winter_init()
      State.rails:location_upper_village(true)
      State.rails:feast_start()
      api.assert_position(State.player, State.runner.positions.cp1, true)
      item.give(State.player, State:add(items_entities.short_bow()))
    end,
  },

  --- @type scene|table
  cp2 = {
    mode = "once",
    start_predicate = function(self, dt)
      return true
    end,

    run = function(self)
      State.rails:winter_init()
      State.rails:winter_end()
      State.rails:location_forest(true)
      State.rails:feast_start()
      State.rails:feast_end()
      State.rails:seekers_start()

      api.assert_position(State.player, State.runner.positions.cp2, true)
      item.give(State.player, State:add(items_entities.axe()))
      item.give(State.player, State:add(items_entities.shield()))
    end,
  },

  --- @type scene|table
  cpt = {
    mode = "once",
    in_combat_flag = true,

    start_predicate = function(self, dt)
      return true
    end,

    run = function(self)
      State.rails:winter_init()
      State.rails:winter_end()
      State.rails:location_forest(true)
      State.rails:feast_start()
      State.rails:feast_end()
      State.rails:seekers_start()
      State.rails:temple_enter()
      State.rails:empathy_start_conversation()

      api.assert_position(State.player, State.runner.positions.cpt, true)
      item.give(State.player, State:add(items_entities.axe()))
      item.give(State.player, State:add(items_entities.shield()))

      State.runner.scenes._100_saving_likka.enabled = false
    end,
  },

  --- @type scene|table
  cpt2 = {
    mode = "once",
    in_combat_flag = true,

    start_predicate = function(self, dt)
      return true
    end,

    run = function(self)
      State.rails:winter_init()
      State.rails:winter_end()
      State.rails:location_forest(true)
      State.rails:feast_start()
      State.rails:feast_end()
      State.rails:seekers_start()
      State.rails:temple_enter()
      State.rails:empathy_start_conversation()

      local ch = State.runner.entities
      local ps = State.runner.positions

      api.assert_position(ch.player, ps.cpt2, true)
      api.assert_position(ch.likka, ps.cpt2 + Vector.right, true)
      item.give(ch.player, State:add(items_entities.axe()))
      item.give(ch.player, State:add(items_entities.shield()))

      health.damage(ch.cpt2_cobweb, 1)

      State.runner.scenes._100_saving_likka.enabled = false
    end,
  },
}
