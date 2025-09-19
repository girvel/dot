local animated = require("engine.tech.animated")
local abilities = require("engine.mech.abilities")
local creature    = require("engine.mech.creature")
local wandering_ai = require("engine.mech.ais.wandering")
local combat_ai = require("engine.mech.ais.combat")
local perks     = require("engine.mech.perks")


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
  return creature.make(animated.mixin("assets/sprites/animations/pig"), {
    name = "Свинья",
    codename = "pig",
    base_abilities = abilities.new(10, 14, 10, 4, 10, 6),
    level = 1,
    ai = wandering_ai.new(),
    max_hp = 4,
    faction = "pigs",
    cues = PIG_CUES,
    perks = {
      perks.passive,
    },
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
  return creature.make(animated.mixin("assets/sprites/animations/pig"), {
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

wildlife.frog = function()
  return creature.make(animated.mixin("assets/sprites/animations/frog"), {
    name = "Лягушка",
    codename = "frog",
    base_abilities = abilities.new(1, 13, 8, 1, 8, 3),
    level = 1,
    ai = wandering_ai.new(),
    max_hp = 1,
    faction = "frogs_" .. State.uid:next(),
    no_blood_flag = true,
    perks = {
      perks.passive,
    },
  })
end

return wildlife
