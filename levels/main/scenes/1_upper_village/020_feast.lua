local async = require("engine.tech.async")
local actions = require("engine.mech.actions")
local screenplay = require "engine.tech.screenplay"
local api        = require "engine.tech.api"


--- @param inviter entity
--- @param invitee entity
--- @param left_corner vector
--- @return promise, scene
local dance = function(inviter, invitee, left_corner)
  return State.rails.runner:run_task(function()
    local t1 = api.travel_scripted(inviter, left_corner)
    local t2 = api.travel_scripted(invitee, left_corner + Vector.right)

    t1:await()
    t2:await()

    for _ = 1, 10 do
      -- NEXT! sync dances
      -- NEXT! more complex dance
      async.sleep(1)
      actions.move(Vector.right):act(invitee)
      actions.move(Vector.right):act(inviter)

      async.sleep(1)
      actions.move(Vector.left):act(inviter)
      actions.move(Vector.left):act(invitee)
    end
  end)
end

return {
  _020_feast = {
    enabled = true,

    characters = {
      player = {},
      green_priest = {},
      boy_1 = {},
      boy_2 = {},
      boy_3 = {},
      girl_1 = {},
      girl_2 = {},
      girl_3 = {},
    },

    --- @param self scene
    --- @param dt number
    --- @param ch rails_characters
    start_predicate = function(self, dt, ch)
      return ch.player.position >= State.rails.runner.positions.feast_start
        and ch.player.position <= State.rails.runner.positions.feast_finish
    end,

    --- @param self scene
    --- @param ch rails_characters
    run = function(self, ch)
      local sp = screenplay.new("assets/screenplay/020_feast.ms", ch)
        api.travel_scripted(ch.player, State.rails.runner.positions.feast_observe):await()
        api.move_camera(State.rails.runner.positions.feast_camera)

        sp:lines()

        local task = State.rails.runner:run_task(function()
          api.travel_scripted(ch.green_priest, ch.boy_1.position):await()
          api.travel_scripted(ch.green_priest, ch.boy_2.position):await()
          api.travel_scripted(ch.green_priest, ch.boy_3.position):await()
        end)
        sp:lines()
        task:await()

        task = dance(ch.girl_1, ch.boy_1, State.rails.runner.positions.dance_1)
        sp:lines()
        task:await()
      sp:finish()
    end,
  },
}
