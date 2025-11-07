local core = require("levels.main.core")
local projectile = require("engine.tech.projectile")
local animated = require("engine.tech.animated")
local async = require("engine.tech.async")
local actions = require("engine.mech.actions")
local screenplay = require "engine.tech.screenplay"
local api        = require "engine.tech.api"
local item       = require "engine.tech.item"


--- @param inviter entity
--- @param invitee entity
--- @param left_corner vector
--- @param passes_n integer
--- @param applause? boolean
--- @return promise, scene
local dance = function(inviter, invitee, left_corner, passes_n, applause)
  -- really not a strict implementation of the simplistic idea I had in mind
  -- but this looks even better
  return State.runner:run_task(function()
    if applause then
      for _ = 1, math.random(2, 3) do
        async.sleep(Random.float(0, .2))
        inviter:animate("clap")
        invitee:animate("clap"):wait()
      end
    end

    api.travel_scripted(inviter, invitee.position):wait()
    api.rotate(inviter, invitee)
    async.sleep(.3)
    api.rotate(invitee, inviter)
    async.sleep(1)

    for _ = 1, passes_n do
      -- both stabilization & traveling to the starting positions
      local t1 = api.travel_scripted(inviter, left_corner)
      local t2 = api.travel_scripted(invitee, left_corner + Vector.right)

      t1:wait()
      t2:wait()

      api.rotate(inviter, invitee)
      api.rotate(invitee, inviter)

      local sec = math.floor(love.timer.getTime())
      while love.timer.getTime() - sec < 1 do coroutine.yield() end
      actions.move(Vector.right):act(invitee)
      actions.move(Vector.right):act(inviter)
      invitee:rotate(Vector.left)
      invitee:animate("move"):wait()
      invitee:animate("hand_attack")
      inviter:animate("offhand_attack")

      sec = math.floor(love.timer.getTime())
      while love.timer.getTime() - sec < 1 do coroutine.yield() end
      actions.move(Vector.left):act(inviter)
      actions.move(Vector.left):act(invitee)
      inviter:rotate(Vector.right)
      inviter:animate("move"):wait()
      invitee:animate("offhand_attack")
      inviter:animate("hand_attack"):wait()
    end
  end, "dance")
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

local fruit_new = function()
  return Table.extend(
    animated.mixin("assets/sprites/animations/fruit"),
    item.mixin_min("hand"),
    {
      codename = "fruit",
      boring_flag = true,
    }
  )
end

--- @param thrower entity
--- @param position vector
--- @param repetitions_n integer
--- @return promise, scene
local throw_snow = function(thrower, position, repetitions_n)
  local pyre_position = State.runner.positions.feast_pyre
    + V(.5 + Random.float(-0.125, 0.125), -.25 + Random.float(-0.125, 0.125))

  return State.runner:run_task(function()
    api.travel_scripted(thrower, position):wait()
    async.sleep(.2)
    thrower:rotate((pyre_position - position):normalized2())

    for _ = 1, repetitions_n do
      async.sleep(Random.float(0, .6))
      local snowball = State:add(snowball_new())
      thrower.inventory.hand = snowball
      local projectile_task
      thrower:animate("throw", true):next(function()
        projectile_task = projectile.launch(thrower, "hand", pyre_position, Random.float(10, 16))
      end):wait()
      projectile_task:wait()
    end
  end, "throw_snow")
end
Ldump.ignore_upvalue_size(throw_snow)

