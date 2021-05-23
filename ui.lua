local ui = {}

function ui.hovered(x, y, w, h)
   local mx, my = love.mouse.getPosition()
   return x < mx and mx < x + w and y < my and my < y + h
end

function ui.drawbutton(x, y, w, h, label)
   love.graphics.setColor(1, 1, 1, ui.hovered(x, y, w, h) and 0.5 or 1)
   love.graphics.rectangle("fill", x, y, w, h)

   love.graphics.setColor(0, 0, 0, 1)
   if label then
      love.graphics.print(label, x + 10, y + 10)
   end
end

return ui
