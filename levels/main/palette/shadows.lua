local factoring = require("engine.tech.factoring")


local shadows = factoring.from_atlas("assets/sprites/atlases/shadows.png", 16, {
  "shadow", "shadow", "shadow", "shadow", "shadow", "shadow", "shadow", "shadow",
  "shadow", "shadow", "shadow", "shadow", "shadow", "shadow", "shadow", "shadow",
}, function()
  return {boring_flag = true}
end)

Ldump.mark(shadows, "const", ...)
return shadows
