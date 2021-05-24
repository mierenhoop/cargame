local utils = require "utils"

local state = {}

local wheel = {}
wheel.radius = 20

local world

function wheel.new(frame, x, y)
   local w = {}

   w.body = love.physics.newBody(world, x, y, "dynamic")
   w.shape = love.physics.newCircleShape(wheel.radius)
   w.fixture = love.physics.newFixture(w.body, w.shape)
   w.fixture:setFriction(10.0)


   w.joint = love.physics.newWheelJoint(frame, w.body, x, y, 0, 1, false)
   w.joint:setSpringFrequency(5)
   w.joint:setSpringDampingRatio(0.8)

   return w
end

function wheel.draw(w)
   love.graphics.setColor(1, 1, 0)
   love.graphics.circle("fill", w.body:getX(), w.body:getY(), wheel.radius)
end

local frame = {}
frame.width = 100
frame.height = 30

function frame.new(x, y)
	local f = {}

	f.body = love.physics.newBody(world, x, y, "dynamic")
	f.shape = love.physics.newRectangleShape(frame.width, frame.height)
	f.fixture = love.physics.newFixture(f.body, f.shape)

	return f
end

function frame.draw(f)
	love.graphics.setColor(1, 1, 1, 1)

   local x, y, dw, dh= f.body:getX(), f.body:getY(), frame.width / 2, frame.height / 2
   love.graphics.polygon("fill", x - dw, y - dh, x + dw, y - dh, x + dw, y + dw, x - dw, y + dw)
end

local level = require "level"

local player = {}

local map

function state.load(l)
   love.window.setVSync(0)
   love.physics.setMeter(64)
   world = love.physics.newWorld(0, 9.81 * 64, true)
   local x, y = 200, 200
   player.frame = frame.new(x, y)

   player.rear  = wheel.new(player.frame.body, x - 35, y + 60)
   player.front = wheel.new(player.frame.body, x + 40, y + 60)

   map = l
end

function state.update(dt)
   if love.keyboard.isDown "w" then
		player.front.body:applyTorque(1/dt*1000000)
	end
   if love.keyboard.isDown("a") then
      player.frame.body:applyTorque(-20000)
   end
   if love.keyboard.isDown("d") then
      player.frame.body:applyTorque(20000)
   end
   if love.keyboard.isDown("s") then
      player.front.body:applyTorque(1/dt*-1000000)
   end

   world:update(dt)
end

local mesh = love.graphics.newMesh(require "data/bg", "triangles", "static")
local texture = love.graphics.newImage("data/bg.png")
texture:setWrap("repeat")
mesh:setTexture(texture)

function state.draw()
   local w, h = love.graphics.getDimensions()
   love.graphics.translate(w / 2 - player.frame.body:getX(), h / 2 - player.frame.body:getY())
   
   love.graphics.setColor(1, 1, 1, 1)
   love.graphics.draw(mesh, 300, 300, 0, 50, 50)

   frame.draw(player.frame)

   wheel.draw(player.rear)
   wheel.draw(player.front)

   level.draw(map)

   love.graphics.origin()
   love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end

function drawflag(pos)
   love.graphics.setColor(1, 1, 0, 0.5)
   love.graphics.rectangle(pos.x, pos.y, 50, 50)
   love.graphics.print("Flag", pos.x + 10, pos.y + 10)
end

return state
