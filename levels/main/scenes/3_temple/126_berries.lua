local on_solids = require("levels.main.palette.on_solids")
local sprite = require("engine.tech.sprite")
local async = require("engine.tech.async")
local api = require("engine.tech.api")
local screenplay = require("engine.tech.screenplay")
local core = require("levels.main.core")


return {
  --- @type scene
  _126_berries = {
    enabled = true,
    characters = {
      player = {},
      temple_berries = {},
      likka = {optional = true},
    },

    on_add = function(self, ch, ps)
      core.activator(ch.temple_berries, "тарелка с ягодами")
    end,

    start_predicate = function(self, dt, ch, ps)
      return ch.temple_berries.was_interacted_by == ch.player
    end,

    run = function(self, ch, ps)
      ch.temple_berries.interact = nil
      local sp = screenplay.new("assets/screenplay/126_berries.ms", ch)
        sp:lines()

        local n = State.rails.tried_berries and 2 or 1
        sp:start_single_branch(n)
          if State.rails.tried_berries then
            sp:lines()
          end
        sp:finish_single_branch()

        if not State.runner.scenes["eating_berries_" .. n]:run(ch, ps) then return end

        State:remove(ch.temple_berries)
        State:add(on_solids.plate(), {
          position = ch.temple_berries.position, grid_layer = "on_solids"
        })

        State.rails:berries_eat()
        local calling = api.play_sound("assets/sounds/seeing_nea")
        api.move_camera(ps.nea_camera)

        local nea = {
          codename = "nea",
          sprite = sprite.image("assets/sprites/standalone/nea.png"),
          position = ps.nea,
          layer = "fx_over",
          boring_flag = true,
        }

        local blink = function(duration)
          async.sleep(duration)
          State:add(nea)
          api.fade_out(0):wait()

          async.sleep(duration)
          State:remove(nea)
          api.fade_in(0):wait()
        end

        async.sleep(1)
        blink(.05)

        async.sleep(2)
        api.rotate(ch.player, nea)

        async.sleep(1)
        blink(.05)

        async.sleep(1)
        blink(.05)

        async.sleep(1)
        nea.sprite = sprite.image("assets/sprites/standalone/nea_eyes.png")
        blink(.05)

        async.sleep(2)
        State:add(nea)
        api.fade_out(0):wait()

        State.rails:nea_meet()

        async.sleep(3)
        State:remove(nea)
        api.fade_in(0):wait()

        for i = 1, 7 do
          blink(.1 / i)
        end

        calling:wait()

        api.free_camera():wait()

        sp:start_single_branch()
          async.sleep(1)
          if State:exists(ch.likka) then
            sp:lines()
          end
        sp:finish_single_branch()
      sp:finish()
    end,
  },
}
