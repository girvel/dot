--- @type level_definition
return {
  ldtk_path = "levels/main/main.ldtk",
  palette = require("levels.main.palette"),
  rails = require("levels.main.rails").new(),
  scenes = require("levels.main.init_scenes"),
}
