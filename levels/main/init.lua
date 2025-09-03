local config = require("levels.main.config")


--- @type level_definition
return {
  ldtk = {
    path = "levels/main/main.ldtk",
    level = "Level_0",
  },

  palette = require("levels.main.palette"),

  layers = {
    "tiles",
    "on_tiles",
    "fx_under",
    "items",
    "solids",
    "fx_over",
    "on_solids",
  },

  cell_size = config.cell_size,

  rails = {
    factory = require("levels.main.rails").new,
    scenes = require("levels.main.scenes"),
  },
}
