local abilities = require("engine.mech.abilities")
local humanoid    = require("engine.mech.humanoid")
local fighter   = require("engine.mech.class.fighter")
local class     = require("engine.mech.class")
local items = require("levels.main.palette.items_entities")
local rogue   = require("engine.mech.class.rogue")
local combat_ai = require("engine.mech.ais.combat")
local creature  = require("engine.mech.creature")


local npcs = {}

npcs.ai_tester = function(faction)
  local result = Table.extend(humanoid.mixin(), creature.mixin(), {
    codename = faction and ("ai_tester_" .. faction) or "ai_tester",
    base_abilities = abilities.new(10, 14, 10, 10, 10, 10),
    armor = 10,
    level = 1,
    ai = combat_ai.new(),
    inventory = {
      offhand = items.short_bow(),
    },
    max_hp = 30,
    faction = faction,
  })

  creature.init(result)
  return result
end

npcs.khaned = function()
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

npcs.likka = function()
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

npcs.villager = function()
  return creature.make(humanoid.mixin(), {
    name = "Абориген",
    codename = "villager",
    base_abilities = abilities.new(12, 12, 12, 12, 12, 12),  -- TODO
    level = 3,  -- TODO
    inventory = {
    },
    faction = "village",
    perks = {  -- TODO
      class.hit_dice(8),
    },
    direction = Random.choice(Vector.directions),
  })
end

npcs.red_priest = function()
  -- TODO base villager?
  local result = Table.extend(humanoid.mixin(), creature.mixin(), {
    name = "Красный жрец",
    codename = "red_priest",
    base_abilities = abilities.new(12, 12, 12, 12, 12, 12),
    level = 3,
    ai = combat_ai.new(),
    inventory = {
      head = items.red_mask(),
    },
    faction = "village",
    perks = {
      class.hit_dice(8),
    },
  })

  creature.init(result)
  return result
end

npcs.invader = function()
  local result = Table.extend(humanoid.mixin(), creature.mixin(), {
    name = "Пришелец",
    codename = "invader",
    base_abilities = abilities.new(12, 12, 12, 12, 12, 12),  -- TODO
    level = 3,  -- TODO
    ai = combat_ai.new(),
    inventory = {
      head = items.invader_helmet(),
      body = items.invader_armor(),
      hand = items.halberd(),
    },
    faction = "invaders",
    perks = {  -- TODO
      class.hit_dice(8),
    },
  })

  creature.init(result)
  return result
end


return npcs
