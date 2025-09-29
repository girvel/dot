local async = require("engine.tech.async")
local actions = require("engine.mech.actions")
local health = require("engine.mech.health")
local level = require("engine.tech.level")
local api = require("engine.tech.api")
local screenplay = require("engine.tech.screenplay")


local CROWD = {
  "boy_1", "boy_2", "boy_3",
  "girl_1", "girl_2", "girl_3",
  "thrower_1", "thrower_2", "thrower_3", "thrower_4", "thrower_5",
  "watcher_1", "watcher_2", "watcher_3", "watcher_4",
  "extra_dancer", "green_priest",
}

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
      ceremony_food = {},
    },

    --- @param self scene|table
    --- @param dt number
    --- @param ch runner_characters
    --- @param ps runner_positions
    start_predicate = function(self, dt, ch, ps)
      return (ps.ceremony_start - ch.player.position):abs2() <= 2
    end,

    _first_time = true,

    --- @param self scene|table
    --- @param ch runner_characters
    --- @param ps runner_positions
    run = function(self, ch, ps)
      local sp = screenplay.new("assets/screenplay/030_ceremony.ms", ch)
        local did_player_come_first = false
        while ch.likka.position ~= ps.ceremony_likka
          or ch.khaned.position ~= ps.ceremony_khaned
          or ch.red_priest.position ~= ps.ceremony_red_priest
        do
          did_player_come_first = true
          coroutine.yield()
          if Period(15, self, "start") then
            level.unsafe_move(ch.likka, ps.ceremony_likka)
            level.unsafe_move(ch.khaned, ps.ceremony_khaned)
            level.unsafe_move(ch.red_priest, ps.ceremony_red_priest)
            break
          end
        end

        sp:start_branches()
        local hand = ch.player.inventory.hand
        local offhand = ch.player.inventory.offhand
        if hand and hand.bonus or offhand and offhand.bonus then
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

        local feast_scene = State.runner.scenes._020_feast
        for _, scene in ipairs(feast_scene.final_dancing_scenes) do
          State.runner:remove(scene)
        end
        feast_scene.enabled = nil

        ch.red_priest:rotate(Vector.right)
        ch.khaned:rotate(Vector.down)
        for _, name in ipairs(CROWD) do
          local e = State.runner.entities[name]
          if State:exists(e) then
            State.runner:run_task(function()
              api.travel_persistent(e, ps.ceremony_crowd, 2)
              e:rotate(Vector.left)
            end, "crowd_travel")
          end
        end

        sp:start_single_branch()
        if not did_player_come_first then
          api.move_camera(ch.likka.position)
          api.rotate(ch.likka, ch.player)
          sp:lines()
          api.rotate(ch.likka, ch.red_priest)
        end
        sp:finish_single_branch()

        api.move_camera(ch.red_priest.position)
        api.travel_scripted(ch.player, ps.ceremony_player):await()
        api.rotate(ch.player, ch.red_priest)

        sp:lines()

        sp:start_branches()
          if ch.player:ability_check("religion", 16) then
            -- SOUND ominous 1
            sp:start_branch(1)
              sp:lines()
            sp:finish_branch()
          end
          if ch.player:ability_check("perception", 16) then
            -- SOUND ominous 2
            sp:start_branch(2)
              sp:lines()
            sp:finish_branch()
          end
        sp:finish_branches()

        api.rotate(ch.red_priest, ch.khaned)
        sp:lines()

        local n = api.options(sp:start_options())
          if n == 1 or n == 3 then
            sp:start_option(1)
              local khaned_weapon = ch.khaned.inventory.offhand
              ch.khaned.inventory.offhand = nil

              api.travel_scripted(ch.khaned, ch.player.position):await()
              api.rotate(ch.khaned, ch.player)
              ch.khaned:animate("offhand_attack"):await()
              health.damage(ch.player, 1)

              sp:lines()
              api.options(sp:start_options())
              sp:finish_options()

              ch.khaned.inventory.offhand = khaned_weapon
              api.rotate(ch.khaned, ch.red_priest)
            sp:finish_option()
          end
        sp:finish_options()

        api.rotate(ch.red_priest, ch.khaned)
        sp:lines()

        ch.red_priest:animate("gesture"):await()
        for _, name in ipairs(CROWD) do
          local e = State.runner.entities[name]
          if State:exists(e) and Random.chance(.8) then
            local animation_name = Random.choice({"fast_gesture", "clap"})
            State.runner:run_task(function()
              for _ = 1, 6 do
                async.sleep(Random.float(0, .2))
                e:animate(animation_name):await()
              end
            end, "crowd_gesture")
          end
        end
        sp:lines()

        local priest_giving = State.runner:run_task(function()
          api.travel_scripted(ch.red_priest, ch.ceremony_food.position):await()
          ch.red_priest:animate("interact"):await()
          State:remove(ch.ceremony_food)
          ch.ceremony_food = nil
          for _, target in ipairs {"player", "likka", "khaned"} do
            api.travel_scripted(ch.red_priest, ch[target].position):await()
            api.rotate(ch[target], ch.red_priest)
            ch.red_priest:animate("interact"):await()
          end
          local t = api.travel_scripted(ch.red_priest, ps.ceremony_red_priest)
          async.sleep(.1)
          ch.khaned:rotate(Vector.down)
          async.sleep(.2)
          ch.likka:rotate(Vector.down)
          async.sleep(.1)
          ch.player:rotate(Vector.down)
          t:await()
          api.rotate(ch.red_priest, ch.khaned)
        end, "priest_giving")
        sp:lines()
        priest_giving:await()

        async.sleep(.5)
        ch.red_priest:animate("clap", true)
        sp:lines()

        async.sleep(1)
        local _, khaned_leaving_scene = api.travel_scripted(ch.khaned, ps.gtf_khaned)
        sp:lines()

        local _, likka_leaving_scene = api.travel_scripted(ch.likka, ps.gtf_likka)
        local player_moving = api.travel_scripted(ch.player, ps.ceremony_player_away)
        sp:lines()
        player_moving:await()

        player_moving = api.travel_scripted(ch.player, ps.ceremony_player_away_2)
        api.free_camera()
        api.fade_out()
        player_moving:await()
        State.runner:remove(khaned_leaving_scene)
        State.runner:remove(likka_leaving_scene)
      sp:finish()
      State.runner.scenes._040_going_to_forest:run(ch, ps)
    end,
  },
}
