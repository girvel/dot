local _common     = require("levels.main.palette._common")
local humanoid    = require("engine.mech.humanoid")
local abilities = require("engine.mech.abilities")
local fighter   = require("engine.mech.class.fighter")
local class     = require("engine.mech.class")
local creature    = require("engine.mech.creature")
local items = require("levels.main.palette.items_entities")
local rogue   = require("engine.mech.class.rogue")
local combat_ai = require("engine.mech.combat_ai")
local player    = require("levels.main.palette.player")


local solids_entities = {}

solids_entities.player = player.new

solids_entities.ai_tester = function(faction)
  local result = Table.extend(humanoid.mixin(), creature.mixin(), {
    codename = faction and ("ai_tester_" .. faction) or "ai_tester",
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

solids_entities.khaned = function()
  local result = Table.extend(humanoid.mixin(), creature.mixin(), {
    name = "Ханед",
    codename = "khaned",
    base_abilities = abilities.new(16, 14, 18, 8, 10, 8),
    level = 4,
    ai = combat_ai.new(),
    inventory = {
      tatoo = items.head_tatoo_1(),
      -- TODO bear spear
    },
    faction = "khaned",
    perks = {
      fighter.hit_dice,
    },
    -- TODO perks
  })

  creature.init(result)
  return result
end

solids_entities.likka = function()
  local result = Table.extend(humanoid.mixin(), creature.mixin(), {
    name = "Ликка",
    codename = "likka",
    base_abilities = abilities.new(16, 14, 18, 8, 10, 8),
    level = 3,
    ai = combat_ai.new(),
    inventory = {
      bag = items.bag(),
      -- TODO spear
    },
    faction = "likka",
    perks = {
      rogue.hit_dice,
    },
    -- TODO perks
  })

  creature.init(result)
  return result
end

solids_entities.villager = function()
  local result = Table.extend(humanoid.mixin(), creature.mixin(), {
    name = "Абориген",
    codename = "villager",
    base_abilities = abilities.new(12, 12, 12, 12, 12, 12),  -- TODO
    level = 3,  -- TODO
    ai = combat_ai.new(),
    inventory = {
    },
    faction = "village",
    perks = {  -- TODO
      class.hit_dice(8),
    },
  })

  creature.init(result)
  return result
end

solids_entities.head_priest = function()
  -- TODO base villager?
  local result = Table.extend(humanoid.mixin(), creature.mixin(), {
    name = "Верховный жрец",
    codename = "head_priest",
    base_abilities = abilities.new(12, 12, 12, 12, 12, 12),
    level = 3,
    ai = combat_ai.new(),
    inventory = {
      head = items.ritual_mask(),
    },
    faction = "village",
    perks = {
      class.hit_dice(8),
    },
  })

  creature.init(result)
  return result
end

solids_entities.invader = function()
  local result = Table.extend(humanoid.mixin(), creature.mixin(), {
    name = "Пришелец",
    codename = "invader",
    base_abilities = abilities.new(12, 12, 12, 12, 12, 12),  -- TODO
    level = 3,  -- TODO
    ai = combat_ai.new(),
    inventory = {
      head = items.invader_helmet(),
      body = items.invader_armor(),
    },
    faction = "invaders",
    perks = {  -- TODO
      class.hit_dice(8),
    },
  })

  creature.init(result)
  return result
end

solids_entities.water = _common.water(Vector.down * .5)

return solids_entities
