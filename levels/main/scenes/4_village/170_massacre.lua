local screenplay = require("engine.tech.screenplay")
local api = require("engine.tech.api")


return {
  --- @type scene
  _170_massacre = {
    enabled = true,
    characters = {
      player = {},
      likka = {optional = true},
      khaned = {optional = true},
      green_priest = {},
    },

    start_predicate = function(self, dt, ch, ps)
      return api.distance(ch.player, ps.ma_start_1) <= 2
        or api.distance(ch.player, ps.ma_start_2) <= 2
    end,

    run = function(self, ch, ps)
      local likka_there = State.rails.likka_status == "village"
      local khaned_there = State.rails.khaned_status == "survived"

      local sp = screenplay.new("assets/screenplay/170_massacre.ms", ch)
        local n = likka_there and 1
          or khaned_there and 2
          or 3

        sp:start_single_branch(n)
          api.move_camera(ps.feast_pyre):wait()

          local prev_rotation
          if n == 1 then
            prev_rotation = ch.likka.direction
            api.rotate(ch.likka, ch.player)
          elseif n == 3 then
            prev_rotation = ch.green_priest.direction
            api.rotate(ch.green_priest, ch.player)
            ch.green_priest:animate("fast_gesture")
          end

          sp:lines()

          if n == 1 then
            ch.likka:rotate(prev_rotation)
          elseif n == 3 then
            ch.green_priest:rotate(prev_rotation)
          end
        sp:finish_single_branch()

        api.free_camera()
        api.travel_scripted(ch.player, ps.feast_sac_1):wait()

        sp:start_single_branch()
          if not likka_there and not khaned_there then
            sp:lines()
          end
        sp:finish_single_branch()

        ch.player:rotate(Vector.up)
        ch.green_priest:animate("clap")
        sp:lines()
      sp:finish()
    end,
  },
}
