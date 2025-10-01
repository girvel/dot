local async = require("engine.tech.async")
local api = require("engine.tech.api")
local screenplay = require("engine.tech.screenplay")
local tcod = require("engine.tech.tcod")
local items_entities = require("levels.main.palette.items_entities")


return {
  --- @type scene|table
  _090_random_gatherer = {
    enabled = true,

    characters = {
      player = {},
      gatherer = {},
    },

    on_add = function(self, ch, ps)
      ch.gatherer.inventory.tatoo = State:add(items_entities.gatherer_scar())
      ch.gatherer:rotate(Vector.left)
      ch.gatherer.name = "Собиратель"
    end,

    start_predicate = function(self, dt, ch, ps)
      return (ch.player.position - ch.gatherer.position):abs2() <= 4
        and tcod.snapshot(State.grids.solids):is_visible_unsafe(unpack(ch.gatherer.position))
    end,

    run = function(self, ch, ps)
      local sp = screenplay.new("assets/screenplay/090_random_gatherer.ms", ch)
        sp:lines()

        api.travel_scripted(ch.player, ps.rg_player)

        sp:start_branches()
          local branch =
            ch.player:ability_check("insight", 8) and 1
            or ch.player:ability_check("stealth", 12) and 2
            or 3

          async.sleep(branch == 2 and 1.5 or .5)
          api.rotate(ch.gatherer, ch.player)

          sp:start_branch(branch)
            sp:lines()
          sp:finish_branch()

          if ch.player:ability_check("perception", 12) then
            sp:start_branch(4)
              sp:lines()
            sp:finish_branch()
          end
        sp:finish_branches()

        sp:lines()
      sp:finish()
    end,
  },
}
