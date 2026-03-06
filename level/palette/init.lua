local tiles = require("level.palette.tiles")
local tiles_entities = require("level.palette.tiles_entities")
local on_tiles = require("level.palette.on_tiles")
local solids_entities = require("level.palette.solids_entities")
local solids = require("level.palette.solids")
local vision_invisible = require("level.palette.vision_invisible")
local items_entities = require("level.palette.items_entities")
local on_solids_entities = require("level.palette.on_solids_entities")
local on_solids = require("level.palette.on_solids")
local shadows = require("level.palette.shadows")
local sounds_invisible = require("level.palette.sounds_invisible")

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
