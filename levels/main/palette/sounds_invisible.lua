local sound = require("engine.tech.sound")


local sounds_invisible = {}

sounds_invisible.birds_1 = function()
  return sound.source("assets/sounds/birds_1", .2, "medium")
end

return sounds_invisible
