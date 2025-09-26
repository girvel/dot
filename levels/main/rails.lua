local api = require "engine.tech.api"
local rails = {}

--- @alias rails_location "0_intro"|"1_upper_village"?

--- @class rails
--- @field runner rails_runner
--- @field location rails_location
--- @field feast "started"|"weapon_found"|"return_weapon"|"ceremony"
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
  Log.info("Location transition", self.location, "->", location)

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
    :next(function() ch.red_priest:rotate(Vector.up) end)
end

local feast_base = {
  name = "Празднование",
  objectives = {
    {status = "new", text = "Взять оружие"},
    {status = "new", text = "Присоединиться к церемонии"},
  },
}

methods.feast_start = function(self)
  self.feast = "started"
  State.quests.items.feast = feast_base
  api.journal_update("new_task")
end

--- @param forced boolean?
methods.feast_weapon_found = function(self, forced)
  if forced then
    State.quests.items.feast = feast_base
  else
    assert(self.feast == "started")
  end
  State.quests.items.feast.objectives[1].status = "done"
  api.journal_update("task_completed")
end

Ldump.mark(rails, {}, ...)
return rails
