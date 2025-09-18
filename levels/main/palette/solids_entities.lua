local _common     = require("levels.main.palette._common")
local player    = require("levels.main.palette.player")


local solids_entities = {}

solids_entities.player = player.new
solids_entities.water = _common.water(Vector.down * .5)

Table.extend(
  solids_entities,
  require("levels.main.palette.npcs"),
  require("levels.main.palette.wildlife")
)

return solids_entities
