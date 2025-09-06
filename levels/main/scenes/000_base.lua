local level = require("engine.tech.level")
local api = require("engine.tech.api")
local async = require("engine.tech.async")
local sound = require "engine.tech.sound"
local health = require("engine.mech.health")


return {
  init = {
    enabled = true,
    start_predicate = function(self, dt) return true end,

    run = function(self)
      State.quests.order = {"feast"}
      State.hostility:set("invaders", "village", "enemy")
      State.hostility:set("player", "village", "ally")
      State.hostility:set("player", "khaned", "ally")
      State.hostility:set("player", "likka", "ally")
    end,
  },

  init_debug = {
    enabled = true,
    start_predicate = function(self, dt) return State.debug end,

    run = function(self)
      State.hostility:set("ai_1", "player", "enemy")
    end,
  },
}
