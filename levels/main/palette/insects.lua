local creature = require "engine.mech.creature"
local animated = require "engine.tech.animated"
local wandering_ai = require "engine.mech.ais.wandering"
local abilities = require("engine.mech.abilities")
local perks     = require("engine.mech.perks")


local insects = {}

insects.mosquito = function()
  return creature.make(animated.mixin("assets/sprites/animations/mosquito"), {
    name = "Комар",
    codename = "mosquito",
    base_abilities = abilities.new(1, 1, 1, 1, 1, 1),
    level = 1,
    ai = wandering_ai.new(3),
    max_hp = 1,
    no_blood_flag = true,
    no_sound_flag = true,
    perks = {
      perks.passive,
    },
  })
end

return insects
