local ResourceManager = require "resourcemanager"

local state = require"gamestate":register"loading"

local background = ResourceManager:getAtlasPart("loadingScreenMat.png", 0, 384, 960, 640)

return function()
    love.graphics.draw(background.image, background.quad)
    love.graphics.print(love.timer.getDelta())
end
