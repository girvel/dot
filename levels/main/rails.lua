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
methods._location_transition = function(self, location)
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

methods.location_intro = function(self)
  self:_location_transition("0_intro")
end

methods.location_upper_village = function(self)
  self:_location_transition("1_upper_village")
end

Ldump.mark(rails, {}, ...)
return rails
