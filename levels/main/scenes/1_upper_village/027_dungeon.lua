local api = require("engine.tech.api")
local health = require("engine.mech.health")
local async = require("engine.tech.async")
local actions = require("engine.mech.actions")
local screenplay = require("engine.tech.screenplay")


return {
  _027_dungeon = {
    enabled = true,

    characters = {
      player = {},
    },

    mode = "sequential",

    --- @param self scene|table
    --- @param dt number
    --- @param ch rails_characters
    start_predicate = function(self, dt, ch)
      return ch.player.position == State.rails.runner.positions.dungeon_entrance_1
        or ch.player.position == State.rails.runner.positions.dungeon_entrance_2
        or ch.player.position == State.rails.runner.positions.dungeon_entrance_3
    end,

    first_time = true,

    --- @param self scene|table
    --- @param ch rails_characters
    run = function(self, ch)
      local sp = screenplay.new("assets/screenplay/027_dungeon.ms", ch)
        sp:lines()

        if not self.first_time then
          actions.move(Vector.down):act(ch.player)
          return
        else
          self.first_time = false
        end

        sp:lines()

        local n = api.options(sp:start_options())
        sp:finish_options()

        if n ~= 3 then
          actions.move(Vector.down):act(ch.player)
          return
        end

        actions.move(Vector.up):act(ch.player)
        async.sleep(.5)

        actions.move(Vector.down):act(ch.player)
        async.sleep(.5)

        sp:lines()
        if ch.player.hp > 1 then
          health.damage(ch.player, 1)
        end

        sp:lines()
        actions.move(Vector.down):act(ch.player)
      sp:finish()
    end,
  },
}
