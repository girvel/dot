local shadows = require("levels.main.palette.shadows")
local async = require("engine.tech.async")
local api = require("engine.tech.api")
local core = require("levels.main.core")
local screenplay = require("engine.tech.screenplay")


--- @param start vector
--- @param finish vector
local create_shard_shadow = function(start, finish)
  for cy = start.y, finish.y, -1 do
    local cx = math.floor((cy - start.y) / (finish.y - start.y) * (finish.x - start.x) + start.x)

    local w = math.min(3, math.floor((start.y - cy) / 2))
    for dx = -w, w do
      local position = V(cx + dx, cy)
      local shadow = State.grids.shadows[position]
      if shadow then State:remove(shadow) end
      State:add(shadows[9](), {position = position, grid_layer = "shadows"})
    end
  end
end


return {
  --- @type scene
  _130_about_player = {
    enabled = true,
    characters = {
      player = {},
      likka = {},
    },

    start_predicate = function(self, dt, ch, ps)
      return (State.player.position - ps.ap_start):abs2() <= 3
    end,

    run = function(self, ch, ps)
      local sp = screenplay.new("assets/screenplay/130_about_player.ms", ch)
        core.bring_likka()

        api.travel_scripted(ch.likka, ch.player.position + Vector.right * 2, 7):wait()
        api.rotate(ch.likka, ch.player)

        sp:lines()
        api.rotate(ch.player, ch.likka)

        local n = api.options(sp:start_options())
        sp:start_option(n)
          sp:start_single_branch(State.rails.empathy == "present" and 1 or 2)
            sp:lines()
          sp:finish_single_branch()
        sp:finish_option()
        sp:finish_options()

        async.sleep(.5)
        ch.likka:rotate(Vector.right)

        async.sleep(3)
        sp:lines()

        local fails_n = 0
        local exit = false

        ch.player:rotate(Vector.right)
        api.move_camera(ps.ap_camera):wait()

        sp:start_branches()
        while not exit do
          sp:start_branch(1)
            sp:start_branches()
            if ch.player:ability_check("perception", 22) then
              exit = true
              sp:start_branch(1)
                create_shard_shadow(ps.shard_shadow_1, ps.shard_shadow_end_1)

                async.sleep(2)
                sp:lines()

                async.sleep(2)
                sp:lines()

                async.sleep(2)
                sp:lines()
              sp:finish_branch()
            else
              fails_n = fails_n + 1
              sp:start_branch(math.min(fails_n + 1, 5))
                sp:lines()
              sp:finish_branch()
            end
            sp:finish_branches()

            if not exit then
              if api.options(sp:start_options()) == 2 then exit = true end
              sp:finish_options()
            end
          sp:finish_branch()
        end
        sp:finish_branches()
      sp:finish()
    end,
  },
}
