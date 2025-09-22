local vision_invisible = {}

vision_invisible.blocker = function()
  return {_vision_invisible_flag = true, boring_flag = true}
end

vision_invisible[562] = vision_invisible.blocker

return vision_invisible
