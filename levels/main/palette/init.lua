local tiles = require("levels.main.palette.tiles")
local tiles_entities = require("levels.main.palette.tiles_entities")
local on_tiles = require("levels.main.palette.on_tiles")
local solids_entities = require("levels.main.palette.solids_entities")
local solids = require("levels.main.palette.solids")
local vision_invisible = require("levels.main.palette.vision_invisible")
local items_entities = require("levels.main.palette.items_entities")
local on_solids_entities = require("levels.main.palette.on_solids_entities")
local on_solids = require("levels.main.palette.on_solids")
local shadows = require("levels.main.palette.shadows")
local sounds_invisible = require("levels.main.palette.sounds_invisible")

return {
  tiles = Table.extend({}, tiles, tiles_entities),
  on_tiles = on_tiles,
  solids = Table.extend({}, solids, solids_entities),
  items = items_entities,
  on_solids = Table.extend({}, on_solids, on_solids_entities),
  shadows = shadows,

  vision = vision_invisible,
  sounds = sounds_invisible,
}
