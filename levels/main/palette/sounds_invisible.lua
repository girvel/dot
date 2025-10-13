local sound = require("engine.tech.sound")


local sounds_invisible = {}

for i = 1, 3 do
  local name = "birds_" .. i
  sounds_invisible[name] = function()
    return sound.source("assets/sounds/" .. name, .2, "medium")
  end
end

Ldump.mark(sounds_invisible, "const", ...)
return sounds_invisible
