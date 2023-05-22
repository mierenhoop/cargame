local ResourceManager = {
    resources = {}
}

local namePrefix = "data/Texture2D/"

---@class AtlasPart
---@field quad love.Quad
---@field image love.image

--TODO: Make this an actual class with draw method
-- also maybe use sprite batches
-- also should register all atlas positions at begin of file,
-- retrieve and draw the actual images at place they are needed

---@param name string
---@param x number
---@param y number
---@param w number
---@param h number
---@return AtlasPart
function ResourceManager:getAtlasPart(name, x, y, w, h)
    local filename = namePrefix .. name
  
    if not self.resources[name] then
        local image = love.graphics.newImage(filename)
        self.resources[name] = image
    end

    local image = self.resources[name]


    return {
        quad = love.graphics.newQuad(x, y, w, h, image:getDimensions()),
        image = image,
    }
end

local resourceDefinitions = {}

function ResourceManager:register(t)
    table.insert(resourceDefinitions, t)
end

return ResourceManager
