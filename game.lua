local utils = require "utils"
local level = require "level"
local playerm = require "player"

local state = {}

local player

local map

local backcb

local world

function state.load(l, cb)
   love.window.setVSync(0)
   love.physics.setMeter(64)
   world = love.physics.newWorld(0, 9.81 * 64, true)

   player = playerm.new(world, l.player.x, l.player.y)

   map = l

   for _, line in ipairs(map.lines) do
      local shape = love.physics.newEdgeShape(line[1].x, line[1].y, line[2].x, line[2].y)
      local body = love.physics.newBody(world, 0, 0, "static")
      local fixture = love.physics.newFixture(body, shape)
      fixture:setFriction(1)
   end

   backcb = cb
end

function state.update(dt)
   if love.keyboard.isDown "w" then
      player.rear.body:applyTorque(1000)
   end
   if love.keyboard.isDown "s" then
      player.rear.body:applyTorque(-1000)
   end
   if love.keyboard.isDown("a") then
      player.body:applyTorque(-2000)
   end
   if love.keyboard.isDown("d") then
      player.body:applyTorque(2000)
   end

   world:update(dt)
end

function state.keypressed(k)
   if k == "escape" then
      backcb()
   end
end

-- local mesh = love.graphics.newMesh(require "data/bg", "triangles", "static")
-- local texture = love.graphics.newImage("data/bg.png")
-- texture:setWrap("repeat")
-- mesh:setTexture(texture)

function state.draw()
   local w, h = love.graphics.getDimensions()
   love.graphics.translate(w / 2 - player.body:getX(), h / 2 - player.body:getY())
   
   love.graphics.setColor(1, 1, 1)
   --love.graphics.draw(mesh, 300, 300, 0, 50, 50)

   playerm.draw(player)

   level.draw(map)

   love.graphics.origin()
   love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end

return state
