return {
  init = {
    start_predicate = function(self, dt) return true end,

    run = function(self)
    end,
  },

  init_debug = {
    start_predicate = function(self, dt) return State.debug end,

    run = function(self)
      State.hostility:set("test_enemy", "player", true)
      State.hostility:set("player", "test_enemy", true)
    end,
  },
}
