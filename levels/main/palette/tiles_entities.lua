local _common = require "levels.main.palette._common"
local tiles_entities = {}

tiles_entities.water = _common.water(Vector.down * .5)

return tiles_entities
