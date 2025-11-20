local rain = require("engine.tech.rain")
local async = require("engine.tech.async")
local shadows = require("levels.main.palette.shadows")
local colors = require("engine.tech.colors")
local sound = require("engine.tech.sound")
local floater = require("engine.tech.floater")
local items_entities = require("levels.main.palette.items_entities")
local item = require("engine.tech.item")
local health = require("engine.mech.health")
local tcod = require("engine.tech.tcod")
local level = require("engine.tech.level")
local no_op = require("engine.mech.ais.no_op")
local combat = require("engine.mech.ais.combat")
local on_solids = require("levels.main.palette.on_solids")
local solids_entities = require("levels.main.palette.solids_entities")
local api = require "engine.tech.api"
local winter = require "engine.tech.shaders.winter"
local likka_ai = require "levels.main.palette.likka_ai"


local rails = {}


----------------------------------------------------------------------------------------------------
-- [SECTION] State
----------------------------------------------------------------------------------------------------

--- @alias rails_location "0_intro"|"1_upper_village"|"2_forest"|"4_village"|"5_dungeon"?

--- @class rails
--- @field runner state_runner
--- @field location rails_location
--- @field feast "started"|"weapon_found"|"ceremony"|"done"?
--- @field winter "initialized"|"ended"?
--- @field seekers "started"|"fruit_found"|"run_away"|"find_exit"?
--- @field tried_berries "once"|"twice"?
--- @field fruit_source "likka"|"khaned"|"found"? also a good indicator if fruit WAS ever picked up
--- @field seen_rotten_fruit boolean?
--- @field ate_rotten_fruit boolean?
--- @field seen_companion_fruit boolean?
--- @field has_blessing boolean?
--- @field has_fruit boolean? nil if not yet found, false if eaten
--- @field khaned_status "dead"|"survived"?
--- @field likka_status "dead"|"temple"|"village"?
--- @field gatherer_status "ran_away"?
--- @field likka_saw_bad_trip boolean?
--- @field temple "entered"|"exited"?
--- @field empathy integer|"present"|"denied"?
--- @field fought_skeleton_group? boolean
--- @field met_nea? boolean
--- @field _scenes_by_location table
--- @field _snow entity[]
--- @field _water entity[]
--- @field _rain rain?
local methods = {}
local mt = {__index = methods}

--- @return rails
rails.new = function()
  local scenes_by_location do
    scenes_by_location = {}
    local scenes_folder = Table.do_folder("levels/main/scenes")
    for k, subfolder in pairs(scenes_folder) do
      scenes_by_location[k] = {}
      for _, v in pairs(subfolder) do
        Table.extend_strict(scenes_by_location[k], v)
      end
    end
  end

  return setmetatable({
    _scenes_by_location = scenes_by_location,
    _snow = {},
    _water = {},
  }, mt)
end


----------------------------------------------------------------------------------------------------
-- [SECTION] Helpers
----------------------------------------------------------------------------------------------------

local cache

--- @param position vector
--- @return boolean
methods.is_indoors = function(self, position)
  if not cache then
    cache = Grid.new(State.level.grid_size)
    Ldump.ignore_size(cache)
  end

  local result = cache:slow_get(position, false)
  if result ~= nil then return result end

  local starts = State.runner:position_sequence("house")
  local ends = State.runner:position_sequence("house_end")
  result = false

  for i = 1, #starts do
    if starts[i] <= position and position <= ends[i] then
      result = true
      break
    end
  end

  cache[position] = result
  return result
end

--- @return entity[]
methods.get_crowd = Memoize(function()
  return Fun.iter({
    "boy_1", "boy_2", "boy_3",
    "girl_1", "girl_2", "girl_3",
    "thrower_1", "thrower_2", "thrower_3", "thrower_4", "thrower_5",
    "watcher_1", "watcher_2", "watcher_3", "watcher_4",
    "extra_dancer", "green_priest"})
    :map(function(id) return State.runner.entities[id] end)
    :totable()
end)


