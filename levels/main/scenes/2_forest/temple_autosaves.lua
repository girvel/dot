local api = require("engine.tech.api")
return {
  --- @type scene
  temple_autosave_1 = {
    enabled = true,
    start_predicate = function(self, dt)
      return State.player.position == State.runner.positions.temple_autosave_1
    end,

    run = function(self)
      api.autosave("Храм -- галерея")
    end,
  },

  --- @type scene
  temple_autosave_2 = {
    enabled = true,
    start_predicate = function(self, dt)
      return State.player.position == State.runner.positions.temple_autosave_2
    end,

    run = function(self)
      api.autosave("Храм -- основной зал")
    end,
  },
}
