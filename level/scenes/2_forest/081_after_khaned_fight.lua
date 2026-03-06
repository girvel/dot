local async = require("engine.tech.async")
local screenplay = require("engine.tech.screenplay")
local api  = require("engine.tech.api")


return {
  --- @type scene
  _081_after_khaned_fight = {
    characters = {
      player = {},
      khaned = {},
      khaned_fruit = {},
    },

    player_was_attacking = true,
    path_blocker = nil,

    start_predicate = function(self, dt, ch, ps)
      return not State.combat
    end,

    run = function(self, ch, ps)
      State:remove(self.path_blocker)
      local sp = screenplay.new("assets/screenplay/081_after_khaned_fight.ms", ch)
        sp:start_single_branch(self.player_was_attacking and 1 or 2)
          sp:lines()
        sp:finish_single_branch()

        ch.khaned:animate()

        sp:lines()

        if ch.player.position == ps.path_blocker + Vector.up then
          api.travel_scripted(ch.player, ch.player.position + Vector.left):wait()
        end

        api.travel_scripted(ch.khaned, ch.khaned_fruit.position):wait()
        ch.khaned:animate("interact"):wait()
        State:remove(ch.khaned_fruit)

        async.sleep(.3)
        api.fast_travel(ch.khaned, ps.sk_khaned_ft, ps.feast_sac_3):wait()
        State.rails:khaned_leaves()
      sp:finish()
    end,
  },
}
