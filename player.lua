local wheel = {}
wheel.radius = 15

function wheel.new(world, frame, x, y)
   local w = {}

   w.body = love.physics.newBody(world, x, y, "dynamic")
   w.shape = love.physics.newCircleShape(wheel.radius)
   w.fixture = love.physics.newFixture(w.body, w.shape, 0.2)
   w.fixture:setFriction(0.90)


   w.joint = love.physics.newWheelJoint(frame, w.body, x, y, 0, 1, false)
   w.joint:setSpringFrequency(10)
   w.joint:setSpringDampingRatio(0.90)

   return w
end

local wheelimage = love.graphics.newImage "data/wheel.png"
local frameimage = love.graphics.newImage "data/frame.png"

function wheel.draw(w)
   love.graphics.setColor(1, 1, 1)
   love.graphics.circle("fill", w.body:getX(), w.body:getY(), wheel.radius)
   local iw, ih = wheelimage:getWidth(), wheelimage:getHeight()
   love.graphics.draw(wheelimage, w.body:getX(), w.body:getY(), w.body:getAngle(), wheel.radius / iw * 2, wheel.radius / ih * 2, iw / 2, ih / 2)

end

local player = {}
player.radius = 10

function player.new(world, x, y)
	local f = {}

	f.body = love.physics.newBody(world, x - 30, y + 15, "dynamic")
	f.shape = love.physics.newCircleShape(player.radius)
	f.fixture = love.physics.newFixture(f.body, f.shape)

   f.rear  = wheel.new(world, f.body, x - 30, y + 15)
   f.front = wheel.new(world, f.body, x + 30, y + 15)

	return f
end

function player.draw(f)
	love.graphics.setColor(1, 1, 1)
	wheel.draw(f.rear)
	wheel.draw(f.front)

   local x, y = f.body:getX(), f.body:getY()

   local scale = 0.17
   local iw, ih = frameimage:getWidth(), frameimage:getHeight()
   love.graphics.draw(frameimage, f.body:getX() - 10, f.body:getY(), f.body:getAngle(), scale, scale, 0, ih)

end

function player.drawdefault(x, y)
end


return player
