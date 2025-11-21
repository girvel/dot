local colors = require("engine.tech.colors")
local sound = require("engine.tech.sound")
local combat = require("engine.mech.ais.combat")
local npcs = require("levels.main.palette.npcs")
local level = require("engine.tech.level")
local health = require("engine.mech.health")
local items_entities = require("levels.main.palette.items_entities")
local item = require("engine.tech.item")
local animated = require("engine.tech.animated")
local async = require("engine.tech.async")
local screenplay = require("engine.tech.screenplay")
local api = require("engine.tech.api")


local godfruit_item = function()
  return Table.extend(
    animated.mixin("assets/sprites/animations/godfruit"),
    item.mixin_min("hand"),
    {
      codename = "godfruit",
      boring_flag = true,
    }
  )
end

local sac_fruit = function(actor)
  api.rotate(actor, State.runner.positions.feast_pyre)

  async.sleep(.5)
  State.period:push_key(actor.inventory, "offhand", State:add(godfruit_item()))

  async.sleep(1.5)
  actor:animate("interact"):wait()
  State:remove(actor.inventory.offhand)
  State.period:pop_key(actor.inventory, "offhand")
end

--- @param target entity
--- @param leader entity
--- @param follower entity
--- @param destination vector
--- @return promise, scene
local escort = function(target, leader, follower, destination)
  return State.runner:run_task(function()
    Promise.all(
      api.travel_scripted(leader, target),
      api.travel_scripted(follower, target)
    ):wait()

    local lead = api.travel_scripted(leader, destination)
    local prev1 = leader.position
    local prev2

    while not lead.is_resolved do
      coroutine.yield()

      if leader.position ~= prev1 then
        level.unsafe_move(target, prev1)
        if prev2 then
          level.unsafe_move(follower, prev2)
        end

        prev2 = prev1
        prev1 = leader.position
      end
    end
  end)
end

local thunder = function()
  api.curtain(.1, colors.white):wait()
  local transparent = colors.white:copy()
  transparent.a = 0
  api.curtain(.3, transparent):wait()
end

--- @async
--- @param ch runner_characters
--- @param ps runner_positions
--- @return promise, entity[]
local spawn_invaders = function(ch, ps)
  local invaders = {}
  local next_spawn = State.grids.solids:bfs(ps.ma_invaders_spawn)

  local invaders_n = 10
  if State.rails.khaned_status == "dead" then
    invaders_n = invaders_n + 1
  end

  for i = 1, invaders_n do ::redo::
    local p, v = next_spawn()
    if v then
      next_spawn:discard()
      goto redo
    end

    local e
    if i == invaders_n - 2 and State.rails.khaned_status == "dead" then
      if State:exists(ch.invader) then
        State:remove(ch.invader)
      end
      e = ch.invader
    elseif i == invaders_n - 1 then
      e = npcs.invader_commander()
      ch.invader_leader = e
    elseif i == invaders_n then
      e = npcs.invader_priest()
      ch.invader_priest = e
    else
      e = npcs.invader()
    end

    table.insert(invaders, 1, State:add(
      e, {position = p, grid_layer = "solids"}
    ))
  end

  local promises = {}
  local next_destination = State.grids.solids:bfs(ps.ma_invaders_standoff)
  for _, invader in ipairs(invaders) do ::redo::
    local p, e = next_destination()
    assert(p)
    if e then
      next_destination:discard()
      goto redo
    end
    next_destination()
    next_destination()

    local pr = api.travel_scripted(invader, p)
    table.insert(promises, pr)
    async.sleep(.2)
  end

  return Promise.all(unpack(promises)), invaders
end

local start_massacre = function(invaders)
  State.hostility:set("village", "invaders", "enemy")
  State.hostility:set("invaders", "village", "enemy")
  State.hostility:set("player", "invaders", "enemy")
  State.hostility:set("invaders", "player", "enemy")

  local ch = State.runner.entities

  for i = 1, 4 do
    local e = ch["watcher_" .. i]
    if not e.inventory.hand then
      item.give(e, State:add(items_entities.bear_spear()))
    end
  end

  item.give(ch.red_priest, State:add(items_entities.short_bow()))
  item.give(ch.green_priest, State:add(items_entities.short_bow()))

  local combat_list = Table.concat(
    invaders, State.rails:get_crowd(),
    {ch.red_priest, ch.blocker_1, ch.blocker_2, ch.watcher_4}
  )

  if State.rails.gatherer_status == "ran_away" then
    table.insert(combat_list, ch.gatherer)
  end

  combat_list = Fun.iter(combat_list)
    :filter(function(e) return State:exists(e) end)
    :totable()

  for _, e in ipairs(combat_list) do
    e.essential_flag = nil

    if getmetatable(e.ai) ~= combat.mt then
      if e.ai.deinit then
        e.ai:deinit(e)
      end
      e.ai = combat.new({scan_range = 20, follow_range = 30})
      e.ai:init(e)
    end
  end
  table.insert(combat_list, State.player)

  State:start_combat(combat_list)
  return combat_list
