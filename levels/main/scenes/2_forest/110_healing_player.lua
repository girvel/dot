local fighter = require("engine.mech.class.fighter")
local screenplay = require("engine.tech.screenplay")
local api = require("engine.tech.api")
local async = require("engine.tech.async")
local actions = require("engine.mech.actions")


return {
  --- @type scene|table
  _110_healing_player_starter = {
    _there_was_combat = false,

    -- should be run every frame including combat => has no characters
    start_predicate = function(self, dt)
      local result = self._there_was_combat
        and not State.combat
        and State.player.hp < State.player:get_max_hp()
      self._there_was_combat = not not State.combat
      return result
    end,

    run = function(self)
      State.runner.scenes._110_healing_player.enabled = true
    end,
  },

  --- @type scene|table
  _110_healing_player = {
    characters = {
      player = {},
      likka = {},
    },

    start_predicate = function(self, dt, ch, ps)
      return true
    end,

    run = function(self, ch, ps)
      local sp = screenplay.new("assets/screenplay/110_healing_player.ms", ch)
        api.rotate(ch.likka, ch.player)
        local p = api.travel_scripted(ch.likka, ch.player.position):next(function()
          api.rotate(ch.player, ch.likka)
        end)

        sp:lines()
        p:wait()

        sp:start_branches()
          if ch.player:ability_check("insight", 12) then
            sp:start_branch(1)
              sp:lines()
            sp:finish_branch()
          end

          if ch.player:ability_check("medicine", 12) then
            sp:start_branch(2)
              sp:lines()
            sp:finish_branch()
          end
        sp:finish_branches()

        local n = api.options(sp:start_options())
          if n == 1 then
            sp:start_option(1)
              local d = State.grids.solids:find_free_position(ch.player.position)
                - ch.player.position
              if d:abs2() == 1 then
                actions.move(d):act(ch.player)
                api.rotate(ch.likka, ch.player)
              end
              sp:lines()

              n = api.options(sp:start_options())
              sp:start_option(n)
                if n == 1 then
                  api.travel_scripted(ch.player, ch.likka.position):wait()
                  api.rotate(ch.likka, ch.player)
                end
                sp:lines()
                if n == 2 then return end
              sp:finish_option()
              sp:finish_options()
            sp:finish_option()
          end
        sp:finish_options()

        sp:lines()

        fighter.hit_dice:_act(ch.player)
        sp:lines()

        n = api.options(sp:start_options())
        sp:start_option(n)
          if n == 1 then
            sp:start_single_branch(ch.player:ability_check("medicine", 12) and 1 or 2)
              sp:lines()
            sp:finish_single_branch()
          else
            sp:lines()
          end
        sp:finish_option()
        sp:finish_options()
      sp:finish()
    end,
  },
}
