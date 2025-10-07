local level = require("engine.tech.level")
local health = require("engine.mech.health")
local async = require("engine.tech.async")
local api = require("engine.tech.api")
local screenplay = require("engine.tech.screenplay")
local tcod = require("engine.tech.tcod")
local items_entities = require("levels.main.palette.items_entities")


return {
  --- @type scene|table
  _090_random_gatherer = {
    enabled = true,

    characters = {
      player = {},
      gatherer = {},
    },

    on_add = function(self, ch, ps)
      ch.gatherer.inventory.tatoo = State:add(items_entities.gatherer_scar())
      ch.gatherer:rotate(Vector.left)
      ch.gatherer.name = "Собиратель"
    end,

    start_predicate = function(self, dt, ch, ps)
      return (ch.player.position - ch.gatherer.position):abs2() <= 4
        and tcod.snapshot(State.grids.solids):is_visible_unsafe(unpack(ch.gatherer.position))
    end,

    run = function(self, ch, ps)
      local SOCIAL_DC = 16
      local subs = {["ИМЯ"] = "Она"}

      local sp = screenplay.new("assets/screenplay/090_random_gatherer.ms", ch)
        sp:lines()

        api.travel_scripted(ch.player, ps.rg_player):wait()
        api.rotate(ch.player, ch.gatherer)

        sp:start_branches()
          local branch =
            ch.player:ability_check("insight", 8) and 1
            or ch.player:ability_check("stealth", 12) and 2
            or 3

          async.sleep(branch == 2 and 1.5 or .5)
          api.rotate(ch.gatherer, ch.player)

          sp:start_branch(branch)
            sp:lines()
          sp:finish_branch()

          if ch.player:ability_check("perception", SOCIAL_DC) then
            sp:start_branch(4)
              sp:lines()
            sp:finish_branch()
          end
        sp:finish_branches()

        sp:lines()

        sp:start_branches()
          if ch.player:ability_check("religion", 12) then
            sp:start_branch(1)
              sp:lines()
            sp:finish_branch()
          end

          if State.rails.fruit_source then
            sp:start_branch(2)
              sp:lines()
            sp:finish_branch()
          else
            sp:start_branch(3)
              sp:lines()

              sp:start_single_branch(
                State.rails.seen_rotten_fruit and 1
                or State.rails.seen_companion_fruit and 2
                or 3
              )
                sp:lines()
              sp:finish_single_branch()
            sp:finish_branch()
          end
        sp:finish_branches()

        sp:lines()

        sp:start_single_branch(State.rails.fruit_source and 1 or 2)
          sp:lines()
        sp:finish_single_branch()

        if api.options(sp:start_options()) == 2 then return end
        sp:finish_options()

        sp:lines()

        sp:start_single_branch()
        if ch.player:ability_check("insight", SOCIAL_DC) then
          sp:lines()
        end
        sp:finish_single_branch()

        sp:lines()

        sp:start_single_branch()
        if ch.player:ability_check("insight", SOCIAL_DC) then
          sp:lines()
        end
        sp:finish_single_branch()

        sp:lines()

        async.sleep(2)
        sp:lines()

        if api.options(sp:start_options()) == 1 then
          sp:start_option(1)
            sp:start_branches()
              sp:start_branch(ch.player:ability_check("insight", SOCIAL_DC) and 1 or 2)
                sp:lines()
              sp:finish_branch()
              for _ = 1, 3 do
                sp:start_branch(3)
                  sp:lines()

                  if api.options(sp:start_options()) == 2 then return end
                  sp:finish_options()
                sp:finish_branch()
              end
            sp:finish_branches()

            ch.gatherer:rotate(Vector.left)
            sp:lines()
            return
          sp:finish_option()
        end
        sp:finish_options()

        sp:lines()
        sp:start_single_branch()
          if ch.player:ability_check("perception", SOCIAL_DC) then
            sp:lines()
          end
        sp:finish_single_branch()

        if api.options(sp:start_options()) == 2 then return end
        sp:finish_options()

        api.travel_scripted(ch.player, ps.rg_player_close)
        sp:lines()

        sp:start_branches()
          if ch.player:ability_check("perception", SOCIAL_DC) then
            sp:start_branch(1)
              sp:lines()
            sp:finish_branch()
          end

          if ch.player:ability_check("insight", SOCIAL_DC) then
            sp:start_branch(2)
              sp:lines()
            sp:finish_branch()
          end
        sp:finish_branches()

        local options = sp:start_options()
          while true do
            local n = api.options(options, true)
            if n == 1 then break end
            if n == 3 then return end

            sp:start_option(2)
              sp:lines()
              ch.gatherer.name = "Дарра"
              subs["ИМЯ"] = "Дарра"
              sp:start_single_branch()
                if ch.player:ability_check("insight", SOCIAL_DC) then
                  sp:lines()
                end
              sp:finish_single_branch()
            sp:finish_option()
          end
        sp:finish_options()

        sp:start_branches()
          if ch.player:ability_check("sleight_of_hand", 16) then
            sp:start_branch(1)
              sp:lines()

              sp:start_single_branch()
                if ch.player:ability_check("insight", SOCIAL_DC) then
                  sp:lines(subs)
                end
              sp:finish_single_branch()

              if api.options(sp:start_options()) == 2 then return end
              sp:finish_options()

              sp:lines()
            sp:finish_branch()
          else
            sp:start_branch(2)
              sp:lines()
            sp:finish_branch()
          end
        sp:finish_branches()

        local kick = State.runner:run_task(function()
          level.unsafe_move(ch.player, ch.player.position + Vector.right)
          health.damage(ch.player, 1)
          api.curtain(.2, Vector.black):wait()
          api.curtain(.2, Vector.transparent):wait()
        end)
        sp:lines(subs)
        kick:wait()

        local ft = api.fast_travel(ch.gatherer, ps.rg_ft, ps.rg_ft_to)
        sp:lines()
        ft:wait()

        State.rails:gatherer_run_away()
      sp:finish()
    end,
  },
}
