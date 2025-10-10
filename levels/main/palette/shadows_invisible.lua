local factoring = require("engine.tech.factoring")


local shadows = {}
for i = 1, 16 do
  shadows[i] = function() end
end

Ldump.mark(shadows, "const", ...)
return shadows
