local _common = require "levels.main.palette._common"
local tiles_entities = {}

tiles_entities.walkable_water_down = _common.water(Vector.down * .5)
tiles_entities.walkable_water_right = _common.water(Vector.right * .5)
tiles_entities.walkable_water_still = _common.water(Vector.zero)

Ldump.mark(tiles_entities, "const", ...)
return tiles_entities
