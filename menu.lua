Game.states.menustate = {}
local menustate = Game.states.menustate

local ui = {}

function generateui()
   ui.playbutton = {
      label = "Play!",
      x = love.graphics.getWidth() / 2,
      y = 50,
      w = 100,
      h = 50
   }
end

function isbuttonhovered(b)
   local x, y = love.mouse.getPosition()
   return b.x < x and x < b.x + b.w and b.y < y and y < b.y + b.h
end

function drawbutton(b)
   love.graphics.setColor(1, 1, 1, isbuttonhovered(b) and 0.5 or 1)
   love.graphics.polygon("fill", b.x, b.y, b.x + b.w, b.y, b.x + b.w, b.y + b.h, b.x, b.y + b.h)

   love.graphics.setColor(0, 0, 0, 1)
   love.graphics.print(b.label, b.x + 10, b.y + 10)
end

function menustate.load()
   generateui()
end

function menustate.mousereleased()
   if isbuttonhovered(ui.playbutton) then
      ReloadState("gamestate")
   end
end

function menustate.draw()
   drawbutton(ui.playbutton)
end
