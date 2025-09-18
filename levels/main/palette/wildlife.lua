local animated = require("engine.tech.animated")
local abilities = require("engine.mech.abilities")
local creature    = require("engine.mech.creature")
local wandering_ai = require("engine.mech.wandering_ai")
local combat_ai = require("engine.mech.combat_ai")


local wildlife = {}

local PIG_CUES = {
  blood = function()
    return Table.extend(
      animated.mixin("assets/sprites/animations/pig_blood"),
      {
        name = "Кровь свиньи",
        codename = "pig_blood",
        slot = "blood",
        anchor = "head",
        boring_flag = true,
      }
    )
  end,
}

wildlife.pig = function()
  return creature.make(animated.mixin("assets/sprites/animations/pig"), creature.mixin(), {
    name = "Свинья",
    codename = "pig",
    base_abilities = abilities.new(10, 14, 10, 4, 10, 6),
    level = 1,
    ai = wandering_ai.new(),
    max_hp = 4,
    faction = "neutral",
    cues = PIG_CUES,
  })
end

local tusks = function()
  return Table.extend(animated.mixin("assets/sprites/animations/tusks"), {
    name = "Клыки",
    codename = "tusks",
    slot = "head",
    no_drop_flag = true,
    tags = {},
  })
end

wildlife.boar = function()
  return creature.make(animated.mixin("assets/sprites/animations/pig"), creature.mixin(), {
    name = "Кабан",
    codename = "boar",
    base_abilities = abilities.new(13, 12, 12, 2, 9, 5),
    level = 1,
    ai = combat_ai.new(),
    max_hp = 11,
    faction = "predators",
    inventory = {
      head = tusks(),
      hand = {
        damage_roll = D(6),
        slot = "hand",
        no_drop_flag = true,
        tags = {},
      },
    },
    cues = PIG_CUES,
  })
end

return wildlife
