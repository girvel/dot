local weapons  = require "engine.mech.weapons"
local item     = require "engine.tech.item"
local gear     = require "engine.mech.gear"


local items_entities = {}

items_entities.knife = weapons.knife

items_entities.head_tatoo_1 = function()
  return Table.extend(item.mixin("assets/sprites/animations/head_tatoo_1"), {
    codename = "head_tatoo_1",
    slot = "tatoo",
    anchor = "head",
  })
end

items_entities.bag = function()
  return Table.extend(item.mixin("assets/sprites/animations/bag"), {
    codename = "bag",
    slot = "bag",
    anchor = "right_pocket",
  })
end

items_entities.ritual_mask = function()
  return Table.extend(item.mixin("assets/sprites/animations/ritual_mask"), {
    codename = "ritual_mask",
    slot = "head",
    perks = {
      gear.helmet,
    },
  })
end

items_entities.invader_helmet = function()
  return Table.extend(item.mixin("assets/sprites/animations/invader_helmet"), {
    codename = "invader_helmet",
    slot = "head",
    perks = {
      gear.medium_helmet,
    },
  })
end

items_entities.invader_armor = function()
  return Table.extend(item.mixin("assets/sprites/animations/invader_armor"), {
    codename = "invader_armor",
    slot = "body",
    perks = {
      gear.medium_armor,
    },
  })
end

return items_entities
