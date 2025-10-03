local async = require("engine.tech.async")
local api = require("engine.tech.api")
local screenplay = require "engine.tech.screenplay"
local solids_entities = require "levels.main.palette.solids_entities"


return {
  --- @type scene|table
  _080_saving_khaned = {
    enabled = true,

    characters = {
      khaned = {},
      invader = {},
      player = {},
      khaned_fruit = {},
    },

    on_add = function(self, ch, ps)
      ch.khaned:rotate(Vector.down)
      ch.invader:rotate(Vector.up)
    end,

    start_predicate = function(self, dt, ch, ps)
      return ch.player.position == ps.sk_start
    end,

    run = function(self, ch, ps)
      local sp = screenplay.new("assets/screenplay/080_saving_khaned.ms", ch)
        api.rotate(ch.player, ch.khaned)
        sp:lines()

        State.runner:run_task(function()
          api.rotate(ch.invader, ch.player)
          async.sleep(.5)
          api.rotate(ch.invader, ch.khaned)
        end)
        sp:lines()

        sp:start_single_branch()
        if ch.player:ability_check("insight", 8) then
          sp:lines()
        end
        sp:finish_single_branch()

        api.rotate(ch.player, ch.khaned_fruit)
        State.rails:fruit_see_companion()
        sp:lines()

        api.rotate(ch.player, ch.khaned)
        sp:lines()

        local options = sp:start_options()
        if State.rails.fruit_source then
          options[3] = nil
        end

        while true do
          local n = api.options(options, true)

          sp:start_option(n)
          if n == 1 then
            sp:lines()
          elseif n == 2 then
            local travel = api.travel_scripted(ch.player, ch.player.position + Vector.left)
            sp:lines()
            travel:await()

            State.hostility:set(ch.invader.faction, ch.khaned.faction, "enemy")
            State.hostility:set(ch.invader.faction, ch.player.faction, "enemy")
            State.hostility:set(ch.khaned.faction, ch.invader.faction, "enemy")
            State.hostility:set(ch.player.faction, ch.invader.faction, "enemy")

            ch.invader.essential_flag = nil

            State:start_combat({ch.invader, ch.khaned, ch.player})
            coroutine.yield()

            local sub
            sub = State.hostility:subscribe(function()
              State.runner.scenes._081_after_khaned_fight.player_was_attacking = true
              State.hostility:unsubscribe(sub)
            end)

            local next_scene = State.runner.scenes._081_after_khaned_fight
            next_scene.enabled = true
            next_scene.path_blocker = State:add(
              solids_entities.path_blocker(),
              {position = ps.sk_path_blocker, grid_layer = "solids"}
            )

            return
          elseif n == 3 then
            api.travel_scripted(ch.player, ch.khaned_fruit.position):await()
            local interact = ch.player:animate("interact"):next(function()
              State.rails:fruit_take_khaneds()
            end)
            sp:lines()

            interact:await()
            async.sleep(.5)

            ch.player:rotate(Vector.down)
            async.sleep(.1)
            api.travel_scripted(ch.invader, ch.invader.position + Vector.up)
            sp:lines()
            async.sleep(.2)
            local leaving = api.travel_scripted(ch.player, ps.sk_leaving_2)
            leaving:await()

            async.sleep(.8)
            sp:lines()

            async.sleep(3)
            sp:lines()

            async.sleep(1)
            api.autosave("Забрал фрукт")
            return
          elseif n == 4 then
            local leaving = api.travel_scripted(ch.player, ps.sk_leaving_2)
            async.sleep(1.5)
            sp:lines()
            leaving:await()
            api.autosave("Повидался с Ханедом")
            return
          end
          sp:finish_option()
        end
        sp:finish_options()

        -- NEXT! consequences
        --   State.rails:khaned_left_to_die()

        -- NEXT! lock location
      sp:finish()
    end,
  },
}
