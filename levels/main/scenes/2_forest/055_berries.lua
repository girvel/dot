local bad_trip = require("engine.tech.shaders.bad_trip")
local async = require("engine.tech.async")
local screenplay = require("engine.tech.screenplay")
local interactive = require("engine.tech.interactive")


return {
  --- @type scene|table
  _055_berries = {
    enabled = true,
    characters = {
      player = {},
    },

    _berries = nil,
    on_add = function(self)
      self._berries = State.grids.on_solids:iter()
        :filter(function(e) return e.codename == "berriesp" end)
        :totable()

      for _, b in ipairs(self._berries) do
        State:add(b, interactive.mixin(function(self_entity)
          local scene = State.runner.scenes._055_berries
          if scene then scene.berry = self_entity end
        end), {name = "ягоды"})
      end
    end,

    berry = nil,
    start_predicate = function(self, dt, ch, ps)
      return self.berry
    end,

    run = function(self, ch, ps)
      local sp = screenplay.new("assets/screenplay/055_berries.ms", ch)
        sp:start_branches()
          local ate_berries
          if not State.rails.tried_berries then
            if State.runner.scenes.eating_berries_1:run(ch, ps) then
              ate_berries = true
              State.rails.tried_berries = "once"
            end
          else
            assert(State.rails.tried_berries == "once")
            sp:start_branch(2)
              sp:lines()
            sp:finish_branch()
            if State.runner.scenes.eating_berries_2:run(ch, ps) then
              ate_berries = true
              State.rails.tried_berries = "twice"
            end
          end
        sp:finish_branches()
      sp:finish()

      if not ate_berries then return end

      for _, b in ipairs(self._berries) do
        b.interact = nil
      end

      State.runner.locked_entities[ch.player] = nil

      local DURATION = 60
      State.shader = bad_trip.new(DURATION)
      async.sleep(DURATION)
      if getmetatable(State.shader) == bad_trip.mt then
        State.shader = nil
      end
    end,

    on_cancel = function(self)
      State.shader = nil
    end,
  },
}
