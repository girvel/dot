local screenplay = require("engine.tech.screenplay")
local solids = require("levels.main.palette.solids")
local api = require("engine.tech.api")


return {
  --- @type scene
  _172_entering_dungeon = {
    in_combat_flag = true,
    characters = {
      player = {},
    },

    start_predicate = function(self, dt, ch, ps)
      return api.distance(ch.player, ps.ed_start_1) <= 1
        or api.distance(ch.player, ps.ed_start_2) <= 1
    end,

    run = function(self, ch, ps)
      for _, e in ipairs(State.runner.scenes._170_massacre.combat_list) do
        if e ~= ch.player then
          State:remove(e)
        end
      end

      for _, p in ipairs {
        ps.dungeon_entrance_1,
        ps.dungeon_entrance_2,
        ps.dungeon_entrance_3,
        ps.ed_edge_1,
        ps.ed_edge_2,
      } do
        local solid = State.grids.solids[p]
        if solid then
          State:remove(solid)
        end

        State:add(solids[42](), {position = p, grid_layer = "solids", transparent_flag = false})
      end

      State.rails:rain_finish()

      -- TODO earthquake

      local sp = screenplay.new("assets/screenplay/172_entering_dungeon.ms", ch)
        sp:lines()
      sp:finish()
    end,
  },
}
