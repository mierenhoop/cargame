local level = {}

--[[
Level file:
p $x $y (Player position)
f $x $y (Flag position)
l $x1 $y1 $x2 $y2 (Line)
]]


function level.new()
   return {
      player = {x = 0, y = 0},
      lines = {}
   }
end

local flagimage = love.graphics.newImage "data/flag.png"

local flagscale = 0.3

function level.draw(l)
   for _, line in ipairs(l.lines) do
      love.graphics.setColor(1, 1, 1)
      love.graphics.line(line[1].x, line[1].y, line[2].x, line[2].y)
   end
   
   if l.flag then
      love.graphics.setColor(1, 1, 1)
      love.graphics.draw(flagimage, l.flag.x, l.flag.y, 0, flagscale, flagscale, flagimage:getWidth() / 12, flagimage:getHeight())
   end
end


return level
