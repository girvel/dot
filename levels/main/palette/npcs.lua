local cleric = require("engine.mech.class.cleric")
local poisoned = require("engine.mech.conditions.poisoned")
local sprite = require("engine.tech.sprite")
local mark = require("engine.tech.mark")
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

local bones_mark = function()
  local atlas = love.image.newImageData("assets/sprites/atlases/on_tiles.png")
  return {
    codename = "bones_mark",
    boring_flag = true,
    sprite = sprite.image(sprite.utility.select(atlas, Random.choice(13, 31, 32))),
  }
end

local skeleton_base = function()
  return Table.extend(animated.mixin("engine/assets/sprites/animations/skeleton"), {
    name = "скелет",
    base_abilities = abilities.new(10, 14, 15, 6, 8, 5),
    armor = 13,
    level = 1,
    ai = combat_ai.new({follow_range = 30}),
    faction = "predators",
    on_death = mark(bones_mark),
    _is_a_skeleton = true,
  })
end

npcs.skeleton_light = function()
  return creature.make(skeleton_base(), {
    codename = "skeleton_light",
    max_hp = 6,
    inventory = {
      offhand = items.short_bow(),
    },
  })
end

npcs.skeleton_heavy = function()
  return creature.make(skeleton_base(), {
    codename = "skeleton_heavy",
    max_hp = 20,
    inventory = {
      hand = items.axe(),
    },
  })
end

npcs.khaned = function()
  return creature.make(animated.mixin("assets/sprites/animations/no_arm"), {
    cues = humanoid.cues,
    name = "Ханед",
    codename = "khaned",
    base_abilities = abilities.new(16, 14, 18, 8, 10, 8),
    level = 4,
    ai = combat_ai.new(),
    inventory = {
      tatoo = items.head_tatoo_1(),
      offhand = items.macuahuitl(),
    },
    faction = "khaned",
    perks = {
      fighter.hit_dice,
      {
        -- no right hand
        modify_activation = function(self, entity, value, codename)
          if codename == "hand_attack" or codename == "opportunity_attack" then return false end
          return value
        end,
      },
    },
    essential_flag = true,
    transparent_flag = true,
    on_half_hp = humanoid.add_blood_mark,
    on_death = humanoid.add_body,
  })
end

npcs.likka = function()
  return creature.make(humanoid.mixin(), {
    name = "Ликка",
    codename = "likka",
    base_abilities = abilities.new(14, 18, 16, 8, 10, 8),
    level = 3,
    ai = combat_ai.new({support_range = 50, follow_range = 50}),
    inventory = {
      bag = items.bag(),
      offhand = items.short_bow(),
    },
    faction = "likka",
    perks = {
      rogue.hit_dice,
      {
        modify_outgoing_damage = poisoned.modify_outgoing_damage(15),
      },
    },
    essential_flag = true,
  })
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
    direction = Random.item(Vector.directions),
    essential_flag = true,
  })
end

local base_priest = function()
  return creature.make(humanoid.mixin(), {
    base_abilities = abilities.new(8, 14, 14, 12, 18, 12),
    level = 6,
    ai = no_op.new(),
    faction = "village",
    perks = {
      cleric.hit_dice,
      cleric.spell_slots,
    },
    essential_flag = true,
  })
end

npcs.red_priest = function()
  return Table.extend(base_priest(), {
    name = "Красный жрец",
    codename = "red_priest",
    inventory = {
      head = items.red_mask(),
    },
  })
end

npcs.green_priest = function()
  return Table.extend(base_priest(), {
    name = "Жрец",
    codename = "green_priest",
    inventory = {
      head = items.green_mask(),
    },
  })
end

npcs.invader = function(faction)
  local result = Table.extend(humanoid.mixin(), creature.mixin(), {
    name = "Пришелец",
    codename = "invader",
    base_abilities = abilities.new(16, 14, 16, 10, 10, 10),
    level = 4,
    ai = combat_ai.new(),
    inventory = {
      head = items.invader_helmet(),
      body = items.invader_armor(),
      hand = items.halberd(),
    },
    faction = faction or "invaders",
    perks = {
      fighter.hit_dice,
      fighter.second_wind,
      fighter.fighting_styles.defence,
      class.skill_proficiency("athletics"),
      class.skill_proficiency("acrobatics"),
    },
    essential_flag = true,
  })

  creature.init(result)
  return result
end

npcs.invader_scout = function()
  local result = npcs.invader()
  result.inventory.head = items.invader_helmet_marked()
  return result
end

npcs.invader_commander = function()
  local result = Table.extend(humanoid.mixin(), creature.mixin(), {
    name = "Пришелец",
    codename = "invader_commander",
    base_abilities = abilities.new(18, 16, 16, 8, 8, 8),
    level = 6,
    ai = combat_ai.new(),
    inventory = {
      head = items.invader_helmet(),
      body = items.invader_armor(),
      offhand = items.shield(),
      hand = items.sword(),
    },
    faction = "invaders",
    perks = {
      fighter.hit_dice,
      fighter.second_wind,
      fighter.action_surge,
      fighter.fighting_styles.defense,
      class.skill_proficiency("athletics"),
      class.skill_proficiency("acrobatics"),
    },
    essential_flag = true,
  })

  creature.init(result)
  return result
end

npcs.invader_priest = function()
  local result = Table.extend(humanoid.mixin(), creature.mixin(), {
    name = "Пришелец",
    codename = "invader_priest",
    base_abilities = abilities.new(8, 16, 16, 8, 18, 8),
    level = 6,
    ai = combat_ai.new(),
    inventory = {
      body = items.priest_robes(),
    },
    faction = "invaders",
    perks = {
      cleric.hit_dice,
      class.skill_proficiency("history"),
      class.skill_proficiency("religion"),
    },
    essential_flag = true,
  })

  creature.init(result)
  return result
end


Ldump.mark(npcs, "const", ...)
return npcs
