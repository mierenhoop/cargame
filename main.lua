local GameState = require "gamestate"

require "titlescreen"
require "playing"
require "editor"
require"careditor"
require"atlaseditor"

function love.load()
    GameState.switch"atlaseditor"
end