----------------------------------------------------------------------------------------------------
-- [SECTION] Transitions
----------------------------------------------------------------------------------------------------

--- @param location rails_location
--- @param forced boolean?
methods._location_transition = function(self, location, forced)
  local in_order = (
    forced
    or self.location == nil and location == "0_intro"
    or self.location == "0_intro" and location == "1_upper_village"
    or self.location == "1_upper_village" and location == "2_forest"
    or self.location == "2_forest" and location == "4_village"
    or self.location == "4_village" and location == "5_dungeon"
  )

  if not in_order then
    Error("Out of order transition %s -> %s", self.location, location)
  end

  Log.info("Location transition %s -> %s", self.location, location)

  if self.location then
    for _, v in pairs(self._scenes_by_location[self.location]) do
      -- doesn't stop scenes
      Table.remove_pair(State.runner.scenes, v)
    end
  end

  State.runner:add(self._scenes_by_location[location])
  self.location = location
end

methods._sublocation_enter = function(self, location)
  -- TODO checks?
  Log.info("Entering sublocation %s", location)
  State.runner:add(self._scenes_by_location[location])
end

methods._sublocation_exit = function(self, location)
  Log.info("Exiting sublocation %s", location)
  for _, v in pairs(self._scenes_by_location[location]) do
    Table.remove_pair(State.runner.scenes, v)
  end
end

--- @param forced boolean?
methods.location_intro = function(self, forced)
  api.autosave("Начало")
  self:_location_transition("0_intro", forced)
end

--- @param forced boolean?
methods.location_upper_village = function(self, forced)
  api.autosave("Церемония")
  self:_location_transition("1_upper_village", forced)

  local ch = State.runner.entities
  local ps = State.runner.positions
  api.travel_scripted(ch.khaned,     ps.ceremony_khaned)
  api.travel_scripted(ch.likka,      ps.ceremony_likka)
  api.travel_scripted(ch.red_priest, ps.ceremony_red_priest)
end

--- @param forced boolean?
methods.location_forest = function(self, forced)
  api.autosave("Лес")
  self:_location_transition("2_forest", forced)

  local ch = State.runner.entities
  local ps = State.runner.positions
  api.assert_position(ch.khaned, ps.sk_khaned, forced)
  api.assert_position(ch.likka, ps.sl_likka, forced)

  for e in pairs(State._entities) do
    if e._is_a_skeleton then
      e.ai = no_op.new()
    end
  end
end

-- TODO theoretically, "forced" mechanic is invalid, because it forces only scene transitions, not
--   the additional checks and asserts

local seekers_fruit_is_missed

--- @param forced boolean?
methods.location_village = function(self, forced)
  if self.khaned_status == nil then
    self:khaned_offscreen_death()
  end

  if self.seekers == "started" then
    seekers_fruit_is_missed(self)
  end

  api.autosave("Деревня")
  self:_location_transition("4_village", forced)
end

local seekers_in_dungeon

--- @param forced boolean?
methods.location_dungeon = function(self, forced)
  api.autosave("Подземелье")
  self:_location_transition("5_dungeon", forced)
  seekers_in_dungeon(self)
end

methods.winter_init = function(self)
  assert(self.winter == nil)

  State.shader = winter.new()
  self.winter = "initialized"

  local ch = State.runner.entities
  ch.blocker_1.immovable_flag = true
  ch.blocker_2.immovable_flag = true
  ch.coast_birds_1.sound_source.source:setVolume(0)
  ch.coast_birds_2.sound_source.source:setVolume(0)

  Log.info("Winter initialized")
end

