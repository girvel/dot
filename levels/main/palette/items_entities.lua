local animated = require("engine.tech.animated")
local item     = require "engine.tech.item"
local gear     = require "engine.mech.gear"


local items_entities = {}

items_entities.knife = function()
  return Table.extend(
    item.mixin("assets/sprites/animations/knife"),
    {
      name = "кухонный нож",
      codename = "knife",
      damage_roll = D(4),
      tags = {
        finesse = true,
        light = true,
      },
      slot = "hands",
    }
  )
end

items_entities.ritual_blade = function()
  local result = Table.extend(
    item.mixin("assets/sprites/animations/ritual_blade"),
    {
      name = "ритуальный клинок",
      codename = "ritual_blade",
      damage_roll = D(6),
      bonus = 1,
      tags = {
        finesse = true,
        light = true,
      },
      slot = "hands",
    }
  )

  item.set_cue(result, "highlight", true)
  return result
end

items_entities.axe = function()
  return Table.extend(
    item.mixin("assets/sprites/animations/axe"),
    {
      name = "топорик",
      codename = "axe",
      damage_roll = D(6),
      tags = {},
      slot = "hands",
    }
  )
end

items_entities.pole = function()
  return Table.extend(
    item.mixin("assets/sprites/animations/pole"),
    {
      name = "двуручный шест",
      codename = "pole",
      damage_roll = D(6),
      bonus = -1,
      tags = {
        heavy = true,
        two_handed = true,
      },
      slot = "hands",
    }
  )
end

items_entities.bear_spear = function()
  return Table.extend(
    item.mixin("assets/sprites/animations/bear_spear"),
    {
      name = "рогатина",
      codename = "bear_spear",
      damage_roll = D(10),
      tags = {
        heavy = true,
        two_handed = true,
      },
      slot = "hands",
    }
  )
end

items_entities.halberd = function()
  return Table.extend(
    item.mixin("assets/sprites/animations/halberd"),
    {
      name = "алебарда",
      codename = "halberd",
      damage_roll = D(10),
      tags = {
        heavy = true,
        two_handed = true,
      },
      slot = "hands",
    }
  )
end

items_entities.sword = function()
  return Table.extend(
    item.mixin("assets/sprites/animations/sword"),
    {
      name = "меч",
      codename = "sword",
      damage_roll = D(8),
      bonus = 1,
      tags = {},
      slot = "hands",
    }
  )
end

items_entities.macuahuitl = function()
  return Table.extend(
    item.mixin("assets/sprites/animations/macuahuitl"),
    {
      name = "Макуауитль",
      codename = "macuahuitl",
      damage_roll = D(8),
      bonus = 0,
      tags = {},
      slot = "hands",
    }
  )
end

local arrow = function()
  return Table.extend(animated.mixin("assets/sprites/animations/arrow"), item.mixin_min("hand"), {
    codename = "arrow",
    boring_flag = true,
  })
end

items_entities.short_bow = function()
  return Table.extend(
    item.mixin("assets/sprites/animations/short_bow"),
    {
      name = "короткий лук",
      codename = "short_bow",
      damage_roll = D(6),
      tags = {
        two_handed = true,
        ranged = true,
      },
      slot = "offhand",
      projectile_factory = arrow,
    }
  )
end

items_entities.long_bow = function()
  return Table.extend(
    item.mixin("assets/sprites/animations/long_bow"),
    {
      name = "длинный лук",
      codename = "long_bow",
      damage_roll = D(8),
      tags = {
        two_handed = true,
        ranged = true,
      },
      slot = "offhand",
      projectile_factory = arrow,
    }
  )
end

items_entities.small_shield = function()
  return Table.extend(item.mixin("assets/sprites/animations/small_shield"), {
    name = "маленький щит",
    codename = "small_shield",
    slot = "offhand",
    perks = {
      gear.weak_shield,
    },
  })
end

items_entities.shield = function()
  return Table.extend(item.mixin("assets/sprites/animations/shield"), {
    name = "щит",
    codename = "shield",
    slot = "offhand",
    perks = {
      gear.shield,
    },
  })
end

items_entities.head_tatoo_1 = function()
  return Table.extend(item.mixin("assets/sprites/animations/head_tatoo_1"), {
    codename = "head_tatoo_1",
    slot = "tatoo",
    anchor = "head",
  })
end

items_entities.gatherer_scar = function()
  return Table.extend(item.mixin("assets/sprites/animations/gatherer_scar"), {
    codename = "gatherer_scar",
    slot = "tatoo",
    anchor = "head",
  })
end

items_entities.bag = function()
  return Table.extend(item.mixin("assets/sprites/animations/bag"), {
    name = "сумка",
    codename = "bag",
    slot = "bag",
    anchor = "right_pocket",
  })
end

--- @alias hair_type "short_hair_1"|"short_hair_2"|"short_hair_3"|"long_hair"

--- @enum (key) hair_color
local hair_colors = {
  dark = Vector.hex("4f5a5c"),
  red = Vector.hex("e86c46"),
  brown = Vector.hex("544747"),
}

--- @param type hair_type
--- @param color hair_color|vector
items_entities.hair = function(type, color)
  color = hair_colors[color] or color  --- @cast color vector

  return Table.extend(
    item.mixin_min("hair"),
    animated.mixin("assets/sprites/animations/" .. type, "directional", color),
    {
      anchor = "head",
    }
  )
end

items_entities.red_mask = function()
  return Table.extend(item.mixin("assets/sprites/animations/red_mask"), {
    name = "ритуальная маска",
    codename = "red_mask",
    slot = "head",
    perks = {
      gear.helmet,
    },
  })
end

items_entities.green_mask = function()
  return Table.extend(item.mixin("assets/sprites/animations/green_mask"), {
    name = "ритуальная маска",
    codename = "red_mask",
    slot = "head",
    perks = {
      gear.helmet,
    },
  })
end

items_entities.invader_helmet = function()
  return Table.extend(item.mixin("assets/sprites/animations/invader_helmet"), {
    name = "шлем пришельца",
    codename = "invader_helmet",
    slot = "head",
    perks = {
      gear.medium_helmet,
    },
  })
end

items_entities.invader_helmet_marked = function()
  return Table.extend(item.mixin("assets/sprites/animations/invader_helmet_marked"), {
    name = "шлем пришельца",
    codename = "invader_helmet_marked",
    slot = "head",
    perks = {
      gear.medium_helmet,
    },
  })
end

items_entities.invader_armor = function()
  return Table.extend(item.mixin("assets/sprites/animations/invader_armor"), {
    name = "броня пришельца",
    codename = "invader_armor",
    slot = "body",
    perks = {
      gear.medium_armor,
    },
  })
end

items_entities.priest_robes = function()
  return Table.extend(item.mixin("assets/sprites/animations/priest_robes"), {
    name = "белая рубаха",
    codename = "priest_robes",
    slot = "body",
    no_drop_flag = true,
    boring_flag = true,
  })
end

Ldump.mark(items_entities, "const", ...)
return items_entities
