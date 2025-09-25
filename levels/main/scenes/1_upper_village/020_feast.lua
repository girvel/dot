local projectile = require("engine.tech.projectile")
local animated = require("engine.tech.animated")
local level = require("engine.tech.level")
local async = require("engine.tech.async")
local actions = require("engine.mech.actions")
local screenplay = require "engine.tech.screenplay"
local api        = require "engine.tech.api"
local item       = require "engine.tech.item"


--- @param inviter entity
--- @param invitee entity
--- @param left_corner vector
--- @param passes_n integer
--- @return promise, scene
local dance = function(inviter, invitee, left_corner, passes_n)
  -- really not a strict implementation of the simplistic idea I had in mind
  -- but this looks even better
  return State.rails.runner:run_task(function()
    api.travel_scripted(inviter, invitee.position):await()
    api.rotate(inviter, invitee)
    async.sleep(.3)
    api.rotate(invitee, inviter)
    async.sleep(1)

    for _ = 1, passes_n do
      -- both stabilization & traveling to the starting positions
      local t1 = api.travel_scripted(inviter, left_corner)
      local t2 = api.travel_scripted(invitee, left_corner + Vector.right)

      t1:await()
      t2:await()

      api.rotate(inviter, invitee)
      api.rotate(invitee, inviter)

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

--- @return item
local snowball_new = function()
  return Table.extend(
    animated.mixin("assets/sprites/animations/snowball"),
    item.mixin_min("hand"),
    {
      codename = "snowball",
      boring_flag = true,
    }
  )
end

--- @param thrower entity
--- @param position vector
--- @return promise, scene
local throw_snow = function(thrower, position)
  local pyre_position = State.rails.runner.positions.feast_pyre + V(.5, -.25)

  return State.rails.runner:run_task(function()
    api.travel_scripted(thrower, position):await()
    async.sleep(.2)
    thrower:rotate((pyre_position - position):normalized2())
    async.sleep(.3)

    local snowball = State:add(snowball_new())
    thrower.inventory.hand = snowball
    thrower:animate("throw", true):next(function()
      projectile.launch(thrower, "hand", pyre_position, 14)
    end):await()
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
      thrower_1 = {},
      thrower_2 = {},
      thrower_3 = {},
      thrower_4 = {},
      thrower_5 = {},
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
        api.travel_scripted(ch.player, State.rails.runner.positions.feast_observe)
        ch.player:rotate(Vector.down)
        api.move_camera(State.rails.runner.positions.feast_camera):await()

        local give_fruit = function(receiver_name)
          api.travel_scripted(ch.green_priest, ch[receiver_name].position):await()
          api.rotate(ch.green_priest, ch[receiver_name])
          async.sleep(.2)
          api.rotate(ch[receiver_name], ch.green_priest)
          async.sleep(.3)
        end

        local priest_task = State.rails.runner:run_task(function()
          give_fruit("boy_1")
          give_fruit("boy_2")
          give_fruit("boy_3")
        end)

        sp:lines()  -- don't wait for narration to start priest movement
        sp:lines()
        priest_task:await()

        priest_task = api.travel_scripted(
          ch.green_priest, State.rails.runner.positions.feast_green_priest
        ):next(function() ch.green_priest:rotate(Vector.up) end)

        local dancing = Promise.all(
          dance(ch.girl_1, ch.boy_1, State.rails.runner.positions.dance_1, 10),
          dance(ch.girl_2, ch.boy_2, State.rails.runner.positions.dance_2, 10),
          dance(ch.girl_3, ch.boy_3, State.rails.runner.positions.dance_3, 10)
        )
        sp:lines()

        priest_task:await()

        priest_task = throw_snow(ch.green_priest, State.rails.runner.positions.feast_throw_priest)
        sp:lines()
        priest_task:await()
        async.sleep(.5)

        local snowballs = Promise.all(
          throw_snow(ch.thrower_1, State.rails.runner.positions.feast_throw_1),
          throw_snow(ch.thrower_2, State.rails.runner.positions.feast_throw_2),
          throw_snow(ch.thrower_3, State.rails.runner.positions.feast_throw_3),
          throw_snow(ch.thrower_4, State.rails.runner.positions.feast_throw_4),
          throw_snow(ch.thrower_5, State.rails.runner.positions.feast_throw_5)
        )
        snowballs:await()

        -- NEXT more snowballs

        dancing:await()
      sp:finish()
    end,
  },
}
