local sound = require("engine.tech.sound")
local health = require("engine.mech.health")
local on_solids = require("levels.main.palette.on_solids")
local factoring = require("engine.tech.factoring")
local interactive = require("engine.tech.interactive")
local async       = require("engine.tech.async")

local solids

local lows = {
  "stool", "godfruit", "slope", "stage", "statue", "table", "chest", "bush", "bed", "fence",
  "candles", "hutwallt", "cabinet", "shelf", "log", "campfire", "scabinet", "sshelf", "sbin",
  "cobweb",
}

local opening_sounds = {
  cabineto = sound.multiple("assets/sounds/cabinet/open", .8),
  chesto   = sound.multiple("assets/sounds/chest/open"),
}

opening_sounds.shelfo = opening_sounds.cabineto
opening_sounds.sshelfo = opening_sounds.cabineto
opening_sounds.scabineto = opening_sounds.cabineto
opening_sounds.schesto = opening_sounds.chesto

--- @param codename string
local is_low = function(codename)
  for _, prefix in ipairs(lows) do
    if codename:starts_with(prefix) then return true end
  end
  return false
end

--- @param codename string
local is_container = function(codename)
  for _, suffix in ipairs {"cabinetc", "shelfc", "binc", "chestc"} do
    if codename:find(suffix, 1, true) then return true end
  end
  return nil
end

local names = {
  godfruit = "плод дерева Акуль",
  godfruitr = "гниющий плод",
}

local open = Memoize(function(name, target_layer)
  local sounds = opening_sounds[name]
  local create_open
  if target_layer then
    assert(target_layer == "on_solids")
    create_open = on_solids[name]
  else
    create_open = solids[name]
  end

  return function(self)
    local open_itself = function()
      State:remove(self)
      State:add(create_open(), {
        position = self.position,
        grid_layer = target_layer or self.grid_layer
      })
    end

    local _, scene = State.runner:run_task(function()
      if sounds then
        sounds:play_at(self.position)
      end
      async.sleep(.18)
      open_itself()
    end)
    scene.on_cancel = open_itself
  end
end)

local get_base = function(codename)
  if codename == "doorc" then
    local result = interactive.mixin(open("dooro", "on_solids"))
    result.name = "дверь"
    return result
  elseif codename == "chestc" then
    local result = interactive.mixin(open("chesto"))
    result.name = "сундук"
    return result
  elseif codename == "shelfc" then
    local result = interactive.mixin(open("shelfo"))
    result.name = "полки"
    return result
  elseif codename == "cabinetc" then
    local result = interactive.mixin(open("cabineto"))
    result.name = "шкаф"
    return result
  elseif codename == "sshelfc" then
    local result = interactive.mixin(open("sshelfo"))
    result.name = "полки"
    return result
  elseif codename == "scabinetc" then
    local result = interactive.mixin(open("scabineto"))
    result.name = "шкаф"
    return result
  elseif codename == "sbinc" then
    local result = interactive.mixin(open("sbino"))
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
    "wall",      "wall",     "wall",     "wall",   "hutwall",   "hutwall",   "hutwall", "hutwall",
    "wall",      "wall",     "wall",     "wall",   "hutwall",   "hutwall",   "hutwall", "hutwall",
    "wall",      "wall",     "wall",     "wall",   "hutwall",   "hutwall",   "hutwall", "hutwall",
    "wall",      "wall",     "wall",     "wall",   "hutwall",   "hutwall",   "hutwall", "hutwall",
    "slope",     "slope",    "godfruit", "trunk",  "trunk",     "bush",      "bush",    "bbush",
    "slope",     "slope",    "slope",    "trunk",  "trunk",     "bush",      "bush",    "bbush",
    "slope_h",   "slope",    "stool",    "trunk",  "trunk",     "rock",      "rock",    "table",
    "godfruitr", "slope",    "slope",    "statue", "statue",    "statue",    "statue",  "table",
    false,       "slope",    "slope",    false,    "table",     "table",     "table",   "table",
    "owall",     "owall",    "owall",    "owall",  false,       "chestc",    "chesto",  "table",
    "owall",     "owall",    "owall",    "owall",  false,       "bed",       "bed",     false,
    "owall",     "owall",    "owall",    "owall",  "candles",   "candles",   "candles", false,
    "owall",     "owall",    "owall",    "owall",  "doorc",     false,       false,     false,
    "stage",     "stage",    "stage",    "stage",  "fence",     "fence",     "fence",   "fence",
    "stage",     "stage",    "stage",    "stage",  "fence",     "fence",     "fence",   "fence",
    "stage",     "stage",    "stage",    "stage",  "fence",     "fence",     "fence",   "fence",
    "stage",     "stage",    "stage",    "stage",  "fence",     "fence",     "fence",   "fence",
    "cabinetc",  "cabineto", "shelfc",   "shelfo", "hutwallt",  "hutwallt",  "rubble",  "campfire",
    "log",       "log",      "log",      "cobweb", "scabinetc", "scabineto", "sshelfc", "sshelfo",
    "log",       "cobweb",   "cobweb",   "cobweb", "cobweb",    "cobweb",    "sbinc",   "sbino",
    "log",       false,      false,      false,    false,       false,       false,     false,
    "log",       false,      false,      false,    false,       false,       false,     false,
  },
  function(codename)
    local result = get_base(codename)
    result.transparent_flag = is_low(codename)
    result.low_flag = is_low(codename)
    result.boring_flag = true
    result._is_container = is_container(codename)
    result.name = names[codename]
    return result
  end
)

Ldump.mark(solids, "const", ...)
return solids
