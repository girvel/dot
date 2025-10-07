local sprite = require("engine.tech.sprite")
local health = require("engine.mech.health")
local api = require("engine.tech.api")
local screenplay = require("engine.tech.screenplay")
local item = require("engine.tech.item")
local interactive = require("engine.tech.interactive")


return {
  --- @type scene|table
  _054_hornets_nest = {
    enabled = true,

    characters = {
      player = {},
    },

    on_add = function(self)
      local e = State:add(interactive.mixin(function(self) State:remove(self) end), {
        name = "Дупло",
        position = State.runner.positions.hn_nest,
        grid_layer = "on_solids",
        sprite = sprite.image("assets/sprites/empty.png"),
      })
      item.set_cue(e, "highlight", true)
      State.runner.entities.hornets_nest = e
    end,

    --- @param self scene|table
    --- @param dt number
    --- @param ch runner_characters
    --- @param ps runner_positions
    start_predicate = function(self, dt, ch, ps)
      return not State:exists(State.runner.entities.hornets_nest)
    end,

    --- @param self scene|table
    --- @param ch runner_characters
    --- @param ps runner_positions
    run = function(self, ch, ps)
      local sp = screenplay.new("assets/screenplay/054_hornets_nest.ms", ch)
        sp:lines()

        if api.options(sp:start_options()) ~= 2 then return end
        sp:finish_options()

        sp:start_branches()
        if ch.player:ability_check("survival", 12) then
          sp:start_branch(1)
            sp:lines()
          sp:finish_branch()
        else
          sp:start_branch(2)
            sp:lines()
          sp:finish_branch()
        end
        sp:finish_branches()

        if api.options(sp:start_options()) ~= 3 then return end
        sp:finish_options()

        sp:lines()

        if api.options(sp:start_options()) ~= 4 then return end
        sp:finish_options()

        -- SOUND hornets
        health.damage(ch.player, 3, true)
        sp:lines()
        api.travel_scripted(ch.player, ps.hn_runaway):wait()
      sp:finish()
    end,
  },
}
