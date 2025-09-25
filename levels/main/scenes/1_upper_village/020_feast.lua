local level = require("engine.tech.level")
local async = require("engine.tech.async")
local actions = require("engine.mech.actions")
local screenplay = require "engine.tech.screenplay"
local api        = require "engine.tech.api"


--- @param inviter entity
--- @param invitee entity
--- @param left_corner vector
--- @param passes_n integer
--- @return promise, scene
local dance = function(inviter, invitee, left_corner, passes_n)
  return State.rails.runner:run_task(function()
    api.travel_scripted(inviter, invitee.position):await()
    api.rotate(inviter, invitee)
    async.sleep(.3)
    api.rotate(invitee, inviter)
    async.sleep(1)

    do
      local t1 = api.travel_scripted(inviter, left_corner)
      local t2 = api.travel_scripted(invitee, left_corner + Vector.right)

      t1:await()
      t2:await()

      -- two moving people, sometimes one stops one cell short,
      -- thinking the other one is an immovable solid
      level.unsafe_move(inviter, left_corner)
      level.unsafe_move(invitee, left_corner + Vector.right)

      api.rotate(inviter, invitee)
      api.rotate(invitee, inviter)
    end

    for _ = 1, passes_n do
      -- TODO more complex dance
      -- TODO stabilize invitee/inviter positions on the beginning of each pass
      local sec = math.floor(love.timer.getTime())
      while love.timer.getTime() - sec < 1 do coroutine.yield() end
      actions.move(Vector.right):act(invitee)
      actions.move(Vector.right):act(inviter)
      invitee:rotate(Vector.left)

      sec = math.floor(love.timer.getTime())
      while love.timer.getTime() - sec < 1 do coroutine.yield() end
      actions.move(Vector.left):act(inviter)
      actions.move(Vector.left):act(invitee)
      inviter:rotate(Vector.right)
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
        ch.player:rotate(Vector.down)
        api.move_camera(State.rails.runner.positions.feast_camera)

        sp:lines()

        local give_fruit = function(receiver_name)
          api.travel_scripted(ch.green_priest, ch[receiver_name].position):await()
          api.rotate(ch.green_priest, ch[receiver_name])
          async.sleep(.2)
          api.rotate(ch[receiver_name], ch.green_priest)
          async.sleep(.3)
        end

        local task = State.rails.runner:run_task(function()
          give_fruit("boy_1")
          give_fruit("boy_2")
          give_fruit("boy_3")
        end)
        sp:lines()
        task:await()

        task = api.travel_scripted(ch.green_priest, State.rails.runner.positions.green_priest_feast)
          :next(function() ch.green_priest:rotate(Vector.up) end)

        local task_1 = dance(ch.girl_1, ch.boy_1, State.rails.runner.positions.dance_1, 10)
        local task_2 = dance(ch.girl_2, ch.boy_2, State.rails.runner.positions.dance_2, 10)
        local task_3 = dance(ch.girl_3, ch.boy_3, State.rails.runner.positions.dance_3, 10)
        sp:lines()
        task_1:await()
        task_2:await()
        task_3:await()

        task:await()
      sp:finish()
    end,
  },
}
