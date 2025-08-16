local solids_entities = {}

solids_entities.player = function()
  return {
    codename = "player",
    player_flag = true,
    sprite = {
      type = "image",
      image = love.graphics.newImage("engine/assets/sprites/moose_dude.png"),
    },
  }
end

return solids_entities
