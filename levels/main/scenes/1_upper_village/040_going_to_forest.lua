local solids_entities = require("levels.main.palette.solids_entities")
local api = require("engine.tech.api")
local async = require("engine.tech.async")
local level = require("engine.tech.level")
local screenplay = require("engine.tech.screenplay")


return {
  --- @type scene|table
  _040_going_to_forest = {
    characters = {
      player = {},
      khaned = {},
      likka = {},
    },

    --- @param self scene|table
    --- @param dt number
    --- @param ch runner_characters
    --- @param ps runner_positions
    start_predicate = function(self, dt, ch, ps)
      return false  -- manually triggered scene
    end,

    --- @param self scene|table
    --- @param ch runner_characters
    --- @param ps runner_positions
    run = function(self, ch, ps)
      local sp = screenplay.new("assets/screenplay/040_going_to_forest.ms", ch)
        level.unsafe_move(ch.khaned, ps.gtf_khaned)
        level.unsafe_move(ch.likka, ps.gtf_likka)
        level.unsafe_move(ch.player, ps.gtf_player)

        ch.khaned:rotate(Vector.left)
        ch.likka:rotate(Vector.left)
        ch.player:rotate(Vector.left)

        async.sleep(3)
        api.fade_in()

        sp:lines()
        api.travel_scripted(ch.likka, ps.gtf_likka_1)

        async.sleep(1)
        api.travel_scripted(ch.khaned, ps.gtf_khaned_1):next(function()
          ch.khaned:rotate(Vector.right)
        end)

        async.sleep(.3)
        local player_moving = api.travel_scripted(ch.player, ps.gtf_player_1)
        async.sleep(2)
        sp:lines()
        player_moving:await()
        async.sleep(1)
        ch.player:rotate(Vector.right)
        async.sleep(.5)
        api.travel_scripted(ch.player, ps.gtf_player_2):await()
        api.move_camera(ch.likka.position)

        async.sleep(.4)
        api.rotate(ch.player, ch.likka)

        async.sleep(.2)
        api.rotate(ch.likka, ch.player)
        sp:lines()
        api.move_camera(ch.player.position):await()
        ch.player:rotate(Vector.right)
        sp:lines()

        local flash_color = Vector.hex("fcea9b")
        local transparent = flash_color:copy()
        transparent.a = 0
        api.curtain(0, transparent)
        local curtain = api.curtain(3, flash_color)
        sp:lines()
        curtain:await()

        State.rails:winter_end()
        curtain = api.curtain(5, transparent)
        curtain:await()

        sp:lines()
        sp:start_single_branch()
        if ch.player:ability_check("insight", 12) then
          sp:lines()
        end
        sp:finish_single_branch()
        sp:lines()

        local ft_khaned = api.fast_travel(ch.khaned, ps.gtf_khaned_ft, ps.sk_khaned)
        api.travel_scripted(ch.likka, ch.player.position):await()

        sp:lines()
        local ft_likka = api.fast_travel(ch.likka, ps.gtf_likka_ft, ps.sl_likka)

        ft_khaned:await()
        ft_likka:await()

        State.rails:location_forest()
        State.rails:feast_end()
        State.rails:seekers_start()
      sp:finish()
    end,
  },
}
