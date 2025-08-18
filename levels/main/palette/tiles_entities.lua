local _common = require "levels.main.palette._common"
local tiles_entities = {}

tiles_entities.walkable_water = _common.water(Vector.down * .5)

return tiles_entities
