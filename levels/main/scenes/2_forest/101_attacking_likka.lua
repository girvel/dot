local screenplay = require("engine.tech.screenplay")


return {
  --- @type scene|table
  _101_attacking_likka = {
    enabled = true,
    mode = "sequential",
    characters = {
      likka = {},
      player = {},
    },

    _sub = nil,
    _counter = 0,
    attacked = false,

    on_add = function(self, ch, ps)
      self._sub = State.hostility:subscribe(function(attacker, target)
        if attacker == State.player and target == ch.likka then
          self.attacked = true
        end
      end)
    end,

    start_predicate = function(self, dt, ch, ps)
      return self.attacked
    end,

    run = function(self, ch, ps)
      self.attacked = false
      self._counter = self._counter + 1

      local sp = screenplay.new("assets/screenplay/101_attacking_likka.ms", ch)
        if self._counter == 1 or self._counter == 2 then
          sp:start_single_branch(self._counter)
            sp:lines()
          sp:finish_single_branch()
        else
          State.hostility:set(ch.likka.faction, State.player.faction, "enemy")
          ch.likka.essential_flag = nil
        end
      sp:finish()
    end,
  },
}
