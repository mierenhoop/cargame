local level = {}

function level.new()
	local ground = {}
	ground.body = love.physics.newBody(Game.world, 0, 0, "static");


	ground.points = {}
	for i = 1, 2000 do
		if i % 2 == 1 then
			ground.points[i] = 100 * i
		else
			ground.points[i] = 300 + (love.math.noise(i/10) ^ 2) * 200
		end
	end

	ground.shape = love.physics.newChainShape(false, ground.points)

	ground.fixture = love.physics.newFixture(ground.body, ground.shape)

	return ground
end

function level.draw(l)
	love.graphics.setColor(0, 0, 1, 1);
	love.graphics.line(l.points);
end

return level