methods.winter_end = function(self)
  assert(self.winter == "initialized")

  for _, e in ipairs(self._snow) do
    State:add(e, {life_time = Random.float(0, 30)})
    e.on_remove = function(self_e)
      if self_e.position.x >= State.runner.positions.grass_gen_limit.x then return end

      local tile = State.grids.tiles[self_e.position]
      if not tile or tile.codename ~= "grassl" then return end

      if State.grids.solids[self_e.position]
        or State.grids.on_solids[self_e.position]
      then return end

      State:add(
        Random.choice(on_solids.grassl, on_solids.grassh)(),
        {position = self_e.position, grid_layer = "on_solids"}
      )
    end
  end

  local ps = State.runner.positions
  local ch = State.runner.entities

  local start = ps.create_water_start
  local finish = ps.create_water_finish
  for x = start.x, finish.x do
    for y = start.y, finish.y do
      local p = V(x, y)
      local tile = State.grids.tiles:unsafe_get(x, y)
      if p == ps.create_water_exception then
        goto continue
      end

      if not State.grids.solids:unsafe_get(x, y) then
        local w = State:add(
          solids_entities.water_down(), {position = p, grid_layer = "solids"}
        )
        table.insert(self._water, w)
      end
      if tile then
        State:remove(tile)
      end

      ::continue::
    end
  end

  for _, water in ipairs(self._water) do
    water.water_velocity = water.water_velocity * 4
  end

  ch.coast_birds_1.sound_source.source:setVolume(.2)
  ch.coast_birds_2.sound_source.source:setVolume(.2)

  ch.blocker_1.immovable_flag = true
  ch.blocker_2.immovable_flag = true
  api.assert_position(ch.blocker_1, ps.blocker_move_1, true)
  api.assert_position(ch.blocker_2, ps.blocker_move_2, true)
  api.rotate(ch.blocker_1, ps.feast_pyre)
  api.rotate(ch.blocker_2, ps.feast_pyre)

  for i = 1, 3 do
    State.runner.entities["dungeon_blocker_" .. i] = State:add(
      solids_entities.path_blocker(),
      {position = ps["dungeon_entrance_" .. i], grid_layer = "solids"}
    )
  end

  api.travel_crowd(self:get_crowd(), ps.massacre_crowd):next(function()
    api.assert_position(ch.green_priest, ps.feast_throw_priest, true)
    api.assert_position(ch.red_priest, ps.massacre_red_priest, true)
    api.assert_position(ch.watcher_1, ps.feast_sac_3 + Vector.up, true)
    api.assert_position(ch.watcher_2, ps.ma_watcher_2, true)
    api.assert_position(ch.watcher_3, ps.ma_watcher_3, true)
  end)

  State.shader = nil
  Log.info("Winter ends")

  self.winter = "ended"
end

local feast_base = {
  name = "Празднование",
  status = "new",
  objectives = {
    {status = "new", text = "Найти оружие"},
    {status = "new", text = "Присоединиться к церемонии на храмовой площади"},
  },
}

methods.feast_start = function(self)
  assert(self.feast == nil)
  self.feast = "started"
  State.quests.items.feast = Table.deep_copy(feast_base)
  api.journal_update("new_task")
end

methods.feast_weapon_found = function(self)
  assert(self.feast == "started")
  State.quests.items.feast.objectives[1].status = "done"
  api.journal_update("task_completed")
end

methods.feast_end = function(self)
  assert(self.feast == "started" or self.feast == "weapon_found")

  local q = State.quests.items.feast
  q.status = "done"
  for _, o in ipairs(q.objectives) do
    o.status = "done"
  end
  api.journal_update("task_completed")

  self.feast = "done"
end

local seekers_base = {
  name = "Искатели",
  status = "new",
  objectives = {
    {status = "new", text = "Найти плод дерева Акуль в лесу"},
  },
}

methods.seekers_start = function(self)
  assert(self.seekers == nil)

  State.quests.items.seekers = Table.deep_copy(seekers_base)
  api.journal_update("new_task")

  self.seekers = "started"
end

local seekers_fruit_is_found = function(self)
  assert(self.seekers == "started")

  local seekers = State.quests.items.seekers
  seekers.objectives[1].status = "done"
  seekers.objectives[2] = {
    status = "new",
    text = "Вернуться на праздник в деревню",
  }
  api.journal_update("new_task")

  self.seekers = "fruit_found"
