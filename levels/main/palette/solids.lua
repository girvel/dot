local health = require("engine.mech.health")
local on_solids = require("levels.main.palette.on_solids")
local factoring = require("engine.tech.factoring")
local interactive = require("engine.tech.interactive")

local solids

local lows = {
  "stool", "godfruit", "slope", "stage", "statue", "table", "chest", "bush", "bed", "fence",
  "candles", "hutwallt", "cabinet", "shelf", "log", "campfire", "scabinet", "sshelf", "sbin",
  "cobweb",
}

--- @param codename string
local is_low = function(codename)
  for _, prefix in ipairs(lows) do
    if codename:starts_with(prefix) then return true end
  end
  return false
end

local open_door = function(self)
  self.on_remove = function(self)
    State:add(on_solids.dooro(), {position = self.position, grid_layer = "on_solids"})
  end
  State:remove(self)
end

local open_solid = function(name)
  return function(self)
    self.on_remove = function(self)
      State:add(solids[name](), {position = self.position, grid_layer = "solids"})
    end
    State:remove(self)
  end
end

local get_base = function(codename)
  if codename == "doorc" then
    local result = interactive.mixin(open_door)
    result.name = "дверь"
    return result
  elseif codename == "chestc" then
    local result = interactive.mixin(open_solid("chesto"))
    result.name = "сундук"
    return result
  elseif codename == "shelfc" then
    local result = interactive.mixin(open_solid("shelfo"))
    result.name = "полки"
    return result
  elseif codename == "cabinetc" then
    local result = interactive.mixin(open_solid("cabineto"))
    result.name = "шкаф"
    return result
  elseif codename == "sshelfc" then
    local result = interactive.mixin(open_solid("sshelfo"))
    result.name = "полки"
    return result
  elseif codename == "scabinetc" then
    local result = interactive.mixin(open_solid("scabineto"))
    result.name = "шкаф"
    return result
  elseif codename == "sbinc" then
    local result = interactive.mixin(open_solid("sbino"))
    result.name = "урна"
    return result
  elseif codename == "cobweb" then
    return {
      hp = 1,
      _cobweb_flag = true,
      on_death = function(self)
        for _, d in ipairs(Vector.directions) do
          local e = State.grids[self.grid_layer]:slow_get(self.position + d)
          if e and e._cobweb_flag and e.hp > 0 then
            health.damage(e, 1)
          end
        end
      end,
    }
  elseif codename == "trunk" then
    return {_tree_flag = true}
  else
    return {}
  end
end

solids = factoring.from_atlas(
  "assets/sprites/atlases/solids.png", Constants.cell_size,
  {
    "wall",     "wall",     "wall",     "wall",   "hutwall",   "hutwall",   "hutwall", "hutwall",
    "wall",     "wall",     "wall",     "wall",   "hutwall",   "hutwall",   "hutwall", "hutwall",
    "wall",     "wall",     "wall",     "wall",   "hutwall",   "hutwall",   "hutwall", "hutwall",
    "wall",     "wall",     "wall",     "wall",   "hutwall",   "hutwall",   "hutwall", "hutwall",
    "slope",    "slope",    "godfruit", "trunk",  "trunk",     "bush",      "bush",    "bbush",
    "slope",    "slope",    "slope",    "trunk",  "trunk",     "bush",      "bush",    "bbush",
    "slope_h",  "slope",    "stool",    "trunk",  "trunk",     "rock",      "rock",    "table",
    false,      "slope",    "slope",    "statue", "statue",    "statue",    "statue",  "table",
    false,      "slope",    "slope",    false,    "table",     "table",     "table",   "table",
    "owall",    "owall",    "owall",    "owall",  false,       "chestc",    "chesto",  "table",
    "owall",    "owall",    "owall",    "owall",  false,       "bed",       "bed",     false,
    "owall",    "owall",    "owall",    "owall",  "candles",   "candles",   "candles", false,
    "owall",    "owall",    "owall",    "owall",  "doorc",     false,       false,     false,
    "stage",    "stage",    "stage",    "stage",  "fence",     "fence",     "fence",   "fence",
    "stage",    "stage",    "stage",    "stage",  "fence",     "fence",     "fence",   "fence",
    "stage",    "stage",    "stage",    "stage",  "fence",     "fence",     "fence",   "fence",
    "stage",    "stage",    "stage",    "stage",  "fence",     "fence",     "fence",   "fence",
    "cabinetc", "cabineto", "shelfc",   "shelfo", "hutwallt",  "hutwallt",  "rubble",  "campfire",
    "log",      "log",      "log",      "cobweb", "scabinetc", "scabineto", "sshelfc", "shelfo",
    "log",      "cobweb",   "cobweb",   "cobweb", false,        false,      "sbinc",   "sbino",
    "log",      false,      false,      false,    false,        false,      false,     false,
    "log",      false,      false,      false,    false,        false,      false,     false,
  },
  function(codename)
    local result = get_base(codename)
    result.transparent_flag = is_low(codename)
    result.low_flag = is_low(codename)
    result.boring_flag = true
    return result
  end
)

Ldump.mark(solids, "const", ...)
return solids
