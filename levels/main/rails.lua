local rails = {}

--- @class rails
--- @field runner rails_runner
--- @field location "0_intro"|"1_upper_village"
local methods = {}
local mt = {__index = methods}

--- @param runner rails_runner
--- @return rails
rails.new = function(runner)
  return setmetatable({
    runner = runner,
    location = "0_intro",
  }, mt)
end

methods.location_upper_village = function(self)
  self.location = "1_upper_village"

  local scenes = self.runner.scenes
  for k, v in pairs(scenes) do
    if type(k) == "string" and k:starts_with("loc_1") then
      v.enabled = true
    end
  end

  scenes._011_exiting_house.enabled = true
end

Ldump.mark(rails, {}, ...)
return rails
