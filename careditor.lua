local state = require"gamestate":register"careditor"

local ResourceManager = require "resourcemanager"

local body = ResourceManager:getAtlasPart("HSVCarAtlas.png", 16, 1273, 781, 302)

local bodyTransform = love.math.newTransform()

-- also do wheelcollision and stuff

-- can't have shear, and circle before transform
-- is assumed to be unit circle
local function circleFromTransform(transform)
    local r = transform:transformPoint(1, 0)
    local x, y = transform:transformPoint(0, 0)
    return x, y, r
end

local cam = love.math.newTransform()

local function getCamera()
    local w, h = love.graphics.getDimensions()
    return love.math.newTransform(w / 2, h / 2) * cam:inverse()
end

function state.update(dt)
    local move = dt * 100
    if love.keyboard.isDown"q" then cam:scale(1 + dt) end
    if love.keyboard.isDown"e" then cam:scale(1 - dt) end
end

-- local gridData = love.image.newImageData(10, 10)
-- gridData:mapPixel(function(x, y)
--     return unpack((x == 0 or y == 0) and {1,1,1,.5} or {1,1,1,0})
-- end)
-- 
-- local grid = love.graphics.newImage(gridData)
-- grid:setFilter("nearest", "nearest")
-- grid:setWrap("repeat", "repeat")
-- 
-- love.graphics.draw(grid, love.graphics.newQuad(0, 0, 100*100, 100*100, 10, 10))

local objects = {}
for _, v in ipairs{"frame", "frontWheel", "rearWheel"} do
    objects[v] = {transform = love.math.newTransform()}
end

function state.draw()
    love.graphics.reset()
    love.graphics.applyTransform(getCamera())

    love.graphics.draw(body.image, body.quad, love.math.newTransform())

end
