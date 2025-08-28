local async = require("engine.tech.async")
local sound = require "engine.tech.sound"
local health = require("engine.mech.health")


return {
  init = {
    start_predicate = function(self, dt) return true end,

    run = function(self)
    end,
  },

  init_debug = {
    start_predicate = function(self, dt) return State.debug end,

    run = function(self)
      State.hostility:set("test_enemy_1", "test_enemy_2", true)
      State.hostility:set("test_enemy_2", "test_enemy_1", true)
      State.hostility:set("test_enemy_2", "player", true)

      while not State.player do coroutine.yield() end

      Log.trace(State.rails.runner.positions, State.rails.runner.entities)
    end,
  },
}
