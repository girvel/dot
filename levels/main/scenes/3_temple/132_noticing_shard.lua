local async = require("engine.tech.async")
local screenplay = require("engine.tech.screenplay")
local shadows = require("levels.main.palette.shadows")
local api = require("engine.tech.api")


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
Ldump.ignore_size(create_shard_shadow)


return {
  --- @type scene
  _132_noticing_shard = {
    characters = {
      likka = {},
      player = {},
    },

    start_predicate = function(self, dt, ch, ps)
      return api.distance(ch.player, ps.shard_shadow_1) <= 14
    end,

    run = function(self, ch, ps)
      local sp = screenplay.new("assets/screenplay/132_noticing_shard.ms", ch)
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
