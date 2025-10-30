local screenplay = require("engine.tech.screenplay")


return {
  --- @type scene
  _101_attacking_likka = {
    enabled = true,
    mode = "sequential",
    characters = {
      likka = {},
      player = {},
    },

    _sub = nil,
    _counter = 0,
    attacked = 0,
    silent = false,

    on_add = function(self, ch, ps)
      self._sub = State.hostility:subscribe(function(attacker, target)
        if attacker == State.player and target == ch.likka then
          self.attacked = self.attacked + 1
          self.silent = not not State.combat
        end
      end)
    end,

    start_predicate = function(self, dt, ch, ps)
      return self.attacked > 0
    end,

    run = function(self, ch, ps)
      self._counter = self._counter + self.attacked
      self.attacked = 0

      if self._counter >= 3 then
        State.hostility:set(ch.likka.faction, State.player.faction, "enemy")
        ch.likka.essential_flag = nil
        self.enabled = false
        State.hostility:unsubscribe(self._sub)
        State:start_combat({ch.player, ch.likka})
        return
      end

      if self.silent then
        return
      end

      local sp = screenplay.new("assets/screenplay/101_attacking_likka.ms", ch)
        sp:start_single_branch(self._counter)
          sp:lines()
        sp:finish_single_branch()
      sp:finish()
    end,
  },
}
