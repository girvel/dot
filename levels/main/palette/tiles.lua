local tiles = {}

tiles.ATLAS_IMAGE = love.graphics.newImage("assets/sprites/atlases/tiles.png")

tiles[1] = function()
  return {
    sprite = {
      type = "atlas",
      -- TODO! cell_size should be in level definition
      quad = love.graphics.newQuad(0, 0, 16, 16, tiles.ATLAS_IMAGE:getDimensions()),
    }
  }
end

return tiles