end

seekers_fruit_is_missed = function(self)
  assert(self.seekers == "started")
  Table.last(State.quests.items.seekers.objectives).status = "failed"
end

methods.seekers_run_away = function(self)
  assert(self.seekers == "started" or self.seekers == "fruit_found")

  local seekers = State.quests.items.seekers
  local last_task = Table.last(seekers.objectives)
  if last_task.status == "new" or last_task.status == "active" then
    last_task.status = "done"
  end

  table.insert(seekers.objectives, {
    status = "new",
    text = "Бежать из деревни",
  })
  api.journal_update("new_task")

  self.seekers = "run_away"
end

--- @param self rails
seekers_in_dungeon = function(self)
  assert(self.seekers == "run_away")

  local seekers = State.quests.items.seekers
  Table.last(seekers.objectives).status = "done"
  table.insert(seekers.objectives, {
    status = "new",
    text = "Найти выход из пещер",
  })
  api.journal_update("new_task")

  self.seekers = "find_exit"
end

methods.berries_eat = function(self)
  if not self.tried_berries then
    self.tried_berries = "once"
  elseif self.tried_berries == "once" then
    self.tried_berries = "twice"
  else
    Error("Eating berries more than 1 time (%s)", self.tried_berries)
  end
end

methods.fruit_take_khaneds = function(self)
  assert(self.fruit_source == nil)
  State:remove(State.runner.entities.khaned_fruit)
  self.fruit_source = "khaned"
  self.has_fruit = true

  seekers_fruit_is_found(self)
end

methods.fruit_take_likkas = function(self)
  assert(self.fruit_source == nil)
  State:remove(State.runner.entities.likka_fruit)
  self.fruit_source = "likka"
  self.has_fruit = true

  seekers_fruit_is_found(self)
end

methods.fruit_take_own = function(self, fruit)
  assert(self.fruit_source == nil)
  State:remove(fruit)
  self.fruit_source = "found"
  self.has_fruit = true

  seekers_fruit_is_found(self)
end

methods.fruit_eat = function(self)
  self.has_fruit = false
  self.has_blessing = true

  assert(self.seekers == "fruit_found")
  State.quests.items.seekers.objectives[1].status = "failed"
end

methods.fruit_see_companion = function(self)
  self.seen_companion_fruit = true
end

methods.fruit_sac = function(self)
  assert(self.has_fruit == true)
  self.has_fruit = false
end

methods.rotten_fruit_touch = function(self)
  assert(self.seen_rotten_fruit == nil)
  self.seen_rotten_fruit = true
end

methods.rotten_fruit_eat = function(self, fruit)
  assert(self.ate_rotten_fruit == nil)
  State:remove(fruit)
  self.ate_rotten_fruit = true
end

methods.khaned_offscreen_death = function(self)
  assert(self.khaned_status == nil)

  local ch = State.runner.entities
  ch.khaned.essential_flag = nil
  health.set_hp(ch.khaned, 0)
  State:remove(ch.khaned_fruit)
  State:remove(ch.invader)

  self.khaned_status = "dead"
end

methods.khaned_leaves = function(self, forced)
  assert(self.khaned_status == nil)

  local ch = State.runner.entities
  local ps = State.runner.positions

  api.assert_position(ch.khaned, ps.feast_sac_3, forced)
  api.rotate(ch.khaned, ps.feast_pyre)

  if State:exists(ch.khaned_fruit) then
    if not forced then
      Log.warn("Khaned's fruit not properly removed")
    end
    State:remove(ch.khaned_fruit)
  end
  api.autosave("Лес - Пришелец побеждён")

  self.khaned_status = "survived"
end

methods.likka_died = function(self)
  assert(self.likka_status == nil)

  local ch = State.runner.entities
  assert(not State:exists(ch.likka))
  api.autosave("Руины - Повидался с Ликкой")

  self.likka_status = "dead"
end

