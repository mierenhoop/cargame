local draw = {}

function draw.centered(image, x, y, r, sx, sy)
  love.graphics.draw(image, x, y, r or 0, sx or 1, sy or 1, image:getWidth()/2, image:getHeight()/2)
end

--[[
snapmode = "tl" | "tc" | "tr" 
         | "cl" | "cc" | "cr"
         | "bl" | "bc" | "br"
]]

function parseSnap(snapmode, x, y, w, h, sx, sy)
  sx, sy = sx or 1, sy or 1
  local sw, sh = love.window.getMode()
  local ymode, xmode = snapmode:sub(1,1), snapmode:sub(2,2)
  local px, py, ox, oy
  if xmode == "l" then
    
  elseif xmode == "c" then
  elseif xmode == "r" then
  end
end

local dummy = love.graphics.newText(love.graphics.getFont()

function draw.textbox(lines, w, snapmode, ox, oy)
  love.graphics.draw()
end

return draw