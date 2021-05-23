local ui = require "ui"

local editorstate = {}
Game.states.editorstate = editorstate

local lines = {}

local firstpoint

local modes = {
   [1] = "move",
   [2] = "line"
}

local mode = 2

local buttonwidth, buttonheight = 40, 40

function buttonpos(m)
   return (m - 1) * buttonheight
end

local view = {
   scale = 1,
   x = 0,
   y = 0,
}


local function gettransform()
   local t = love.math.newTransform()
   t:translate(view.x, view.y)
   return t
end

local function intersectcircle(p1, p2, r)
   local dx, dy = p1.x - p2.x, p1.y - p2.y
   return math.sqrt(dx * dx + dy * dy) < r
end
         
local radius = 10

function editorstate.mousepressed(x, y, button)
   if x < buttonwidth then
      print (mode)
      for i in ipairs(modes) do
         if ui.hovered(0, buttonpos(i), buttonwidth, buttonheight) then
            mode = i
            break
         end
      end
   else
      if modes[mode] == "line" then
         local lx, ly = gettransform():inverseTransformPoint(x, y)
         for _, line in ipairs(lines) do
            for i = 1, 2 do
               if intersectcircle(line[i], { x = lx, y = ly }, radius) then
                  lx, ly = line[i].x, line[i].y
                  goto out
               end
            end
         end
         ::out::
         if not firstpoint then
            firstpoint = { x = lx, y = ly }
         else
            table.insert(lines, { firstpoint, { x = lx, y = ly } })
            firstpoint = nil
         end
      end
   end
end


function editorstate.mousemoved(x, y, dx, dy)
   if x > buttonwidth and love.mouse.isDown(1) then
      if modes[mode] == "move" then
         view.x, view.y = view.x + dx, view.y + dy
      end
   end
end

function editorstate.draw()
   love.graphics.origin()
   love.graphics.applyTransform(gettransform())
      
   local x, y = love.mouse.getPosition()
   local lx, ly = gettransform():inverseTransformPoint(x, y)

   for _, line in ipairs(lines) do
      love.graphics.setColor(1, 1, 1)
      love.graphics.line(line[1].x, line[1].y, line[2].x, line[2].y)

      love.graphics.setColor(0, 0, 1)
      for i = 1, 2 do
         if intersectcircle(line[i], { x = lx, y = ly }, radius) then
            love.graphics.circle("fill", line[i].x, line[i].y, radius)
         end
      end
   end

   love.graphics.setColor(1, 1, 1)
   if firstpoint then
      love.graphics.line(firstpoint.x, firstpoint.y, lx, ly)
   end

   love.graphics.origin()

   for m in ipairs(modes) do
      ui.drawbutton(0, buttonpos(m), buttonwidth, buttonheight, modes[m])
   end
end