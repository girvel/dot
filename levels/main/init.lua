local config = require("levels.main.config")


--- @type level_definition
return {
  ldtk = {
    path = "levels/main/main.ldtk",
    level = "Level_0",
  },

  palette = {
    tiles = require("levels.main.palette.tiles"),
    tiles_entities = require("levels.main.palette.tiles_entities"),
    on_tiles = require("levels.main.palette.on_tiles"),
    solids_entities = require("levels.main.palette.solids_entities"),
    solids = require("levels.main.palette.solids"),
  },

  cell_size = config.cell_size,
}
