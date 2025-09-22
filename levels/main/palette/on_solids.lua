local factoring = require("engine.tech.factoring")
local config = require("levels.main.config")
local interactive = require("engine.tech.interactive")
local health      = require("engine.mech.health")


local on_solids = {}

local collect_berries = function(self, other)
  State:remove(self)
  health.heal(other, 1)
end

local collect_food = function(self, other)
  self.on_remove = function()
    State:add(on_solids.plate(), {position = self.position, grid_layer = "on_solids"})
  end
  State:remove(self)
  health.heal(other, 1)
end

local get_base = function(codename)
  if codename == "berries" then
    local result = interactive.mixin(collect_berries)
    result.name = "ягоды"
    return result
  elseif codename == "food" then
    local result = interactive.mixin(collect_food)
    result.name = "еда"
    return result
  end
  return {}
end

on_solids = factoring.from_atlas("assets/sprites/atlases/on_solids.png", config.cell_size, {
  "vines",    "vines",     "vines",     "cobweb_1", "cobweb_2", "statue_1", "statue_2", "window",
  false,      "candles_1", "candles_2", "cobweb_3", "cobweb_4", "statue_3", "statue_4", false,
  "stage",    "candles_3", "skull",     "dooro",    "statue_5", "statue_6", "statue_7", false,
  "pot_1",    "pot_2",     "pot_3",     "plate",    "plate",    false,      false,      false,
  "pot_4",    "pot_5",     "pot_6",     "cloth",    "food",     "food",     false,      false,
  "berriesp", "berries",   "berries",   false,      false,      false,      false,      false,
  "berriesp", "berries",   "berries",   false,      false,      false,      false,      false,
}, function(codename)
  local result = get_base(codename)
  result.boring_flag = true
  return result
end)

return on_solids
