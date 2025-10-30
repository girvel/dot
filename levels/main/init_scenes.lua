local api = require("engine.tech.api")
local health = require("engine.mech.health")
local item   = require("engine.tech.item")
local items_entities = require("levels.main.palette.items_entities")


return {
  --- @type scene
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

  --- @type scene
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

  --- @type scene
  cp2 = {
    mode = "once",
    start_predicate = function(self, dt)
      return true
    end,

    run = function(self)
    end,
  },

  --- @type scene
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
      item.give(State.player, State:add(items_entities.small_shield()))

      State.runner.scenes._100_saving_likka.enabled = false
    end,
  },

  --- @type scene
  cpt2 = {
    mode = "once",
    in_combat_flag = true,

    start_predicate = function(self, dt)
      return true
    end,

    run = function(self)
    end,
  },

  --- @type scene
  cpt3 = {
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
      State.rails:empathy_finalize()

      local ch = State.runner.entities
      local ps = State.runner.positions

      api.assert_position(ch.player, ps.cpt3, true)
      api.assert_position(ch.likka, ps.cpt3 + Vector.right, true)
      item.give(ch.player, State:add(items_entities.axe()))
      item.give(ch.player, State:add(items_entities.small_shield()))

      health.damage(ch.cpt2_cobweb, 1)

      State.runner.scenes._100_saving_likka.enabled = false
    end,
  },
}