return {
  _020_feast = {
    enabled = true,
    mode = "disable",

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
      extra_dancer = {},
    },

    final_dancing_scenes = {},

    --- @param self scene
    --- @param dt number
    --- @param ch runner_characters
    --- @param ps runner_positions
    start_predicate = function(self, dt, ch, ps)
      return ch.player.position >= ps.feast_start
        and ch.player.position <= ps.feast_finish
    end,

    --- @param self scene
    --- @param ch runner_characters
    --- @param ps runner_positions
    run = Ldump.ignore_upvalue_size(function(self, ch, ps)
      State.period:push_key(State.player, "fov_r", 25)
      local sp = screenplay.new("assets/screenplay/020_feast.ms", ch)
        api.travel_scripted(ch.player, ps.feast_observe):next(function()
          ch.player:rotate(Vector.down)
        end)
        api.move_camera(ps.feast_camera):wait()

        local give_fruit = function(receiver_name)
          api.travel_scripted(ch.green_priest, ch[receiver_name].position):wait()
          api.rotate(ch.green_priest, ch[receiver_name])
          async.sleep(.2)
          api.rotate(ch[receiver_name], ch.green_priest)
          ch.green_priest:animate("interact", true):wait()
        end

        local priest_task = State.runner:run_task(function()
          give_fruit("boy_1")
          give_fruit("boy_2")
          give_fruit("boy_3")
        end, "priest_gives_fruit")

        sp:lines()  -- don't wait for narration to start priest movement
        sp:lines()
        priest_task:wait()

        priest_task = api.travel_scripted(
          ch.green_priest, ps.feast_green_priest
        ):next(function() ch.green_priest:rotate(Vector.up) end)

        local dancing = Promise.all(
          dance(ch.girl_1, ch.boy_1, ps.dance_1, 7),
          dance(ch.girl_2, ch.boy_2, ps.dance_2, 7),
          dance(ch.girl_3, ch.boy_3, ps.dance_3, 6)
        )
        sp:lines()

        priest_task:wait()

        async.sleep(4)
        priest_task = throw_snow(ch.green_priest, ps.feast_throw_priest, 1)
        sp:lines()
        priest_task:wait()
        async.sleep(.5)

        local snowballs = Promise.all(
          throw_snow(ch.thrower_1, ps.feast_throw_1, math.random(2, 3)),
          throw_snow(ch.thrower_2, ps.feast_throw_2, math.random(2, 3)),
          throw_snow(ch.thrower_3, ps.feast_throw_3, math.random(2, 3)),
          throw_snow(ch.thrower_4, ps.feast_throw_4, math.random(2, 3)),
          throw_snow(ch.thrower_5, ps.feast_throw_5, math.random(2, 3))
        )
        sp:lines()
        snowballs:wait()
        dancing:wait()

        local sac_fruit = function(ch_name, fruit_pos, sac_pos)
          return State.runner:run_task(function()
            local guy = ch[ch_name]
            fruit_pos = ps[fruit_pos]
            sac_pos = ps[sac_pos]

            api.travel_scripted(guy, fruit_pos):wait()
            api.rotate(guy, fruit_pos)
            async.sleep(1)
            guy:animate("interact"):wait()
            guy.inventory.hand = State:add(fruit_new())
            async.sleep(1)

            api.travel_scripted(guy, sac_pos):wait()
            api.rotate(guy, ps.feast_pyre)
            guy:animate("interact"):wait()
            State:remove(guy.inventory.hand)
            guy.inventory.hand = nil
          end, "sac_fruit")
        end

        ch.green_priest:animate("gesture"):wait()
        local fruits = Promise.all(
          sac_fruit("boy_1", "feast_fruit_1", "feast_sac_1"),
          sac_fruit("boy_2", "feast_fruit_2", "feast_sac_2"),
          sac_fruit("boy_3", "feast_fruit_3", "feast_sac_3")
        )
        sp:lines()
        fruits:wait()

        local human_sac = State.runner:run_task(function()
          for _, target in ipairs {"boy_3", "boy_2", "boy_1"} do
            api.travel_scripted(ch.green_priest, ch[target].position):wait()
            async.sleep(.5)
            ch.green_priest:animate("interact")
            async.sleep(.3)
            ch[target]:animate("lying")
            coroutine.yield()
            ch[target]:animation_set_paused(true)
            async.sleep(1)
          end
        end, "human_sac")
        sp:lines()
        human_sac:wait()

        async.sleep(5)
        local next_dance = function(inviter, invitee, corner)
          local is_priest = not inviter:ends_with("priest")
          inviter = ch[inviter]
          invitee = ch[invitee]
          corner = ps[corner]

          async.sleep(Random.float(0, .3))
          local promise, scene = dance(
            inviter, invitee, corner, 20, is_priest
          )
          table.insert(self.final_dancing_scenes, scene)
          return promise
        end

        next_dance("green_priest", "girl_1", "dance_1")
        next_dance("thrower_4", "girl_2", "dance_2")
        next_dance("extra_dancer", "girl_3", "dance_3")
        next_dance("thrower_5", "thrower_3", "dance_4")
        next_dance("thrower_2", "thrower_1", "dance_5")
        sp:lines()
        async.sleep(5)
      sp:finish()

      State.period:pop_key(State.player, "fov_r")
    end),
  },
}
