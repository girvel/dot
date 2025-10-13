local on_solids = require("levels.main.palette.on_solids")
local solids_entities = require("levels.main.palette.solids_entities")
local api = require "engine.tech.api"
local winter = require "engine.tech.shaders.winter"
local combat = require "engine.mech.ais.combat"
local likka_ai = require "levels.main.palette.likka_ai"


local rails = {}

--- @alias rails_location "0_intro"|"1_upper_village"|"2_forest"?

--- @class rails
--- @field runner state_runner
--- @field location rails_location
--- @field feast "started"|"weapon_found"|"ceremony"|"done"?
--- @field winter "initialized"|"ended"?
--- @field seekers "started"|"fruit_found"?
--- @field tried_berries "once"|"twice"?
--- @field fruit_source "likka"|"khaned"|"found"?
--- @field seen_rotten_fruit boolean?
--- @field eaten_rotten_fruit boolean?
--- @field seen_companion_fruit boolean?
--- @field has_blessing boolean?
--- @field has_fruit boolean?
--- @field khaned_status "dead"|"survived"?
--- @field gatherer_status "ran_away"?
--- @field likka_saw_bad_trip boolean?
--- @field temple "entered"|"exited"?
--- @field _scenes_by_location table
--- @field _snow entity[]?
--- @field _water entity[]?
local methods = {}
local mt = {__index = methods}

--- @return rails
rails.new = function()
  local scenes_by_location do
    scenes_by_location = {}
    local scenes_folder = Table.require_folder("levels.main.scenes")
    for k, subfolder in pairs(scenes_folder) do
      scenes_by_location[k] = {}
      for _, v in pairs(subfolder) do
        Table.extend_strict(scenes_by_location[k], v)
      end
    end
  end

  return setmetatable({
    _scenes_by_location = scenes_by_location,
  }, mt)
end

--- @param location rails_location
--- @param forced boolean?
methods._location_transition = function(self, location, forced)
  assert(
    forced
      or self.location == nil and location and location:sub(1, 1) == "0"
      or location and self.location
        and tonumber(location:sub(1, 1)) - tonumber(self.location:sub(1, 1)) == 1,
    ("Out of order transition %s -> %s"):format(self.location, location)
  )
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
end

methods.winter_init = function(self)
  assert(self.winter == nil)

  State.shader = winter
  self._snow = State.grids.on_tiles:iter():filter(function(e) return e.winter_flag end):totable()
  self._water = State.grids.solids:iter():filter(function(e) return e.water_velocity end):totable()
  self.winter = "initialized"

  Log.info("Winter initialized")
end

methods.winter_end = function(self)
  assert(self.winter == "initialized")

  for _, e in ipairs(self._snow) do
    State:add(e, {life_time = Random.float(0, 30)})
    e.on_remove = function(self)
      local tile = State.grids.tiles[self.position]
      local solid = State.grids.solids[self.position]
      local on_solid = State.grids.on_solids[self.position]

      if tile and tile.codename == "grassl" and not solid and not on_solid then
        State:add(
          Random.choice(on_solids.grassl, on_solids.grassh)(),
          {position = self.position, grid_layer = "on_solids"}
        )
      end
    end
  end

  local ps = State.runner.positions
  local start = ps.create_water_start
  local finish = ps.create_water_finish
  for x = start.x, finish.x do
    for y = start.y, finish.y do
      local p = V(x, y)
      local tile = State.grids.tiles:unsafe_get(x, y)
      if p == ps.create_water_exception then
        table.insert(self._water, tile)
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

  State.shader = nil
  self.winter = "ended"

  Log.info("Winter ends")
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

methods.fruit_eat = function(self)
  self.has_fruit = false
  self.has_blessing = true

  assert(self.seekers == "fruit_found")
  State.quests.items.seekers.objectives[1].status = "failed"
end

methods.fruit_see_companion = function(self)
  self.seen_companion_fruit = true
end

methods.khaned_offscreen_death = function(self)
  assert(self.khaned_status == nil)

  local ch = State.runner.entities
  State:remove(ch.khaned)
  State:remove(ch.khaned_fruit)
  State:remove(ch.invader)
  api.autosave("Повидался с Ханедом")

  self.khaned_status = "dead"
end

methods.khaned_leaves = function(self)
  assert(self.khaned_status == nil)

  local ch = State.runner.entities
  local ps = State.runner.positions
  api.assert_position(ch.khaned, ps.feast_sac_1)
  if State:exists(ch.khaned_fruit) then
    Log.warn("Khaned's fruit not properly removed")
    State:remove(ch.khaned_fruit)
  end
  api.autosave("Пришелец побеждён")

  self.khaned_status = "survived"
end

methods.gatherer_run_away = function(self)
  assert(self.gatherer_status == nil)
  self.gatherer_status = "ran_away"
end

methods.temple_enter = function(self)
  assert(self.temple == nil)
  assert(self.location == "2_forest")

  local ch = State.runner.entities
  assert(getmetatable(ch.likka.ai) == combat.mt)
  ch.likka.ai = likka_ai.new(ch.likka.ai --[[@as combat_ai]])
  State.hostility:set(State.player.faction, "likka")
  State.hostility:set("likka", State.player.faction, "ally")

  self.temple = "entered"
end

methods.temple_exit = function(self)
  assert(self.temple == "entered")
  assert(self.location == "2_forest")

  local ch = State.runner.entities
  assert(getmetatable(ch.likka.ai) == likka_ai.mt)
  ch.likka.ai = ch.likka.ai._combat_component
  State.hostility:set(State.player.faction, "likka", "ally")
  State.hostility:set("likka", State.player.faction)

  self.temple = "exited"
end

Ldump.mark(rails, {}, ...)
return rails
