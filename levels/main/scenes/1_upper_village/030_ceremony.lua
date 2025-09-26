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

        local feast_scene = Runner.scenes._020_feast
        for _, scene in ipairs(feast_scene.final_dancing_scenes) do
          Runner:remove(scene)
        end
        feast_scene.enabled = nil

        for _, name in ipairs {
          "boy_1", "boy_2", "boy_3",
          "girl_1", "girl_2", "girl_3",
          "thrower_1", "thrower_2", "thrower_3", "thrower_4", "thrower_5",
          "watcher_1", "watcher_2", "watcher_3", "watcher_4",
          "extra_dancer", "green_priest",
        } do
          local e = Runner.entities[name]
          if State:exists(e) then
            State.rails.runner:run_task(function()
              api.travel_persistent(e, Runner.positions.ceremony_crowd, 2)
              e:rotate(Vector.left)
            end)
          end
        end

        api.move_camera(ch.likka.position)
        sp:lines()

        api.free_camera()
        api.travel_scripted(ch.player, Runner.positions.ceremony_player)
      sp:finish()
    end,
  },
}
