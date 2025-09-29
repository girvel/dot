local sound = require("engine.tech.sound")


local sounds_invisible = {}

sounds_invisible.birds_1 = function()
  return sound.source("assets/sounds/birds_1", .2, "medium")
end

Ldump.mark(sounds_invisible, "const", ...)
return sounds_invisible
