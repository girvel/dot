local core = require("levels.main.core")
local async = require("engine.tech.async")
local screenplay = require("engine.tech.screenplay")
local api = require("engine.tech.api")


return {
  --- @type scene
  _116_walking_corridor = {
    enabled = true,
    characters = {
      player = {},
      likka = {},
      skeleton_1 = {},
      skeleton_2 = {},
    },

    start_predicate = function(self, dt, ch, ps)
      return (State.player.position - ps.wc_start):abs2() <= 1
    end,

    run = function(self, ch, ps)
      local sp = screenplay.new("assets/screenplay/116_walking_corridor.ms", ch)
        core.bring_likka()
        sp:lines()

        local n = api.options(sp:start_options())
        sp:finish_options()
        if n == 3 then
          State.rails:empathy_lower()
        end

        api.rotate(ch.likka, ch.player)
        api.rotate(ch.player, ch.likka)

        sp:lines()

        n = api.options(sp:start_options())
          if n == 2 then
            sp:start_option(2)
              sp:lines()
            sp:finish_option()
          elseif n == 4 then
            State.rails:empathy_lower()
          end
        sp:finish_options()

        local skeletons_enter = Promise.all(
          api.travel_scripted(ch.skeleton_1, ps.wc_skeleton_1),
          api.travel_scripted(ch.skeleton_2, ps.wc_skeleton_2)
        )

        async.sleep(1.5)
        sp:lines()

        api.rotate(ch.player, ps.wc_skeleton_1)
        api.rotate(ch.likka, ps.wc_skeleton_1)
        local camera_move = api.move_camera(ps.wc_camera)
        skeletons_enter:wait()
        camera_move:wait()

        api.free_camera()
        local retreat = Promise.all(
          api.travel_scripted(ch.likka, ps.wc_retreat_likka, 8),
          api.travel_scripted(ch.player, ps.wc_retreat_player, 8)
        )
        retreat:wait()
        api.rotate(ch.player, ch.likka)
        api.rotate(ch.likka, ch.player)

        sp:lines()

        State.runner.scenes.skeletons_coming.enabled = true
      sp:finish() api.autosave("Руины - Термы") end,
  },

  --- @type scene
  skeletons_coming = {
    characters = {
      skeleton_1 = {},
      skeleton_2 = {},
      skeleton_3 = {},
      skeleton_4 = {},
      skeleton_5 = {},
    },

    start_predicate = function(self, dt, ch, ps)
      return true
    end,

    run = function(self, ch, ps)
      local promises = {}
      local scenes = {}
      for i = 1, 5 do
        local promise, scene = api.travel_scripted(
          ch["skeleton_" .. i],
          ps["skeleton_coming_" .. i]
        )

        table.insert(promises, promise)
        table.insert(scenes, scene)
      end

      local all = Promise.all(unpack(promises))
      while not all.is_resolved do
        local is_seen = false
        for i = 1, 5 do
          local skeleton = ch["skeleton_" .. i]
          if (State.player.position - skeleton.position):abs2() <= 10
            and api.is_visible(skeleton)
          then
            is_seen = true
          end
        end

        if is_seen then
          for _, scene in ipairs(scenes) do
            State.runner:stop(scene, true)
          end

          State.rails.fought_skeleton_group = true

          State:start_combat({
            State.player,
            ch.skeleton_1,
            ch.skeleton_2,
            ch.skeleton_3,
            ch.skeleton_4,
            ch.skeleton_5,
          })
          coroutine.yield()

          break
        end

        async.sleep(Random.float(.05, .15))
      end

      State.runner.scenes._118_after_danger.enabled = true
    end,
  },
}
