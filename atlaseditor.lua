local state = require"gamestate".register"atlaseditor"

local camera = require "camera"

local textures = {selected = 1}

local dir = "data/Texture2D/"

local thread

local loading = {}

local boxes = {}

local transparent = {}
local function generateTransparentImage()
  local data = love.image.newImageData(2, 2)
  data:setPixel(0, 0, love.math.colorFromBytes(0xff, 0xff, 0xff, 0xff))
  data:setPixel(1, 0, love.math.colorFromBytes(0xee, 0xee, 0xee, 0xff))
  data:setPixel(0, 1, love.math.colorFromBytes(0xee, 0xee, 0xee, 0xff))
  data:setPixel(1, 1, love.math.colorFromBytes(0xff, 0xff, 0xff, 0xff))
  transparent.image = love.graphics.newImage(data)
  transparent.image:setWrap("repeat", "repeat")
  transparent.image:setFilter("nearest", "nearest")
  ransparent.quad = love.graphics.newQuad(0, 0, 10000, 10000, 2, 2)
end

function state.mousemoved(x, y, dx, dy)
    if love.mouse.isDown(1) then
        camera.controller:translate(-dx, -dy)
    end
end

function state.wheelmoved(_, y)
    camera.controller:scale(1 - 0.1 * y)
end

-- TODO: assign texture index to ImageData so the wrong texture is not used
local function loadImage()
    if not textures[textures.selected].image and not loading[textures.selected] then
        print("loading",textures[textures.selected].name)
        love.thread.getChannel"file":push(dir .. textures[textures.selected].name)
        loading[textures.selected] = true
    end
    camera.controller:reset()
end

function state.load()
  generateTransparentImage()
  camera.controller = love.math.newTransform()

    for i, file in ipairs(love.filesystem.getDirectoryItems(dir)) do
        print("loading", file)
        textures[i] = { name = file }
    end
    thread = love.thread.newThread("loadresources.lua")
    thread:start()

    loadImage()
    
    love.keyboard.setKeyRepeat(true)
end

function state.update()
    if not textures[textures.selected].image then
        local data = love.thread.getChannel"texture":pop()
        if data then
            textures[textures.selected].image = love.graphics.newImage(data)
        end
    end
end

function state.draw()
    love.graphics.reset()
    love.graphics.draw(transparent.image, transparent.quad, 0, 0, 0, 10, 10, 5000, 5000)
    love.graphics.applyTransform(camera.getWindowTransform())
    local im = textures[textures.selected].image
    if im then
        love.graphics.draw(im, 0, 0, 0,1, 1, im:getWidth()/2, im:getHeight()/2)
    end
    
    love.graphics.setLineWidth(2)
    for i, box in ipairs(boxes) do
      --if i ~= boxes.selected then
        love.graphics.setColor(1,0,0)
        love.graphics.rectangle("line", box.x-1, box.y-1, box.w+2, box.h+2)
        love.graphics.setColor(0,0,0,.5)
        love.graphics.rectangle("fill", box.x, box.y, box.w, box.h)
      --end
    end

  love.graphics.reset()
  love.graphics.setColor(0,0,0,0.5)
  love.graphics.rectangle("fill", 0, 0, 300, 20)
  love.graphics.setColor(1,1,1,1)
  love.graphics.print("Filename: " .. textures[textures.selected].name)
end

function state.keypressed(key, ...)
  if key == "d" then textures.selected = (textures.selected) % #textures + 1 loadImage() end
  if key == "a" then textures.selected = (textures.selected - 2) % #textures + 1 loadImage() end
  
  if key == "space" then
    boxes.selected = (boxes.selected or 0) + 1
    local w, h = love.window.getMode()
    w, h = camera.getWindowTransform():inverseTransformPoint(w/2, h/2)
    boxes[boxes.selected] = {x=w/2,y=h/2,w=10,h=10}
  end
  local bs = boxes[boxes.selected]
  if bs then
    local dx, dy = 0, 0
    if key == "right" then dx = dx + 1 end
    if key == "up"    then dy = dy - 1 end
    if key == "down"  then dy = dy + 1 end
    if key == "left"  then dx = dx - 1 end
  
    if love.keyboard.isDown"lctrl" then dx, dy = dx * 25, dy * 25 end
    if not love.keyboard.isDown"lshift" then
      bs.x, bs.y = bs.x + dx, bs.y + dy
      bs.w, bs.h = bs.w - dx, bs.h - dy
    else
      bs.w, bs.h = bs.w + dx, bs.h + dy
    end
    if bs.h < 0 then bs.h = 0 end
    if bs.w < 0 then bs.w = 0 end

  end
end
