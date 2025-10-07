local bad_trip = require("engine.tech.shaders.bad_trip")
local health = require("engine.mech.health")
local level = require("engine.tech.level")
local screenplay = require("engine.tech.screenplay")
local api = require("engine.tech.api")


local LONG_TIME = 600

return {
  --- @type scene|table
  _100_saving_likka = {
    enabled = true,
    mode = "sequential",

    characters = {
      likka = {},
      player = {},
    },

    start_predicate = function(self, dt, ch, ps)
      return (ps.sl_start - ch.player.position):abs2() <= 2
        and (not State.shader or getmetatable(State.shader) ~= bad_trip.mt)
    end,

    _first_time = true,
    _last_talked = nil,

    _initial_options = nil,

    run = function(self, ch, ps)
      self._last_talked = love.timer.getTime()

      local sp = screenplay.new("assets/screenplay/100_saving_likka.ms", ch)
        api.rotate(ch.player, ch.likka)
        api.move_camera(ps.sl_fall)

        sp:start_branches()
          if State.rails.likka_saw_bad_trip and State.period:once(self, "bad_trip") then
            sp:start_branch(1)
              api.rotate(ch.likka, ch.player)
              sp:lines()
            sp:finish_branch()
          elseif self._first_time then
            sp:start_branch(2)
              sp:lines()
              sp:start_single_branch(ch.player:ability_check("performance", 12) and 1 or 2)
                sp:lines()
              sp:finish_single_branch()
              api.rotate(ch.likka, ch.player)
              sp:lines()
            sp:finish_branch()
          elseif love.timer.getTime() - self._last_talked >= LONG_TIME then
            sp:start_branch(3)
              sp:lines()
            sp:finish_branch()
          else
            sp:start_branch(4)
              sp:lines()
            sp:finish_branch()
          end
          self._first_time = false
        sp:finish_branches()

        local options = sp:start_options()
        self._initial_options = self._initial_options or options
        while true do
          local n = api.options(self._initial_options)
          if n == 1 then
            self._initial_options[1] = nil
            sp:start_option(1)
              api.travel_scripted(ch.player, ps.sl_start):wait()
              -- NEXT! animate kneeling?
              sp:lines()
            sp:finish_option()
          elseif n == 2 then
            break
          else
            api.travel_scripted(ch.player, ch.player.position + Vector.up * 3):wait()
            return
          end
        end
        sp:finish_options()

        self.enabled = false
        api.travel_scripted(ch.player, ps.sl_start)
        sp:lines()  -- NEXT! animate player, blood, armor, ...

        api.options(sp:start_options())
        sp:finish_options()

        sp:lines()

        options = sp:start_options()
        while true do
          local n = api.options(options, true)

          sp:start_option(n)
          if n == 1 then
            sp:start_branches()
              if ch.player:ability_check("athletics", 12) then
                sp:start_branch(1)
                  sp:lines()
                sp:finish_branch()
              else
                sp:start_branch(2)
                  sp:lines()
                  level.unsafe_move(ch.player, ps.sl_fall)
                  health.damage(ch.player, 2)  -- NEXT! animate lying
                  sp:lines()
                sp:finish_branch()

                sp:finish_branches()
                break
              end
            sp:finish_branches()
          elseif n == 2 then
            sp:lines()

            local success = ch.player:ability_check("acrobatics", 12)
            level.unsafe_move(ch.player, ps.sl_fall)
            if not success then health.damage(ch.player, 1) end

            sp:start_single_branch(success and 1 or 2)
              sp:lines()
            sp:finish_single_branch()

            sp:finish_option()
            break
          else
            sp:lines()
          end
          sp:finish_option()
        end
        sp:finish_options()

        sp:lines()
        sp:start_single_branch(ch.player:ability_check("performance", 12) and 1 or 2)
          sp:lines()
        sp:finish_single_branch()
      sp:finish()
    end,
  },
}
