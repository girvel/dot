local creature = require "engine.mech.creature"
local animated = require "engine.tech.animated"
local wandering_ai = require "engine.mech.ais.wandering"
local abilities = require("engine.mech.abilities")


local insects = {}

insects.mosquito = function()
  return creature.make(animated.mixin("assets/sprites/animations/mosquito"), {
    name = "Комар",
    codename = "mosquito",
    base_abilities = abilities.new(1, 1, 1, 1, 1, 1),
    level = 1,
    ai = wandering_ai.new(3),
    max_hp = 1,
    faction = "neutral",
    no_blood_flag = true,
    no_sound_flag = true,
  })
end

return insects
