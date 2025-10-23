local api = require("engine.tech.api")
local item = require("engine.tech.item")
local interactive = require("engine.tech.interactive")


local core = {}

core.bring_likka = function()
  local ch = State.runner.entities
  if State:exists(ch.likka) and not api.is_visible(ch.likka) then
    api.travel_scripted(ch.likka, ch.player.position, 8):wait()
  end
end

--- @param entity entity
--- @param name string
core.activator = function(entity, name)
  State:add(entity, interactive.mixin(), {name = name})
  item.set_cue(entity, "highlight", true)
end

--- @param position vector
--- @param ... item
core.drops = function(position, ...)
  if not item.drops(position, ...) == select("#", ...) then
    Log.warn("Item drop missed at %s", position)
  end
end

Ldump.mark(core, {}, ...)
return core
