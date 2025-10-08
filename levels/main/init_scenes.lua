local async = require("engine.tech.async")
local api = require("engine.tech.api")
local health = require("engine.mech.health")
local tcod   = require("engine.tech.tcod")
local item   = require("engine.tech.item")
local items_entities = require("levels.main.palette.items_entities")
local bad_trip       = require("engine.tech.shaders.bad_trip")
local actions        = require("engine.mech.actions")
local perks          = require("engine.mech.perks")


return {
  --- @type scene|table
  init = {
    enabled = true,
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
      State.hostility:set("invaders", "village", "enemy")

      State.hostility:set("boars", "village", "enemy")
      State.hostility:set("village", "boars", "enemy")
      State.hostility:set("boars", "player", "enemy")
      State.hostility:set("player", "boars", "enemy")

      State.hostility:set("player", "village", "ally")
      State.hostility:set("player", "khaned", "ally")
      State.hostility:set("player", "likka", "ally")

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
  init_debug = {
    enabled = true,
    start_predicate = function(self, dt) return State.debug end,
    in_combat_flag = true,

    run = function(self)
      coroutine.yield()  -- race condition safety
      State.player.inventory.body = State:add(items_entities.invader_armor())
      State.player.inventory.head = State:add(items_entities.invader_helmet())
    end,
  },

  --- @type scene|table
  cp1 = {
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

      api.assert_position(State.player, State.runner.positions.cpt, true)
      item.give(State.player, State:add(items_entities.axe()))
      item.give(State.player, State:add(items_entities.shield()))

      State.runner.scenes._100_saving_likka.enabled = false
    end,
  },
}
