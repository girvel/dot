local factoring = require("engine.tech.factoring")
local sound  = require("engine.tech.sound")

local walk_sounds = {
  dirt      = sound.multiple("assets/sounds/walk/walkway", .2),
  walkway_2 = sound.multiple("assets/sounds/walk/walkway", .2),
  planks    = sound.multiple("assets/sounds/walk/planks",  .2),
}

local tiles = factoring.from_atlas("assets/sprites/atlases/tiles.png", Constants.cell_size, {
  "grassl",   "grassh",   "dirt",      "sand",      "roots",  "leaves_1", "flowers_1", "planks",
  "stone_1",  "stone_2",  "walkway_1", "walkway_2", "snow",   "leaves_2", "flowers_2", false,
  "bricks_1", "bricks_2", "gray",      false,       false,    false,      "flowers_3", false,
  "bricks_3", "bricks_4", false,       false,       false,    false,      "flowers_4", false,
  "ornament_1",  "ornament_2",  "ornament_3",  "ornament_4",  false, false, false, false,
  "ornament_5",  "ornament_6",  "ornament_7",  "ornament_8",  false, false, false, false,
  "ornament_9",  "ornament_10", "ornament_11", "ornament_12", false, false, false, false,
  "ornament_13", "ornament_14", "ornament_15", "ornament_16", false, false, false, false,
}, function(codename)
  local s = walk_sounds[codename]
  return {
    boring_flag = true,
    sounds = s and {walk = s}
  }
end)

Ldump.mark(tiles, "const", ...)
return tiles
