local solids_entities = require("levels.main.palette.solids_entities")
local api = require "engine.tech.api"
local winter = require "engine.tech.shaders.winter"


local rails = {}

--- @alias rails_location "0_intro"|"1_upper_village"|"2_forest"?

--- @class rails
--- @field runner rails_runner
--- @field location rails_location
--- @field feast "started"|"weapon_found"|"ceremony"|"done"?
--- @field winter "initialized"|"ended"?
--- @field seekers "started"?
local methods = {}
local mt = {__index = methods}

--- @param runner rails_runner
--- @return rails
rails.new = function(runner)
  return setmetatable({
    runner = runner,
  }, mt)
end

local scenes_by_location do
  scenes_by_location = {}
  local scenes_folder = Table.require_folder("levels.main.scenes")
  for k, subfolder in pairs(scenes_folder) do
    scenes_by_location[k] = {}
    for _, v in pairs(subfolder) do
      Table.join(scenes_by_location[k], v)
    end
  end
end

--- @param location rails_location
--- @param forced boolean?
methods._location_transition = function(self, location, forced)
  assert(
    forced
      or self.location == nil and location and location:sub(1, 1) == "0"
      or location and self.location
        and tonumber(location:sub(1, 1)) - tonumber(self.location:sub(1, 1)) == 1,
    ("Out of order transition %s -> %s"):format(self.location, location)
  )
  Log.info("Location transition %s -> %s", self.location, location)

  if self.location then
    for _, v in pairs(scenes_by_location[self.location]) do
      -- doesn't stop scenes
      Table.remove_pair(self.runner.scenes, v)
    end
  end

  Table.join(self.runner.scenes, scenes_by_location[location])
  self.location = location
end

--- @param forced boolean?
methods.location_intro = function(self, forced)
  api.autosave("Начало")
  self:_location_transition("0_intro", forced)
end

--- @param forced boolean?
methods.location_upper_village = function(self, forced)
  api.autosave("Церемония")
  self:_location_transition("1_upper_village", forced)

  local ch = Runner.entities
  api.travel_scripted(ch.khaned, Runner.positions.ceremony_khaned)
  api.travel_scripted(ch.likka,  Runner.positions.ceremony_likka)
  api.travel_scripted(ch.red_priest, Runner.positions.ceremony_red_priest)
end

--- @param forced boolean?
methods.location_forest = function(self, forced)
  api.autosave("Лес")
  self:_location_transition("2_forest", forced)

  local ch = Runner.entities
  local ps = Runner.positions
  api.assert_position(ch.khaned, ps.sk_khaned)
  api.assert_position(ch.likka, ps.sl_likka)
end

local snow = {}

methods.winter_init = function(self)
  assert(self.winter == nil)

  State.shader = winter
  snow = State.grids.on_tiles:iter():filter(function(e) return e.winter_flag end):totable()
  self.winter = "initialized"

  Log.info("Winter initialized")
end

methods.winter_end = function(self)
  assert(self.winter == "initialized")

  for _, e in ipairs(snow) do
    State:add(e, {life_time = Random.float(0, 30)})
  end

  local ps = Runner.positions
  local start = ps.create_water_start
  local finish = ps.create_water_finish
  for x = start.x, finish.x do
    for y = start.y, finish.y do
      if not State.grids.solids:unsafe_get(x, y) then
        State:add(solids_entities.water(), {position = V(x, y), grid_layer = "solids"})
      end
    end
  end

  State.shader = nil
  self.winter = "ended"

  Log.info("Winter ends")
end

local feast_base = {
  name = "Празднование",
  objectives = {
    {status = "new", text = "Взять оружие"},
    {status = "new", text = "Присоединиться к церемонии"},
  },
}

methods.feast_start = function(self)
  assert(self.feast == nil)
  self.feast = "started"
  State.quests.items.feast = feast_base
  api.journal_update("new_task")
end

methods.feast_end = function(self)
  assert(self.feast == "started" or self.feast == "weapon_found")
  self.feast = "done"
  for _, o in ipairs(State.quests.items.feast.objectives) do
    o.status = "done"
  end
  api.journal_update("task_completed")
end

methods.feast_weapon_found = function(self)
  assert(self.feast == "started")
  State.quests.items.feast.objectives[1].status = "done"
  api.journal_update("task_completed")
end

local seekers_base = {
  name = "Искатели",
  objectives = {
    {status = "new", text = "Найти плод дерева Акуль"},
  },
}

methods.seekers_start = function(self)
  assert(self.seekers == nil)
  State.quests.items.seekers = seekers_base
  self.seekers = "started"
  api.journal_update("new_task")
end

Ldump.mark(rails, {}, ...)
return rails
