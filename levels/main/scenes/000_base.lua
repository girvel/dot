local level = require("engine.tech.level")
local api = require("engine.tech.api")
local async = require("engine.tech.async")
local sound = require "engine.tech.sound"
local health = require("engine.mech.health")
local tcod   = require("engine.tech.tcod")


return {
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
          Log.warn("Vision blocker misses:", table.concat(misses, ", "))
        end

        tcod.snapshot(State.grids.solids):update_transparency()
        Log.info("Blocked vision for", updated_n, "cells")
      end

      State.quests.order = {"feast"}
      State.hostility:set("invaders", "village", "enemy")

      State.hostility:set("predators", "village", "enemy")
      State.hostility:set("village", "predators", "enemy")
      State.hostility:set("predators", "player", "enemy")
      State.hostility:set("player", "predators", "enemy")

      State.hostility:set("player", "village", "ally")
      State.hostility:set("player", "khaned", "ally")
      State.hostility:set("player", "likka", "ally")

      health.set_hp(State.player, State.player:get_max_hp() - 2)
    end,
  },

  init_debug = {
    enabled = true,
    start_predicate = function(self, dt) return State.debug end,

    run = function(self)
    end,
  },

  cp1 = {
    --- @param self scene
    --- @param dt number
    start_predicate = function(self, dt)
      return true
    end,

    --- @param self scene
    run = function(self)
      State.rails:location_upper_village()
    end,
  },
}
