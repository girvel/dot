local async = require("engine.tech.async")
local screenplay = require("engine.tech.screenplay")
local solids = require("levels.main.palette.solids")
local api = require("engine.tech.api")


return {
  --- @type scene
  _172_entering_dungeon = {
    enabled = true,
    in_combat_flag = true,
    characters = {
      player = {},
    },

    start_predicate = function(self, dt, ch, ps)
      return api.distance(ch.player, ps.ed_start_1) <= 1
        or api.distance(ch.player, ps.ed_start_2) <= 1
    end,

    run = function(self, ch, ps)
      State.rails:massacre_finish()
      State.rails:rain_finish()

      -- TODO earthquake

      local sp = screenplay.new("assets/screenplay/172_entering_dungeon.ms", ch)
        sp:lines()

        async.sleep(.5)
        ch.player:rotate(Vector.right)
        async.sleep(.2)
        ch.player:rotate(Vector.left)
        async.sleep(.15)
        ch.player:rotate(Vector.down)

        sp:lines()
      sp:finish()

      State.rails:location_dungeon()
    end,
  },
}
