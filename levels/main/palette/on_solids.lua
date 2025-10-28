local factoring = require("engine.tech.factoring")
local interactive = require("engine.tech.interactive")
local health      = require("engine.mech.health")


local on_solids

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

local is_in_perspective = function(codename)
  return codename == "statuet" or nil
end

on_solids = factoring.from_atlas("assets/sprites/atlases/on_solids.png", Constants.cell_size, {
  "vines",    "vines",   "vines",   "cobweb", "cobweb", "statuet", "statuet", "window",
  false,      "candles", "candles", "cobweb", "cobweb", "statue",  "statue",  "cobweb",
  "stage",    "candles", "skull",   "dooro",  "statue", "statue",  "statue",  "cobweb",
  "pot_1",    "pot_2",   "pot_3",   "plate",  "plate",  false,     false,     "cobweb",
  "pot_4",    "pot_5",   "pot_6",   "cloth",  "food",   "food",    "pfood",   "cobweb",
  "berriesp", "berries", "berries", "herbs",  "herbs",  "reeds",   "grassl",  "grassh",
  "berriesp", "berries", "berries", "bplate", "bplate", false,     "cobweb",  "cobweb",
  "mold",     "mold",    "mold",    "mold",   false,    false,     "cobweb",  "cobweb",
  false,      false,     false,     false,    false,    false,     "cobweb",  "cobweb",
  "bonef",    "bonef",   "bones",   "bones",  "bones",  false,     false,     false,
  "sign",
}, function(codename)
  local result = get_base(codename)
  result.boring_flag = true
  result.perspective_flag = is_in_perspective(codename)
  return result
end)

Ldump.mark(on_solids, "const", ...)
return on_solids
