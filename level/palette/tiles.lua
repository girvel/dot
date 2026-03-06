local factoring = require("engine.tech.factoring")
local sound  = require("engine.tech.sound")

local walk_sounds do
  local stone = sound.multiple("assets/sounds/walk/stone", .0125)
  local walkway = sound.multiple("assets/sounds/walk/walkway", .02)
  local planks = sound.multiple("assets/sounds/walk/planks", .02)

  walk_sounds = {
    dirt = walkway,
    walkway = walkway,
    planks = planks,
    stone = stone,
    bricks = stone,
    ornament = stone,
  }
end

local tiles = factoring.from_atlas("assets/sprites/atlases/tiles.png", Constants.cell_size, {
  "grassl",   "grassh",   "dirt",     "sand",     "roots", "leaves",  "flowers", "planks",
  "stone",    "stone",    "walkway",  "walkway",  "snow",  "leavest", "flowers", false,
  "bricks",   "bricks",   "gray",     false,      false,   false,     "flowers", false,
  "bricks",   "bricks",   false,      false,      false,   false,     "flowers", false,
  "ornament", "ornament", "ornament", "ornament", false,   false,     false,     false,
  "ornament", "ornament", "ornament", "ornament", false,   false,     false,     false,
  "ornament", "ornament", "ornament", "ornament", false,   false,     false,     false,
  "ornament", "ornament", "ornament", "ornament", false,   false,     false,     false,
}, function(codename)
  local s = walk_sounds[codename]
  return {
    boring_flag = true,
    sounds = s and {walk = s}
  }
end)

Ldump.mark(tiles, "const", ...)
return tiles
