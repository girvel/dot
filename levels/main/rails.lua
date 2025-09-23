local rails = {}

--- @class rails
--- @field runner rails_runner
--- @field location "0_intro"|"1_upper_village"?
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

local intro_scenes = require("levels.main.scenes.0_intro.010_intro")

methods.location_intro = function(self)
  Log.info("Transitioning to location intro")
  assert(self.location == nil)
  self.location = "0_intro"
  Table.join(self.runner.scenes, intro_scenes)
end

local upper_village_scenes = Table.join({},
  require("levels.main.scenes.1_upper_village.011_exiting_house"),
  require("levels.main.scenes.1_upper_village.018_getting_sword"),
  require("levels.main.scenes.1_upper_village.loc")
)

methods.location_upper_village = function(self)
  Log.info("Transitioning to location upper village")
  assert(self.location == "0_intro")
  self.location = "1_upper_village"

  for k, v in pairs(intro_scenes) do
    -- doesn't stop scenes
    Table.remove_pair(self.runner.scenes, v)
  end

  Table.join(self.runner.scenes, upper_village_scenes)
end

Ldump.mark(rails, {}, ...)
return rails
