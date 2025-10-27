local api = require("engine.tech.api")
local level = require("engine.tech.level")
local screenplay = require("engine.tech.screenplay")
local item = require("engine.tech.item")
local interactive = require("engine.tech.interactive")


return {
  --- @type scene
  _139_exiting_ruins = {
    enabled = true,
    mode = "sequential",

    characters = {
      player = {},
      likka = {optional = true},
      temple_exit = {},
    },

    on_add = function(self, ch, ps)
      State:add(ch.temple_exit, interactive.mixin(), {name = "склон"})
      item.set_cue(ch.temple_exit, "highlight", false)
    end,

    start_predicate = function(self, dt, ch, ps)
      return ch.temple_exit.was_interacted_by == ch.player
    end,

    run = function(self, ch, ps)
      local sp = screenplay.new("assets/screenplay/139_exiting_ruins.ms", ch)
        sp:start_single_branch()
          if not State:exists(ch.likka) then
            if api.options(sp:start_options()) == 1 then
              State.rails:temple_exit()
              self.enabled = false
            end
            sp:finish_options()
            return
          end
        sp:finish_single_branch()

        api.travel_scripted(ch.likka, ch.player.position + Vector.right):wait()
        api.rotate(ch.likka, ch.player)
        State.period:push_key(ch.likka.inventory, "offhand", nil)

        sp:lines()

        if api.options(sp:start_options()) == 2 then
          State.period:pop_key(ch.likka.inventory, "offhand")
          return
        end
        sp:finish_options()

        self.enabled = false
        State.rails:temple_exit()
        api.rotate(ch.player, ch.likka)
        sp:lines()

        api.travel_scripted(ch.likka, ch.temple_exit)

        local n = api.options(sp:start_options())
        sp:start_option(n)
          if n == 1 then
            level.unsafe_move(ch.player, ch.player.position + Vector.up)
            level.unsafe_move(ch.likka, ps.er_up)

            sp:lines()
            sp:start_single_branch()
              if not State.rails.fruit_source then
                sp:lines()
              end
            sp:finish_single_branch()

            sp:lines()

            _ = sp:start_options()
            sp:finish_options()

            State.period:pop_key(ch.likka.inventory, "offhand")
            api.travel_scripted(ch.player, ch.player.position + Vector.left):wait()
            api.fast_travel(ch.likka, ps.er_likka_ft, ps.feast_sac_2):wait()

            State.rails:likka_went_to_village()
          else
            api.travel_scripted(ch.player, ch.player.position + Vector.up):wait()
            sp:lines()
            api.travel_scripted(ch.player, ps.er_player_leaving):wait()

            State.rails:likka_left_in_temple()
          end
        sp:finish_option()
        sp:finish_options()
      sp:finish()
    end,
  },
}
