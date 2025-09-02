local api = require("engine.tech.api")
local screenplay = require("engine.tech.screenplay")


return {
  _010_intro = {
    characters = {
      player = {},
      khaned = {},
      likka = {},
      head_priest = {},
    },

    --- @param self scene
    --- @param dt number
    --- @param ch railing_characters
    start_predicate = function(self, dt, ch)
      return State.player
    end,

    --- @param self scene
    --- @param ch railing_characters
    run = function(self, ch)
      local sp = screenplay.new("assets/screenplay/010_intro.ms", ch)
        ch.khaned:rotate(Vector.up)
        ch.likka:rotate(Vector.up)

        sp:lines()
        local options = sp:start_options()
        for _ = 1, 3 do
          local n = api.options(options, true)
          sp:start_option(n)
            sp:lines()
          sp:finish_option()
        end
        sp:finish_options()
        sp:lines()

        api.rotate(ch.likka, ch.khaned)

        sp:lines()

        local n = api.options(sp:start_options())
          if n == 1 then
            sp:start_option(n)
            sp:start_branches()
              sp:start_branch(ch.player:ability_check("investigation", 10) and 1 or 2)
                sp:lines()
              sp:finish_branch()
            sp:finish_branches()
            sp:finish_option()
          end
        sp:finish_options()

        sp:lines()
        api.travel_persistent(ch.head_priest, Runner.positions.head_priest_1)
        sp:lines()
        Runner:run_task(function()
          api.travel_scripted(ch.head_priest, Runner.positions.head_priest_3)
          ch.head_priest:rotate(Vector.up)
        end)
        api.wait(2)

        sp:lines()
        Runner:run_task(function()
          api.travel_scripted(ch.khaned, Runner.positions.khaned_feast)
        end)
        Runner:run_task(function()
          api.travel_scripted(ch.likka, Runner.positions.likka_feast)
        end)
        api.wait(2)

        sp:lines()
        Runner.locked_entities[ch.player] = nil

        State.quests.items.feast = {
          name = sp:literal(),
          objectives = {
            {status = "new", text = sp:literal()},
            {status = "new", text = sp:literal()},
          },
        }
        api.journal_update()

        while ch.player.position ~= Runner.positions.start_location_exit do
          coroutine.yield()
        end

        sp:start_branches()
        if not ch.player.inventory.hand then
          Runner.locked_entities[ch.player] = true
          sp:start_branch(1)
            sp:lines()
          sp:finish_branch()
          Runner.locked_entities[ch.player] = nil
        end
        sp:finish_branches()
      sp:finish()
    end,
  },
}
