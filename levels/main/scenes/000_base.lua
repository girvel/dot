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
    end,
  },
}
