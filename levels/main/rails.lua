local rails = {}

--- @alias rails_location "0_intro"|"1_upper_village"?

--- @class rails
--- @field runner rails_runner
--- @field location rails_location
local methods = {}
local mt = {__index = methods}

--- @param runner rails_runner
--- @return rails
rails.new = function(runner)
  return setmetatable({
    runner = runner,
    location = nil,
  }, mt)
end

local scenes_by_location = {
  ["0_intro"] = require("levels.main.scenes.0_intro.010_intro"),
  ["1_upper_village"] = Table.join({},
    require("levels.main.scenes.1_upper_village.011_exiting_house"),
    require("levels.main.scenes.1_upper_village.018_getting_sword"),
    require("levels.main.scenes.1_upper_village.loc")
  ),
}

--- @param location rails_location
--- @param forced boolean?
methods._location_transition = function(self, location, forced)
  assert(
    forced
      or self.location == nil and location and location:sub(1, 1) == "0"
      or location and self.location and location:sub(1, 1) == self.location:sub(1, 1) + 1,
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
  self:_location_transition("0_intro", forced)
end

--- @param forced boolean?
methods.location_upper_village = function(self, forced)
  self:_location_transition("1_upper_village", forced)
end

Ldump.mark(rails, {}, ...)
return rails
