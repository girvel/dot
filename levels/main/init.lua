local config = require("levels.main.config")


--- @type level_definition
return {
  ldtk = {
    path = "levels/main/main.ldtk",
    level = "Level_0",
  },

  palette = require("levels.main.palette"),

  cell_size = config.cell_size,

  rails = {
    factory = require("levels.main.rails").new,
    scenes = require("levels.main.scenes"),
  },
}
