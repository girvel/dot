return {
  --- @type scene
  likka_drops_fruit = {
    enabled = true,
    start_predicate = function(self, dt)
      return not State:exists(State.runner.entities.likka)
    end,

    run = function(self)
      local ch = State.runner.entities
      if State.rails.fruit_source then
        if State:exists(ch.likka_fruit) then
          State:remove(ch.likka_fruit)
        end
      elseif not State:exists(ch.likka_fruit) then
        State:add(ch.likka_fruit, {position = ch.likka.position})
      end
    end,
  },
}
