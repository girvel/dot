local level = require("engine.tech.level")
local api = require("engine.tech.api")
local screenplay = require("engine.tech.screenplay")


return {
  --- @type scene|table
  _030_ceremony = {
    enabled = true,
    mode = "sequential",

    characters = {
      player = {},
      khaned = {},
      likka = {},
      red_priest = {},
    },

    --- @param self scene|table
    --- @param dt number
    --- @param ch rails_characters
    start_predicate = function(self, dt, ch)
      return (State.rails.runner.positions.ceremony_start - ch.player.position):abs2() <= 2
    end,

    _first_time = true,

    --- @param self scene|table
    --- @param ch rails_characters
    run = function(self, ch)
      local sp = screenplay.new("assets/screenplay/030_ceremony.ms", ch)
        while ch.likka.position ~= Runner.positions.ceremony_likka
          or ch.khaned.position ~= Runner.positions.ceremony_khaned
          or ch.red_priest.position ~= Runner.positions.ceremony_red_priest
        do
          coroutine.yield()
          if Period(15, self, "start") then
            level.unsafe_move(ch.likka, Runner.positions.ceremony_likka)
            level.unsafe_move(ch.khaned, Runner.positions.ceremony_khaned)
            level.unsafe_move(ch.red_priest, Runner.positions.ceremony_red_priest)
            break
          end
        end

        sp:start_branches()
        if ch.player.inventory.hand.bonus or ch.player.inventory.offhand.bonus then
          api.move_camera(ch.khaned.position):await()
          if self._first_time then
            sp:start_branch(1)
              sp:lines()
              ch.player:animate("gesture")
              sp:lines()
            sp:finish_branch()
            self._first_time = false
          else
            sp:start_branch(2)
              sp:lines()
            sp:finish_branch()
          end
          api.travel_scripted(ch.player, ch.player.position + Vector.up * 3):await()
          return
        end
        sp:finish_branches()
        self.enabled = nil
      sp:finish()
    end,
  },
}