end


return {
  --- @type scene
  _170_massacre = {
    enabled = true,
    mode = "sequential",
    characters = {
      player = {},
      likka = {optional = true},
      khaned = {optional = true},
      green_priest = {},

      watcher_1 = {},
      watcher_2 = {},
      watcher_3 = {},
      watcher_4 = {},

      invader_leader = {dynamic = true, optional = true},
      invader_priest = {dynamic = true, optional = true},
      invader = {optional = true},

      dungeon_blocker_1 = {optional = true},
      dungeon_blocker_2 = {optional = true},
      dungeon_blocker_3 = {optional = true},
    },

    start_predicate = function(self, dt, ch, ps)
      for i = 1, 3 do
        if api.distance(ch.player, ps["ma_start_" .. i]) <= 2 then
          return true, i
        end
      end
    end,

    run = function(self, ch, ps, entrance_i)
      local likka_there = State.rails.likka_status == "village"
      local khaned_there = State.rails.khaned_status == "survived"

      -- if State.debug then
      --   State.runner:remove(self)
      --   if likka_there then
      --     ch.likka.essential_flag = nil
      --     health.set_hp(ch.likka, 0)
      --   end
      --   if khaned_there then
      --     ch.khaned.essential_flag = nil
      --     health.set_hp(ch.khaned, 0)
      --   end
      --   local invaders = spawn_invaders(ch, ps)
      --   State:remove(ch.invader_priest)
      --   start_massacre(invaders)
      --   return
      -- end

      local sp = screenplay.new("assets/screenplay/170_massacre.ms", ch)
        sp:lines()

        if api.options(sp:start_options()) == 1 then
          api.travel_scripted(ch.player, ps["ma_away_" .. entrance_i]):wait()
          return
        end
        sp:finish_options()

        State.runner:remove(self)
        State.rails:rain_intensify()

        local n = likka_there and 1
          or khaned_there and 2
          or 3

        sp:start_single_branch(n)
          api.move_camera(ps.feast_pyre):wait()

          local prev_rotation
          if n == 1 then
            prev_rotation = ch.likka.direction
            api.rotate(ch.likka, ch.player)
          elseif n == 3 then
            prev_rotation = ch.green_priest.direction
            api.rotate(ch.green_priest, ch.player)
            ch.green_priest:animate("fast_gesture")
          end

          sp:lines()

          if n == 1 then
            ch.likka:rotate(prev_rotation)
          elseif n == 3 then
            ch.green_priest:rotate(prev_rotation)
          end
        sp:finish_single_branch()

        api.free_camera()
        api.travel_scripted(ch.player, ps.feast_sac_1):wait()

        sp:start_single_branch()
          if not likka_there and not khaned_there then
            sp:lines()
          end
        sp:finish_single_branch()

        ch.player:rotate(Vector.up)
        ch.green_priest:rotate(Vector.down)

        async.sleep(1)
        ch.green_priest:animate("clap"):next(function()
          for _, e in ipairs(State.rails:get_crowd()) do
            api.rotate(e, ps.feast_pyre)
          end
        end)
        sp:lines()

        sp:start_branches()
          if khaned_there then
            sp:start_branch(1)
              api.assert_position(ch.khaned, ps.feast_sac_3)
              local p = State.runner:run_task(function() sac_fruit(ch.khaned) end)
              sp:lines()
              p:wait()
            sp:finish_branch()
          end

          if likka_there then
            sp:start_branch(2)
              api.assert_position(ch.likka, ps.feast_sac_2)
              local p = State.runner:run_task(function() sac_fruit(ch.likka) end)
              sp:lines()
              p:wait()

              sp:start_single_branch()
                if khaned_there then
                  p = State.runner:run_task(function()
                    async.sleep(.2)
                    api.rotate(ch.likka, ch.player)

                    async.sleep(.2)
                    api.rotate(ch.likka, ch.khaned)

                    async.sleep(.2)
                    ch.likka:rotate(Vector.right)
                  end)
                  sp:lines()
                  p:wait()
                end
              sp:finish_single_branch()
            sp:finish_branch()
          end
        sp:finish_branches()

        sp:start_single_branch(State.rails.has_fruit and 1 or 2)
          if State.rails.has_fruit then
            sp:start_single_branch(ch.player:ability_check("performance", 12) and 1 or 2)
              local p = State.runner:run_task(function() sac_fruit(ch.player) end)
              sp:lines()
              p:wait()
              State.rails:fruit_sac()
            sp:finish_single_branch()
          else
            sp:lines()

            sp:start_single_branch(ch.player:ability_check("performance", 12) and 1 or 2)
              sp:lines()
              sp:start_single_branch()
                if not likka_there and not khaned_there then
                  sp:lines()
                end
              sp:finish_single_branch()
            sp:finish_single_branch()

            sp:start_single_branch()
              if likka_there or khaned_there then
                sp:lines()
              end
            sp:finish_single_branch()
          end
        sp:finish_single_branch()

        async.sleep(1)
        ch.player:rotate(Vector.left)
        if likka_there then
          async.sleep(.1)
          ch.likka:rotate(Vector.left)
        end
        if khaned_there then
          async.sleep(.2)
          ch.khaned:rotate(Vector.left)
        end

        -- SOUND ominous
        sp:lines()

        n = likka_there and khaned_there and 1
          or likka_there and 2
          or khaned_there and 3
          or 4
        sp:start_single_branch(n)
          sp:lines()
        sp:finish_single_branch()

        async.sleep(.3)

        sp:start_single_branch()
          if khaned_there then
            ch.green_priest:animate("fast_gesture")
            sp:lines()

            async.sleep(1)
            api.rotate(ch.watcher_1, ch.khaned)
            api.assert_position(ch.watcher_1, ch.khaned.position + Vector.up)
            item.give(ch.watcher_1, State:add(items_entities.bear_spear()))

            async.sleep(1)
            -- SOUND devastated
            api.emulate_attack(ch.watcher_1, "hand"):next(function()
              health.set_hp(ch.khaned, 1)
              ch.khaned:animation_freeze("lying")
              api.rotate(ch.player, ch.khaned)
            end):wait()

            sp:lines()

            async.sleep(4)
            ch.khaned.essential_flag = nil
            health.set_hp(ch.khaned, 0)

            sp:start_single_branch()
              if likka_there then
                api.move_camera(ps.ma_likka_away)
                local likka_away = api.travel_scripted(ch.likka, ps.ma_likka_away, 10)

                local lines = State.runner:run_task(function()
                  async.sleep(.5)
                  sp:lines()
                end)

                local t = love.timer.getTime()
                while api.distance(ch.likka, ps.ma_likka_away) > 3
                  and love.timer.getTime() - t <= 10
                do
                  coroutine.yield()
                end

                api.travel_scripted(ch.watcher_2, ps.ma_watcher_2 + Vector.right)
                api.travel_scripted(ch.watcher_3, ps.ma_watcher_3 + Vector.left)
                likka_away:wait()
                lines:wait()

                local mess = State.runner:run_task(function()
                  api.rotate(ch.likka, ch.watcher_2)
                  ch.likka:animate("offhand_attack"):wait()
                  ch.likka:rotate(-ch.likka.direction)
                  ch.likka:animate("move"):wait()

                  api.rotate(ch.likka, ch.watcher_3)
                  ch.likka:animate("offhand_attack"):wait()
                  ch.likka:rotate(-ch.likka.direction)
                  ch.likka:animate("move"):wait()

                  api.rotate(ch.likka, ch.watcher_2)
                  ch.likka:animate("offhand_attack"):wait()
                  ch.likka:rotate(-ch.likka.direction)
                  ch.likka:animate("move"):wait()
                end)
                sp:lines()
                mess:wait()

                api.free_camera()
              end
            sp:finish_single_branch()

            -- SOUND heartbeat
            async.sleep(2)
            sp:lines()
          end
        sp:finish_single_branch()

        sp:lines()

        sp:start_single_branch()
          if likka_there then
            sp:start_single_branch(khaned_there and 1 or 2)
              local p
              if khaned_there then
                p = escort(ch.likka, ch.watcher_2, ch.watcher_3, ps.feast_sac_2)
              else
                p = Promise.all(
                  api.travel_scripted(ch.watcher_2, ch.likka),
                  api.travel_scripted(ch.watcher_3, ch.likka)
                )
              end
              ch.green_priest:animate("fast_gesture")
              sp:lines()
              p:wait()
            sp:finish_single_branch()

            sp:lines()

            api.rotate(ch.likka, ch.green_priest)
            sp:start_branches()
              if State.rails.empathy == "present" then
                sp:start_branch(1)
                  sp:lines()
                sp:finish_branch()
              elseif not State.rails.has_fruit then
                sp:start_branch(2)
                  sp:lines()
                  sp:start_single_branch()
                    if khaned_there then
                      sp:lines()
                    end
                  sp:finish_single_branch()
                sp:finish_branch()
              end
            sp:finish_branches()

            n = api.options(sp:start_options())
              if n == 1 then
                sp:start_option(1)
                  sp:lines()

                  item.give(ch.watcher_3, State:add(items_entities.bear_spear()))
                  api.travel_scripted(ch.watcher_3, ch.player):wait()
                  api.emulate_attack(ch.watcher_3, "hand"):wait()
                  health.set_hp(State.player, math.min(State.player.hp, 6))

                  sp:lines()
                  -- TODO achievement on return

                  health.damage(State.player, 1)
                  if State.player.hp == 0 then return end
                  sp:lines()

                  health.damage(State.player, 1)
                  if State.player.hp == 0 then return end
                  State.player:animation_freeze("lying")
                  sp:lines()

                  health.damage(State.player, 1)
                  if State.player.hp == 0 then return end
                  sp:lines()

                  health.damage(State.player, 1)
                  api.rotate(ch.likka, Vector.right)
                  if State.player.hp == 0 then return end
                  sp:lines()

                  health.damage(State.player, 1)
                  if State.player.hp == 0 then return end
                  api.curtain(1, colors.black)
                  sp:lines()

                  health.set_hp(State.player, 0)
                  api.curtain(0, Vector.transparent)
                  return
                sp:finish_option()
              end
            sp:finish_options()

            async.sleep(1.5)
            api.rotate(ch.watcher_2, ch.likka)
            item.give(ch.watcher_2, State:add(items_entities.bear_spear()))

            async.sleep(.5)
            api.emulate_attack(ch.watcher_2, "hand"):wait()
            -- SOUND devastated
            health.set_hp(ch.likka, 0)

            local delay = api.delay(5)
            sp:lines()
            delay:wait()

            async.sleep(2)
            ch.likka.essential_flag = nil
            health.set_hp(ch.likka, 0)
          end
        sp:finish_single_branch()

        sp:lines()

        sp:start_single_branch()
          if State.rails.has_fruit or (not likka_there and not khaned_there) then
            n = likka_there and khaned_there and 1
              or likka_there and 2
              or khaned_there and 3
              or 4

            sp:start_single_branch(n)
              local p = escort(
                ch.player, ch.watcher_3, ch.watcher_2, n == 3 and ps.feast_sac_3 or ps.feast_sac_2
              )
              sp:lines()
            sp:finish_single_branch()

            sp:start_single_branch(ch.player:ability_check("performance", 12) and 1 or 2)
              sp:lines()
            sp:finish_single_branch()
            p:wait()
          end
        sp:finish_single_branch()

        async.sleep(1)
        item.give(ch.watcher_3, State:add(items_entities.bear_spear()))
        api.rotate(ch.watcher_3, ch.player)
        local invaders_promise, invaders = spawn_invaders(ch, ps)

        async.sleep(1.5)
        api.rotate(ch.watcher_3, ch.invader_priest)
        sp:lines()

        invaders_promise:wait()
        sp:lines()

        sound.new("assets/sounds/thunder.mp3"):play()
        async.sleep(.3)
        thunder()

        sp:start_single_branch()
          if State.rails.khaned_status then
            sp:lines()
          end
        sp:finish_single_branch()
        sp:lines()

        local singing
        local priest_coming = api.travel_scripted(ch.invader_priest, ps.ma_priest_spell):next(function()
          _, singing = State.runner:run_task(function()
            while true do
              ch.invader_priest:rotate(Vector.left)
              ch.invader_priest:animate("gesture"):wait()
              async.sleep(.5)
              ch.invader_priest:rotate(Vector.right)
              ch.invader_priest:animate("gesture"):wait()
              async.sleep(.5)
            end
          end)
        end)
        sp:lines()
        priest_coming:wait()

        async.sleep(5)
        sp:lines()
        State.runner:stop(singing)

        sound.new("assets/sounds/massacre_spell.mp3", .5):play()
        async.sleep(.1)
        State:remove(ch.invader_priest)
        local fx = animated.add_fx(
          "assets/sprites/animations/massacre_spell",
          ch.invader_priest.position - V(1, 3), "fx_over"
        )

        coroutine.yield()
        while State:exists(fx) and fx.animation.frame < 9 do coroutine.yield() end

        thunder()

        sp:lines()
        -- SOUND wounded mennar
        -- TODO chaos in the feast
        sp:lines()
      sp:finish()

      State.rails:seekers_run_away()
      api.autosave("Праздник - Резня")
      State:remove(ch.dungeon_blocker_1)
      State:remove(ch.dungeon_blocker_2)
      State:remove(ch.dungeon_blocker_3)
      State.runner:run_task(function()
        coroutine.yield()
        State.rails.massacre_combat_list = start_massacre(invaders)
      end)
    end,
  },
}
