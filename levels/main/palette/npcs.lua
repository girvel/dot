local animated = require("engine.tech.animated")
local abilities = require("engine.mech.abilities")
local humanoid    = require("engine.mech.humanoid")
local fighter   = require("engine.mech.class.fighter")
local class     = require("engine.mech.class")
local items = require("levels.main.palette.items_entities")
local rogue   = require("engine.mech.class.rogue")
local combat_ai = require("engine.mech.ais.combat")
local creature  = require("engine.mech.creature")
local no_op     = require("engine.mech.ais.no_op")


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
    faction = faction or State.uid:next(),
  })

  creature.init(result)
  return result
end

npcs.khaned = function()
  return creature.make(animated.mixin("assets/sprites/animations/no_arm"), {
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
    -- TODO perks
    perks = {
      fighter.hit_dice,
      {
        -- no right hand
        modify_activation = function(self, entity, value, codename)
          if codename == "hand_attack" then return false end
          return value
        end,
      },
    },
    essential_flag = true,
    transparent_flag = true,
  })
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
    essential_flag = true,
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
    ai = no_op.new(),
    inventory = {},
    faction = "village",
    perks = {  -- TODO
      class.hit_dice(8),
    },
    direction = Random.choice(Vector.directions),
    essential_flag = true,
  })
end

npcs.red_priest = function()
  return creature.make(humanoid.mixin(), {
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
    essential_flag = true,
  })
end

npcs.green_priest = function()
  return creature.make(humanoid.mixin(), {
    name = "Бирюзовый жрец",
    codename = "green_priest",
    base_abilities = abilities.new(12, 12, 12, 12, 12, 12),
    level = 3,
    ai = combat_ai.new(),
    inventory = {
      head = items.green_mask(),
    },
    faction = "village",
    perks = {
      class.hit_dice(8),
    },
    essential_flag = true,
  })
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
    essential_flag = true,
  })

  creature.init(result)
  return result
end


return npcs