methods.likka_went_to_village = function(self, forced)
  assert(self.likka_status == nil)

  local ch = State.runner.entities
  local ps = State.runner.positions
  api.assert_position(ch.likka, ps.feast_sac_2, forced)
  api.rotate(ch.likka, ps.feast_pyre)

  self.likka_status = "village"
end

methods.likka_left_in_temple = function(self)
  assert(self.likka_status == nil)

  local ch = State.runner.entities
  assert(State:exists(ch.likka))
  State:remove(ch.likka)

  self.likka_status = "temple"
end

methods.gatherer_run_away = function(self)
  assert(self.gatherer_status == nil)
  self.gatherer_status = "ran_away"
end

methods.temple_enter = function(self)
  assert(self.temple == nil)
  assert(self.location == "2_forest")

  self:_sublocation_enter("3_temple")
  local ch = State.runner.entities
  assert(getmetatable(ch.likka.ai) == combat.mt)
  ch.likka.ai = likka_ai.new(ch.likka.ai --[[@as combat_ai]])
  State.hostility:set(State.player.faction, "likka")
  State.hostility:set("likka", State.player.faction, "ally")

  for e in pairs(State._entities) do
    if e._is_a_skeleton then
      e.ai = combat.new()
      e.ai:init(e)
    end
  end

  api.autosave("Руины - Вход")

  self.temple = "entered"
end

methods.temple_exit = function(self)
  assert(self.temple == "entered")
  assert(self.location == "2_forest")

  self:_sublocation_exit("3_temple")

  local ch = State.runner.entities
  local ps = State.runner.positions

  level.unsafe_move(ch.player, ps.er_up)
  ch.temple_exit.interact = nil
  assert(getmetatable(ch.likka.ai) == likka_ai.mt)
  ch.likka.ai = ch.likka.ai._combat_component
  State.hostility:set(State.player.faction, "likka", "ally")
  State.hostility:set("likka", State.player.faction)

  for e in pairs(State._entities) do
    if e._is_a_skeleton then
      e.ai = no_op.new()
    end
  end

  api.autosave("Руины - Выход")

  self.temple = "exited"
end

methods.empathy_start_conversation = function(self)
  assert(self.empathy == nil)
  self.empathy = 0
end

methods.empathy_raise = function(self)
  assert(type(self.empathy) == "number")
  self.empathy = self.empathy + 1
end

methods.empathy_lower = function(self)
  assert(type(self.empathy) == "number")
  self.empathy = self.empathy - 1
end

methods.empathy_finalize = function(self)
  assert(type(self.empathy) == "number")
  if self.empathy >= 0 then
    self.empathy = "present"
  else
    self.empathy = "denied"
  end
end

methods.nea_meet = function(self)
  assert(self.met_nea == nil)
  self.met_nea = true
end

methods.rain_start = function(self)
  assert(self._rain == nil)
  self._rain = State:add(rain.new(1/3, 15))
end

methods.rain_intensify = function(self)
  assert(self._rain)
  self._rain.rain_density = 1
end

methods.rain_finish = function(self)
  assert(self._rain)
  State:remove(self._rain)
  self._rain = nil
end


----------------------------------------------------------------------------------------------------
-- [SECTION] Initialization
----------------------------------------------------------------------------------------------------

local init_blockers, init_factions, init_loot, init_shadows, init_debug
local checkpoints = {}

--- @param checkpoint string?
methods.init = function(self, checkpoint)
  init_blockers(self)
  init_factions(self)
  State.quests.order = {"seekers", "feast"}
  init_loot(self)
  init_shadows(self)
  init_debug(self)
  checkpoints[checkpoint or "intro"](self)
end

--- @param self rails
init_blockers = function(self)
  local misses = {}
  local updated_n = 0
  for entity in pairs(State._entities) do
    if entity._vision_invisible_flag then
      local target = State.grids.solids:slow_get(entity.position)
      if target then
        target.transparent_flag = nil
        updated_n = updated_n + 1
      else
        table.insert(misses, tostring(entity.position))
      end
      State:remove(entity)
    end
  end

  if #misses > 0 then
    Log.warn("Vision blocker misses: %s", table.concat(misses, ", "))
  end

  tcod.update_transparency(State.grids.solids)
  Log.info("Blocked vision for %s cells", updated_n)
