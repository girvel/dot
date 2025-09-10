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
      damage_roll = D(2),
      bonus = 1,
      tags = {
        finesse = true,
        light = true,
      },
      slot = "hands",
    }
  )
end

items_entities.axe = function()
  return Table.extend(
    item.mixin("assets/sprites/animations/axe"),
    {
      name = "топорик",
      codename = "axe",
      damage_roll = D(6),
      tags = {
        finesse = true,
      },
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
        versatile = true,
      },
      slot = "hands",
    }
  )
end

local arrow = function()
  return Table.extend(animated.mixin("assets/sprites/animations/arrow"), {
    codename = "arrow",
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

items_entities.shield = function()
  return Table.extend(item.mixin("assets/sprites/animations/shield"), {
    name = "маленький щит",
    codename = "shield",
    slot = "offhand",
    perks = {
      gear.weak_shield,
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

items_entities.bag = function()
  return Table.extend(item.mixin("assets/sprites/animations/bag"), {
    name = "сумка",
    codename = "bag",
    slot = "bag",
    anchor = "right_pocket",
  })
end

items_entities.ritual_mask = function()
  return Table.extend(item.mixin("assets/sprites/animations/ritual_mask"), {
    name = "ритуальная маска",
    codename = "ritual_mask",
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

return items_entities
