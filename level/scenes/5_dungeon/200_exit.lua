local colors = require("engine.tech.colors")
local sprite = require("engine.tech.sprite")
local actions = require("engine.mech.actions")
local async = require("engine.tech.async")
local screenplay = require("engine.tech.screenplay")
local api = require("engine.tech.api")


return {
  --- @type scene
  _200_exit = {
    enabled = true,
    characters = {
      player = {},
    },

    start_predicate = function(self, dt, ch, ps)
      return api.distance(ch.player, ps.test_zero) <= 3
    end,

    run = function(self, ch, ps)
      local is_good = State.rails.has_blessing and State.rails.question_i
      local sp = screenplay.new("assets/screenplay/200_exit.ms", ch)
        sp:start_single_branch(is_good and 1 or 2)
          if State.rails.has_blessing then
            State.player.is_blind = false
          end
          sp:lines()

          if not is_good then
            sp:start_single_branch()
              if State.rails.question_i then
                sp:lines()
              end
            sp:finish_single_branch()

            sp:start_single_branch(State.rails.likka_status == "temple" and 1 or 2)
              sp:lines()
            sp:finish_single_branch()
          end
        sp:finish_single_branch()

        async.sleep(1.5)
        local curtain = api.curtain(5, colors.white)
        sp:lines()

        State.runner:run_task(function()
          async.sleep(.5)
          if ch.player.position.y > ch.player.position.x then
            actions.move(Vector.left):act(ch.player)
          else
            actions.move(Vector.right):act(ch.player)
          end

          async.sleep(.4)
          ch.player:animation_set_paused(true)
          coroutine.yield()
          ch.player.sprite = sprite.image("assets/sprites/standalone/empty.png")
        end)

        curtain:wait()

        State.mode:ending(is_good)
      sp:finish()
    end,
  },
}
