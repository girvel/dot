local level = require("engine.tech.level")
local colors = require("engine.tech.colors")
local health = require("engine.mech.health")
local async = require("engine.tech.async")
local screenplay = require("engine.tech.screenplay")
local api = require("engine.tech.api")


--- @param check boolean
--- @return promise, scene
local run_away = function(check)
  local pr, sc = api.travel_scripted(State.player, State.runner.positions.fi_away, check and 12 or 5)
  pr:next(function()
    if check and State.player.hp > 1 then
      health.damage(State.player, 1)
    end
    api.fade_in(2)
  end)
  -- NEXT! block the way back
  return pr, sc
end

return {
  --- @type scene
  _180_final_interaction = {
    enabled = true,
    characters = {
      player = {},
    },

    start_predicate = function(self, dt, ch, ps)
      return api.distance(ch.player, ps.fi_start) <= 3
    end,

    run = function(self, ch, ps)
      api.travel_scripted(ch.player, ps.fi_start):wait()
      ch.player:rotate(Vector.up)

      local sp = screenplay.new("assets/screenplay/180_final_interaction.ms", ch)
        sp:lines()

        api.fade_out(.5)
        sp:lines()

        -- SOUND ominous

        local n = api.options(sp:start_options())
          if n == 2 then
            sp:start_option(n)
              sp:lines()

              n = api.options(sp:start_options())
                sp:start_option(n)
                  if n == 2 then
                    sp:lines()

                    local check = ch.player:ability_check("athletics", 12)
                    sp:start_single_branch(check and 1 or 2)
                      sp:lines()
                      local running_away = run_away(check)
                      sp:lines()
                      running_away:wait()
                    sp:finish_single_branch()
                    sp:lines()

                    return
                  end
                sp:finish_option()
              sp:finish_options()
            sp:finish_option()
          end
        sp:finish_options()

        local fade_in = api.fade_in(.5):next(function()
          State.runner:run_task(function()
            async.sleep(.5)
            State.player.is_blind = true
          end)
        end)
        api.move_camera(ps.fi_camera)
        sp:lines()
        fade_in:wait()

        sp:lines()

        n = api.options(sp:start_options())
        sp:finish_options()

        if n == 1 then
          run_away(false)
          return
        end

        sp:lines()

        State.rails:ask_the_question(api.options(sp:start_options()))
        sp:finish_options()

        sp:lines()

        api.options(sp:start_options())
        sp:finish_options()

        sp:lines()
        local ethereal_music = api.play_sound("assets/sounds/ethereal_music", .8)
        sp:lines()
        ethereal_music:wait()

        sp:lines()

        api.curtain(1, colors.black)
        local delay = api.delay(10)
        sp:lines()
      sp:finish()

      delay:wait()
      level.unsafe_move(State.player, ps.fi_away)
      api.curtain(1, Vector.transparent):wait()
    end,
  },
}
