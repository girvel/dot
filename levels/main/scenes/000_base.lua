return {
  init = {
    start_predicate = function(self, dt) return true end,

    run = function(self)
      Log.trace("Hello from rails!")
    end,
  },
}
