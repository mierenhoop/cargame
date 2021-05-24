local level = {}

--[[
Level file:
p $x $y (Player position)
f $x $y (Flag position)
l $x1 $y1 $x2 $y2 (Line)
]]


function level.new()
   return {
      player = {},
      flag = {},
      lines = {}
   }
end

function level.draw(l)
   for _, line in ipairs(l.lines) do
      love.graphics.setColor(1, 1, 1)
      love.graphics.line(line[1].x, line[1].y, line[2].x, line[2].y)
   end
   
   if l.flag then
      love.graphics.setColor(1, 1, 1, 0.2)
      love.graphics.rectangle("fill", l.flag.x, l.flag.y, 10000000, -10000000)
   end
end


return level
