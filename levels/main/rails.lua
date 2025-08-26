local rails = {}

--- @class rails
--- @field runner rails_runner
local methods = {}
local mt = {__index = methods}

--- @param runner rails_runner
--- @return rails
rails.new = function(runner)
  return setmetatable({
    runner = runner
  }, mt)
end

Ldump.mark(rails, {}, ...)
return rails
