local gamestate = {}
local states = {}
local currentState

local useDebugHook = true

function gamestate.register(name)
    local state = {}
    states[name] = state

    return state
end

function gamestate.switch(name)
    currentState = name

    local state = states[currentState]

    if state.load then
        state.load()
    end

    for _, v in ipairs{"draw", "update", "filedropped", "keypressed", "mousereleased", "mousemoved", "wheelmoved"} do
        love[v] = state[v]
    end

    if useDebugHook then
      love.keypressed = function(key, ...)
        if key == "escape" then love.event.quit() end
        return state.keypressed(key, ...)
      end
      love.draw = function(...)
        state.draw(...)
        love.graphics.reset()
        local w, h, flags = love.window.getMode()
        love.graphics.setColor(0, 0, 0, .5)
        love.graphics.rectangle("fill", 0, h - 45, 200, h)
        love.graphics.setColor(1,1,1,1)
        love.graphics.print("VSYNC: " .. (flags.vsync == 1 and "ON" or "OFF"), 0, h - 40)
        love.graphics.print("FPS: " .. love.timer.getFPS(), 0, h - 20)
      end
    end
end

return gamestate
