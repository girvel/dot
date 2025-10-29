local rogue = require("engine.mech.class.rogue")
local async = require("engine.tech.async")
local api = require("engine.tech.api")


local likka_ai = {}

--- @class likka_ai: ai_strict
--- @field _combat_component combat_ai
--- @field _last_action_t number
--- @field _was_in_combat boolean
local methods = {}
likka_ai.mt = {__index = methods}

--- @param combat_ai combat_ai
--- @return likka_ai: ai
likka_ai.new = function(combat_ai)
  return setmetatable({
    _combat_component = combat_ai,
    _last_action_t = love.timer.getTime(),
    _was_in_combat = false,
  }, likka_ai.mt)
end

local NEUTRAL_DISTANCE = 4
local ADHD_PERIOD = 15

local needs_travel = function(likka)
  local distance = (likka.position - State.player.position):abs2()
  return distance <= 1 or distance > NEUTRAL_DISTANCE
end

methods.init = function(self, entity)
  return self._combat_component:init(entity)
end

methods.deinit = function(self, entity)
  return self._combat_component:deinit(entity)
end

methods.control = function(self, entity)
  if State.combat then
    self._was_in_combat = State:in_combat(entity)
    return self._combat_component:control(entity)
  end

  if self._was_in_combat then
    self._was_in_combat = false
    async.sleep(Random.float(.3, .7))
    rogue.hit_dice:act(entity)
  end

  if State.hostility:get(self, State.player) == "enemy" then return end

  if needs_travel(entity) then
    async.sleep(Random.float(.05, .15))

    local target = State.player.position
    local norm = (target - entity.position):normalized2()
    local shift = norm:rotate()

    for _, offset in ipairs {Vector.zero, shift, -shift} do
      local path = api.build_path(entity.position, target - norm * 2 + offset)
      if path then
        api.follow_path(entity, path, false, 10)
        if not needs_travel(entity) then
          async.sleep(Random.float(.1, .2))
          api.rotate(entity, State.player)
        end
        self._last_action_t = love.timer.getTime()
        break
      end
    end
  end

  if love.timer.getTime() - self._last_action_t >= ADHD_PERIOD
    and State.period:absolute(1, self, "ADHD")
    and Random.chance(.3)
  then
    self._last_action_t = love.timer.getTime()
    entity:rotate(Random.item(Vector.directions))
    async.sleep(Random.float(.5, 3))
    entity:rotate(Random.item(Vector.directions))
  end
end

--- Deliberately no .observe, Likka should not start fights

Ldump.mark(likka_ai, {mt = "const"}, ...)
return likka_ai
