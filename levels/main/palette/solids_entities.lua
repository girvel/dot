local base_player = require("engine.state.player").base
local _common     = require("levels.main.palette._common")
local humanoid    = require("engine.mech.humanoid")
local creature    = require("engine.mech.creature")
local items = require("levels.main.palette.items_entities")
local abilities = require("engine.mech.abilities")
local fighter   = require("engine.mech.class.fighter")
local class     = require("engine.mech.class")
local feats     = require("engine.mech.class.feats")
local combat_ai = require("engine.mech.combat_ai")


local solids_entities = {}

--- @class player: base_player

solids_entities.player = function()
  local result = Table.extend(base_player(), humanoid.mixin(), {
    inventory = {
      hand = items.knife(),
      offhand = items.knife(),
    },
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

solids_entities.ai_tester = function(faction)
  local result = Table.extend(humanoid.mixin(), creature.mixin(), {
    codename = "ai_tester",
    base_abilities = abilities.new(10, 14, 10, 10, 10, 10),
    armor = 10,
    level = 1,
    ai = combat_ai.new(),
    inventory = {
      hand = items.knife(),
    },
    max_hp = 30,
    faction = faction,
  })

  creature.init(result)
  return result
end

solids_entities.water = _common.water(Vector.down * .5)

return solids_entities
