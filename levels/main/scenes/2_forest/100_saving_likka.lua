local async = require("engine.tech.async")
local bad_trip = require("engine.tech.shaders.bad_trip")
local health = require("engine.mech.health")
local level = require("engine.tech.level")
local screenplay = require("engine.tech.screenplay")
local api = require("engine.tech.api")


local LONG_TIME = 600

return {
  --- @type scene
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
        sp:lines()

        local hand, offhand do
          level.remove(ch.player)
          ch.player.position = ps.sl_start + Vector.down
          ch.player.grid_layer = "on_solids"
          ch.player:rotate(Vector.up)
          level.put(ch.player)

          ch.player:animate("hanging", false, true)

          hand = ch.player.inventory.hand
          offhand = ch.player.inventory.offhand
          ch.player.inventory.hand = nil
          ch.player.inventory.offhand = nil
        end
        sp:lines()

        ch.player:rotate(Vector.right)
        sp:lines()

        ch.player:rotate(Vector.up)
        sp:lines()

        api.options(sp:start_options())
        sp:finish_options()

        sp:lines()

        local get_down = function()
          level.remove(ch.player)
          ch.player.position = ps.sl_fall
          ch.player.grid_layer = "solids"
          level.put(ch.player)

          ch.player:animate("idle", false, true)

          ch.player.inventory.hand = hand
          ch.player.inventory.offhand = offhand
        end

        options = sp:start_options()
        local quit
        while not quit do
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

                  get_down()
                  -- no lying animation, because lying fucks up items anchoring
                  health.damage(ch.player, 2)
                  sp:lines()
                sp:finish_branch()

                quit = true
              end
            sp:finish_branches()
          elseif n == 2 then
            local success = ch.player:ability_check("acrobatics", 12)
            sp:lines()

            get_down()
            if not success then health.damage(ch.player, 1) end

            sp:start_single_branch(success and 1 or 2)
              sp:lines()
            sp:finish_single_branch()

            quit = true
          else
            sp:lines()
          end
          sp:finish_option()
        end
        sp:finish_options()

        api.rotate(ch.player, ch.likka)
        sp:lines()
        local success = ch.player:ability_check("performance", 12)
        sp:start_single_branch(success and 1 or 2)
          if not success then async.sleep(1.5) end
          sp:lines()
        sp:finish_single_branch()

        State.rails:temple_enter()
        State.rails:empathy_start_conversation()
      sp:finish()
    end,
  },
}
