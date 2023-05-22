local GameState = require "gamestate"

local state = GameState:register"playing"

local bg1image, bg2image

function state.load()
    bg1image = love.graphics.newImage("data/Texture2D/bg01 #78614.png")
    bg2image = love.graphics.newImage("data/Texture2D/bg02 #78610.png")
end

local camera = { x = 0, y = 0 }
local bg1depth = 50
local bg2depth = 20

-- local CameraAnimation = require "camera"
-- 
-- local anim = CameraAnimation.new {
--     {
--         time = 10,
--         scale = 2
--     },
--     {
--         time = 20,
--         move = {x = 2000, y = 0}
--     }
-- }

-- function Camera:playAnimation(animationData)
--     local anim = CameraAnimation.new(animationData)
-- end

function state.update(dt)
    dt = dt * 100
    --Camera:scale(dt)
    if love.keyboard.isDown"w" then camera.y = camera.y - dt end
    if love.keyboard.isDown"s" then camera.y = camera.y + dt end
    if love.keyboard.isDown"a" then camera.x = camera.x - dt end
    if love.keyboard.isDown"d" then camera.x = camera.x + dt end
end

function state.draw()
    local w, h = love.graphics.getDimensions()

    love.graphics.translate(w / 2, h / 2)

    love.graphics.push()

    love.graphics.translate(-camera.x / bg1depth, -camera.y / bg1depth) -- y also?
    love.graphics.draw(bg1image, 0, 0, 0, 1,1, bg1image:getWidth() / 2, bg1image:getHeight() / 2)

    love.graphics.pop()

    love.graphics.push()
    love.graphics.translate(-camera.x / bg2depth, -camera.y / bg2depth)
    love.graphics.draw(bg2image, 0, 0, 0, 1,1, bg2image:getWidth() / 2, bg2image:getHeight() / 2)
    love.graphics.pop()
end

local readPLY = require "ply"

---@param f love.DroppedFile
function state.filedropped(f)
    f:open("r")

    readPLY(f)

    f:close()
end