end

local hostile = function(a, ...)
  for i = 1, select("#", ...) do
    local b = select(i, ...)
    State.hostility:set(a, b, "enemy")
    State.hostility:set(b, a, "enemy")
  end
end

local ally = function(a, ...)
  for i = 1, select("#", ...) do
    local b = select(i, ...)
    State.hostility:set(a, b, "ally")
    State.hostility:set(b, a, "ally")
  end
end

--- @param self rails
init_factions = function(self)
  hostile("predators", "player", "khaned")
  ally("player", "khaned", "village")

  -- player is likka's ally only inside the temple
end

--- @param sequence string
--- @param money integer
--- @param items item[]
local put_loot = function(sequence, money, items)
  local starts = State.runner:position_sequence(sequence)
  local ends = State.runner:position_sequence(sequence .. "_end")

  local containers = {}
  for _, start, finish in Fun.zip(starts, ends) do
    for _, _, v in State.grids.solids:rectv(start, finish) do
      if v and v._is_container then
        containers[v] = true
      end
    end
  end

  containers = Table.keys(containers)

  local money_dist = Random.distribute(money, #containers)
  local item_dist = Random.distribute_items(items, #containers)

  for _, e, amount, dropped_items in Fun.zip(containers, money_dist, item_dist) do
    local base_interact = assert(e.on_interact)
    e.on_interact = function(self_e, other)
      if other ~= State.player then return end
      if amount > 0 then
        State.player.bag.money = State.player.bag.money + amount
        State:add(floater.new("+" .. amount, State.player.position, colors.white))
        sound.multiple("assets/sounds/money", .15):play()
      end
      item.drops(e.position, unpack(dropped_items))
      base_interact(self_e, other)
    end
    Ldump.ignore_upvalue_size(e.on_interact)
  end

  Log.info("Distributed loot in %q between %s containers", sequence, #containers)
end

--- @param self rails
init_loot = function(self)
  put_loot("loot_temple", 1200, {items_entities.ritual_blade(), items_entities.shield()})
  put_loot("house", 420, {items_entities.bear_spear(), items_entities.long_bow()})
end

--- @param self rails
init_shadows = function(self)
  local sometimes = async.sometimes()

  local size = State.level.grid_size
  local exclude = State.runner:position_sequence("no_tree_shadow")

  --- @type vector[]
  local trees do
    trees = {}
    for x = 1, size.x do
      for y = 1, size.y do
        local e = State.grids.solids:unsafe_get(x, y)
        if e and e._tree_flag and not Table.contains(exclude, e.position) then
          table.insert(trees, e.position)
        end
      end
    end
  end

  local R1 = 4
  local R2 = 2
  local R1_SQ = R1^2
  local R2_SQ = R2^2

  local shadow_values = Grid.new(size, function() return 0 end)
  for _, tree in ipairs(trees) do
    for x, y, v in shadow_values:rect(tree.x - R1, tree.y - R1, tree.x + R1, tree.y + R1) do
      local d_sq = (x - tree.x)^2 + (y - tree.y)^2 + math.random(-2, 2)
      local value
      if d_sq <= R2_SQ then
        value = 4
      elseif d_sq <= R1_SQ then
        value = 2
      else
        goto continue
      end
      shadow_values:unsafe_set(x, y, math.max(value, v))

      ::continue::
    end
  end

  local total_n = size.x * size.y

  for x = 1, size.x do
  for y = 1, size.y do
    sometimes:yield("rails_init", ((x - 1) * size.y + y - 1) / total_n)
    local n = shadow_values:unsafe_get(x, y)
    if n == 0 or State.grids.shadows:unsafe_get(x, y) then goto continue end

    local position = V(x, y)
    if self:is_indoors(position) then goto continue end

    State:add(shadows[16 - n](), {position = position, grid_layer = "shadows"})

    ::continue::
  end
  end
end

--- @param self rails
init_debug = function(self)
  if not State.debug then return end
end


----------------------------------------------------------------------------------------------------
-- [SECTION] Checkpoints
----------------------------------------------------------------------------------------------------

--- @param self rails
checkpoints.intro = function(self)
  self:winter_init()
  self:location_intro()
  health.set_hp(State.player, State.player:get_max_hp() - 2)
  State.hostility:set("player", "likka", "ally")
end

--- @param self rails
checkpoints.cp1 = function(self)
  self:winter_init()
  self:location_upper_village(true)
  self:feast_start()
  api.assert_position(State.player, State.runner.positions.cp1, true)
  item.give(State.player, State:add(items_entities.short_bow()))
end

--- @param self rails
checkpoints.cp2 = function(self)
  self:winter_init()
  self:winter_end()
  self:location_forest(true)
  self:feast_start()
  self:feast_end()
  self:seekers_start()

  api.assert_position(State.player, State.runner.positions.cp2, true)
  item.give(State.player, State:add(items_entities.axe()))
  item.give(State.player, State:add(items_entities.small_shield()))
end

--- @param self rails
checkpoints.cpt = function(self)
  self:winter_init()
  self:winter_end()
  self:location_forest(true)
  self:feast_start()
  self:feast_end()
  self:seekers_start()
  self:temple_enter()
  self:fruit_take_khaneds()
  self:empathy_start_conversation()

  api.assert_position(State.player, State.runner.positions.cpt, true)
  item.give(State.player, State:add(items_entities.axe()))
  item.give(State.player, State:add(items_entities.small_shield()))

  State.runner:remove("_100_saving_likka")
end

--- @param self rails
checkpoints.cpt2 = function(self)
  self:winter_init()
  self:winter_end()
  self:location_forest(true)
  self:feast_start()
  self:feast_end()
  self:seekers_start()
  self:temple_enter()
  self:empathy_start_conversation()

  local ch = State.runner.entities
  local ps = State.runner.positions

  api.assert_position(ch.player, ps.cpt2, true)
  api.assert_position(ch.likka, ps.cpt2 + Vector.right, true)
  item.give(ch.player, State:add(items_entities.axe()))
  item.give(ch.player, State:add(items_entities.small_shield()))

  health.damage(ch.cpt2_cobweb, 1)

  State.runner:remove("_100_saving_likka")
end

--- @param self rails
checkpoints.cpt3 = function(self)
  self:winter_init()
  self:winter_end()
  self:location_forest(true)
  self:feast_start()
  self:feast_end()
  self:seekers_start()
  self:temple_enter()
  self:empathy_start_conversation()
  self:empathy_finalize()
  self:fruit_take_khaneds()
  self:fruit_eat()
  self:berries_eat()

  local ch = State.runner.entities
  local ps = State.runner.positions

  api.assert_position(ch.player, ps.cpt3, true)
  api.assert_position(ch.likka, ps.cpt3 + Vector.right, true)
  item.give(ch.player, State:add(items_entities.axe()))
  item.give(ch.player, State:add(items_entities.small_shield()))

  health.damage(ch.cpt2_cobweb, 1)

  State.runner:remove("_100_saving_likka")
end

--- @param self rails
checkpoints.cp4 = function(self)
  self:winter_init()
  self:winter_end()
  self:feast_start()
  self:feast_end()
  self:seekers_start()
  -- self:fruit_take_own({})
  -- self:likka_went_to_village(true)
  self:khaned_leaves(true)
  self:location_village(true)

  api.assert_position(State.player, State.runner.positions.cp4, true)
  item.give(State.player, State:add(items_entities.ritual_blade()))
  item.give(State.player, State:add(items_entities.shield()))
  item.give(State.player, State:add(items_entities.invader_helmet()))
  item.give(State.player, State:add(items_entities.invader_armor()))
end

Ldump.mark(rails, {}, ...)
return rails
