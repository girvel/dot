local core = require("levels.main.core")
local health = require("engine.mech.health")
local screenplay = require("engine.tech.screenplay")
local api = require("engine.tech.api")


return {
  --- @type scene
  _135_likka_finds_fruit = {
    enabled = true,
    characters = {
      player = {},
      likka = {},
      likka_fruit = {},
    },

    start_predicate = function(self, dt, ch, ps)
      return api.is_visible(ch.likka_fruit) and api.distance(ch.likka_fruit, ch.player) <= 10
    end,

    run = function(self, ch, ps)
      local sp = screenplay.new("assets/screenplay/135_likka_finds_fruit.ms", ch)
        core.bring_likka()

        local likka_runs = api.travel_scripted(ch.likka, ch.likka_fruit, 10)
        sp:lines()
        likka_runs:wait()
        ch.likka:animate("interact"):wait()
        State:remove(ch.likka_fruit)

        local ever_had_fruit = not not State.rails.fruit_source
        local options = sp:start_options()
          if ever_had_fruit or api.options(options) == 2 then
            sp:start_option(2)
              sp:start_single_branch()
                if not ever_had_fruit then
                  sp:lines()
                end
              sp:finish_single_branch()

              sp:lines()

              sp:start_single_branch()
                if not ever_had_fruit then
                  sp:lines()
                end
              sp:finish_single_branch()
            sp:finish_option()
            return
          end
        sp:finish_options()

        api.travel_scripted(ch.player, ch.likka):wait()
        sp:lines()

        if api.options(sp:start_options()) == 2 then
          sp:start_option(2)
            sp:lines()
          sp:finish_option()
          return
        end
        sp:finish_options()

        if ch.player:ability_check("athletics", ch.likka:get_roll("acrobatics"):roll()) then
          sp:start_single_branch(1)
            ch.player:animate("offhand_attack")
            sp:lines()

            ch.likka:animate("offhand_attack")
            health.damage(ch.player, 1, true)
            sp:lines()
          sp:finish_single_branch()
        else
          sp:start_single_branch(2)
            sp:lines()

            local p = State.grids.solids:find_free_position(ch.likka.position, 1)
            if p then
              api.travel_scripted(ch.likka, p)
            end

            sp:lines()
          sp:finish_single_branch()
        end
      sp:finish()
    end,
  },
}
