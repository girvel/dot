local creature = require("engine.mech.creature")
local feats     = require("engine.mech.class.feats")
local base_player = require("engine.state.player.base")
local humanoid    = require("engine.mech.humanoid")
local abilities = require("engine.mech.abilities")
local fighter   = require("engine.mech.class.fighter")
local class     = require("engine.mech.class")


local player = {}

--- @class player: base_player

--- @return player
player.new = function()
  local result = Table.extend(base_player.mixin(), humanoid.mixin(), {
    name = "Протагонист",
    base_abilities = abilities.new(8, 8, 8, 8, 8, 8),
    level = 0,
    perks = {},
    faction = "player",
  })

  creature.init(result)
  return result
end

Ldump.mark(player, "const", ...)
return player
