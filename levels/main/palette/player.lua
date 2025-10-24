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
    base_abilities = abilities.new(16, 14, 14, 8, 12, 10),
    level = 3,
    perks = {
      class.skill_proficiency("history"),  -- backstory
      class.skill_proficiency("sleight_of_hand"),  -- backstory
      class.skill_proficiency("stealth"),  -- race
      feats.savage_attacker,  -- race
      class.save_proficiency("str"),  -- class...
      class.save_proficiency("con"),
      class.skill_proficiency("athletics"),
      class.skill_proficiency("perception"),
      fighter.fighting_styles.two_weapon_fighting,
      fighter.hit_dice,
      fighter.action_surge,
      fighter.second_wind,
      fighter.fighting_spirit,
      class.skill_proficiency("performance"),
    },
    faction = "player",
  })

  creature.init(result)
  return result
end

Ldump.mark(player, "const", ...)
return player
