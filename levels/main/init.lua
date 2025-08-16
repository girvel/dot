local config = require("levels.main.config")


--- @type level_definition
return {
  ldtk = {
    path = "levels/main/main.ldtk",
    level = "Level_0",
  },

  palette = {
    tiles = require("levels.main.palette.tiles"),
    solids_entities = require("levels.main.palette.solids_entities"),
  },

  cell_size = config.cell_size,
}
