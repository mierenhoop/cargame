local ResourceManager = require "resourcemanager"

local background = ResourceManager:getAtlasPart("MainMenuBackground.png", 0, 257, 1022, 767)

local button = ResourceManager:getAtlasPart("MainMenuBackground.png", 100, 100, 100, 100)

local GameState = require "gamestate"

local state = GameState:register("titlescreen")

local buttonBackground = ResourceManager:getAtlasPart("MainMenuMaterial.png", 0, 202, 186, 62)

local frame = ResourceManager:getAtlasPart("MainMenuMaterial.png", 0, 700, 246, 324)
local singleplayer = ResourceManager:getAtlasPart("MainMenuMaterial.png", 683, 612, 182, 37)

local res = ResourceManager:register {
    "background", "MainMenuBackground.png", 0, 257, 1022, 767,
    "button", "MainMenuBackground.png", 100, 100, 100, 100,
    "buttonBackground", "MainMenuMaterial.png", 0, 202, 186, 62,
    "frame", "MainMenuMaterial.png", 0, 700, 246, 324,
    "singleplayer","MainMenuMaterial.png", 683, 612, 182, 37,
}

---@comment Can't use rotation
---@param quad love.Quad
---@param transform love.Transform
---@param mx number
---@param my number
---@return boolean
local function contains(quad, transform, mx, my)
    local x, y, w, h = quad:getViewport()
    mx, my = transform:inverseTransformPoint(mx, my)
    return 0 < mx and mx < w and 0 < my and my < h
end

---@param quad love.Quad
---@param transform love.Transform
local function center(quad, transform)
    local _, _, w, h = quad:getViewport()
    transform:translate(-w/2, -h/2)
end

local animation = {
    0.0,
    {func="move", trans="linear", x=200, y=0},
    0.0,
    {func="move", trans="cubic-out", x=-100, y=0},
    1.0
}

local function interpolate(trans, into)
    if into == 1 then return 1
    elseif trans == "linear" then return into
    elseif trans == "quadratic-in" then return into*into
    elseif trans == "cubic-in" then return into*into*into
    elseif trans == "quadratic-out" then return math.sqrt(into)
    elseif trans == "cubic-out" then return math.pow(into,1/3)
    end
end

local function applyOperations(transform, ops, into)
    into = into or 1
    for _, op in ipairs(ops) do
        local n = interpolate(op.trans, into)
        if op.func == "scale" then
            transform:scale(1 + n*op.x, 1 + n*op.y)
        elseif op.func == "move" then
            transform:translate(n*op.x, n*op.y)
        elseif op.func == "rotate" then
            transform:rotate(n*op.r)
        end
    end
end

local function bake(self)
    local currentTime = 0.0
    local previousOperations = {}
    local transform = love.math.newTransform()
    local baked = {}
    for _, v in ipairs(self) do
        if type(v) == "number" then
            applyOperations(transform, previousOperations, 1)
            table.insert(baked, {startTime=currentTime, endTime = v, transform=transform:clone(), ops = previousOperations})
            currentTime = v
            previousOperations = {}
        elseif type(v) == "table" then
            table.insert(previousOperations, v)
        end
    end
    self.baked = baked

    self.currentIndex = 1
end

local function getTransform(self)
    local t = love.timer.getTime() - self.animationStartTime
    for i = self.currentIndex, #self.baked do
        local last = self.baked[i]
        if last.startTime > t then
            error"gone index too far"
        end

        if t < last.endTime then
            self.currentIndex = i
            local total = last.endTime - last.startTime
            local into = (t - last.startTime) / total
            local transform = last.transform:clone()
            applyOperations(transform, last.ops, into)
            return transform
        end
    end
    -- FIX EVERYTHING AFTER THIS
    local transform = self.baked[#self.baked].transform:clone()
    applyOperations(transform, self.baked[#self.baked].ops, 1)
    return transform
end

local loadingThread

function state.load()
    --loadingThread = love.thread.newThread("register")

    print(love.window.updateMode({ resizable = true }))

    bake(animation)
    animation.animationStartTime = love.timer.getTime()
end

function state.update()
end

local ui = require "ui".new()

local drawLoading = require"loading"

function state.draw()
    love.graphics.reset()

    --if loadingThread.isRunning() then
    --    drawLoading()
    --    return
    --end

    -- love.graphics.setColor(1, 0, 0)
    local scale = love.graphics.getWidth() / select(3, background.quad:getViewport())
    love.graphics.draw(background.image, background.quad, 0, 0, 0, scale)
    -- love.graphics.rectangle("fill", 0, 0, 1000, 300)


    local w = love.graphics.getWidth()
    local _, _, iw = frame.quad:getViewport()

    love.graphics.draw(frame.image, frame.quad, love.math.newTransform(w - 20 - iw, 10) * getTransform(animation))
    local _, _, bw, bh = buttonBackground.quad:getViewport()
    love.graphics.draw(buttonBackground.image, buttonBackground.quad, love.math.newTransform(w - 20 - iw/2 - bw/2, 50) * getTransform(animation) * (contains(buttonBackground.quad, love.math.newTransform(w - 20 - iw/2 - bw/2, 50) * getTransform(animation), love.mouse.getPosition()) and love.math.newTransform(bw/2, bh/2, math.pi, 1, 1, bw / 2, bh / 2) or love.math.newTransform(bw/2, bh/2, 0, 1, 1, bw / 2, bh / 2)))
    local _, _, sw = singleplayer.quad:getViewport()
    love.graphics.draw(singleplayer.image, singleplayer.quad, getTransform(animation) * love.math.newTransform(w - 20 - iw/2, 66, 0, 0.9, 0.9, sw/2))

    -- ui:button(100, 100, button)
end

--[[
startingtime
{func=move|scale|rotate, trans=linear|cubic|..., arguments...}
endtime
{another...}
endtime
]]

