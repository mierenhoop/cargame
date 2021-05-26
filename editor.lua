local ui = require "ui"
local gamestate = require "game"
local utils = require "utils"
local struct = require "struct"
local http = require "socket.http"

local level = require "level"

local state = {}

local map

local firstpoint

local buttons = {
   "move",
   "line",
   "bike",
   "flag",
   "play",
   "load",
   "-",
   "+",
}

local mode

local buttonwidth, buttonheight = 40, 40

function buttonpos(m)
   return (m - 1) * buttonheight
end

local view

local function gettransform()
   local w, h = love.graphics.getDimensions()
   local t = love.math.newTransform()
   t:translate(view.x + w / 2, view.y + h / 2)
   t:scale(view.scale, view.scale)
   return t
end

local function intersectcircle(p1, p2, r)
   local dx, dy = p1.x - p2.x, p1.y - p2.y
   return math.sqrt(dx * dx + dy * dy) < r
end
         
local radius = 10

function getradius()
   return radius / view.scale
end

function state.load(filename)
   if filename then
      map = level.fromfile(filename)
   else
      map = level.new()
   end
   view = {
      scale = 1,
      x = 0,
      y = 0,
   }

   mode = 2
end

function state.mousepressed(x, y, button)
   local lx, ly = gettransform():inverseTransformPoint(x, y)
   if x < buttonwidth then
      print (mode)
      for i in ipairs(buttons) do
         if ui.hovered(0, buttonpos(i), buttonwidth, buttonheight) then
            if buttons[i] == "+" then
               view.scale = view.scale * 1.2
            elseif buttons[i] == "-" then
               view.scale = view.scale * 0.8
            elseif buttons[i] == "play" then
               utils.reloadstate(gamestate, map, function()
                  local m, v = map, view
                  utils.reloadstate(state)
                  map, view = m, v
               end)
            elseif buttons[i] == "load" then
               local url = love.system.getClipboardText()
               url = string.gsub(url, "https://", "http://")
               local body = http.request(url)

               local scale = 200

               if body then
                  map.lines = {}

                  local points = {struct.unpack(">".. string.rep("f", #body / 4 - 2), body, 9)}

                  map.player = { x = points[5] * scale, y = points[6] * -scale - 100}
                  map.flag = { x = points[7] * scale, y = points[8] * -scale }

                  for i = 9, #points - 2, 4 do 
                     table.insert(map.lines, { { x = points[i] * scale, y = points[i + 1] * -scale }, { x = points[i + 2] * scale, y = points[i + 3] * -scale } })
                  end
               else
                  print "couldn't load link"
               end
            else
               mode = i
            end
            break
         end
      end
   else
      if buttons[mode] == "line" then
         for _, line in ipairs(map.lines) do
            for i = 1, 2 do
               if intersectcircle(line[i], { x = lx, y = ly }, getradius()) then
                  lx, ly = line[i].x, line[i].y
                  goto out
               end
            end
         end
         ::out::
         if not firstpoint then
            firstpoint = { x = lx, y = ly }
         else
            table.insert(map.lines, { firstpoint, { x = lx, y = ly } })
            firstpoint = nil
         end
      elseif buttons[mode] == "bike" then
         map.player = { x = lx, y = ly }                  
      elseif buttons[mode] == "flag" then
         map.flag = { x = lx, y = ly }                  
      end
   end
end


function state.mousemoved(x, y, dx, dy)
   if x > buttonwidth and love.mouse.isDown(1) then
      if buttons[mode] == "move" then
         view.x, view.y = view.x + dx, view.y + dy
      end
   end
end

function state.draw()
   love.graphics.origin()
   love.graphics.applyTransform(gettransform())
      
   local x, y = love.mouse.getPosition()
   local lx, ly = gettransform():inverseTransformPoint(x, y)

   level.draw(map)

   if map.player then
      love.graphics.circle("fill", map.player.x, map.player.y, 10)
   end

   love.graphics.setColor(0, 0, 1)
   for _, line in ipairs(map.lines) do
      for i = 1, 2 do
         if intersectcircle(line[i], { x = lx, y = ly }, getradius()) then
            love.graphics.circle("fill", line[i].x, line[i].y, getradius())
         end
      end
   end

   love.graphics.setColor(1, 1, 1)
   if buttons[mode] ~= "line" then firstpoint = nil end
   if firstpoint then
      love.graphics.line(firstpoint.x, firstpoint.y, lx, ly)
   end

   love.graphics.origin()

   for m in ipairs(buttons) do
      ui.drawbutton(0, buttonpos(m), buttonwidth, buttonheight, buttons[m])
   end
end

return state
