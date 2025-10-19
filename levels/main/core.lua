local api = require("engine.tech.api")
local core = {}

core.bring_likka = function()
  local ch = State.runner.entities
  if not api.is_visible(ch.likka) then
    api.travel_scripted(ch.likka, ch.player.position, 8):wait()
  end
end

Ldump.mark(core, {}, ...)
return core
