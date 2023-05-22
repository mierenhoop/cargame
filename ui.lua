local ui = {}

---@class CollisionImage
---@field canvas love.Canvas
local CollisionImage = {}

---@param w number
---@param h number
---@return CollisionImage
function CollisionImage.new(w, h)
    local self = setmetatable({}, { __index = CollisionImage })

    self.canvas = love.graphics.newCanvas(w, h)

    return self
end


function CollisionImage:addImage(image)
    love.graphics.setCanvas(self.canvas)
    local id = math.random(0, 0xFFFFFF)


    love.graphics.setCanvas()
end

-- TODO: it's immediate mode so constructor not needed?
function ui.new()
    local self = setmetatable({}, { __index = ui })

    return self
end

local function contains(px, py, sx, sy, sw, sh)
    return sx < px and px < sx + sw
       and sy < py and py < sy + sh
end

---@param x number
---@param y number
---@param atlasPart AtlasPart
function ui:button(x, y, atlasPart)
    love.graphics.draw(atlasPart.image, atlasPart.quad, x, y)
    local px, py = love.mouse.getPosition()
    local _, _, w, h = atlasPart.quad:getViewport()
    print(contains(px, py, x, y, w, h))
end

return ui