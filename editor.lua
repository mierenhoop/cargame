local state = require"gamestate":register"editor"

local ResourceManager = require "resourcemanager"

local road = ResourceManager:getAtlasPart("faixa #78613.png", 0, 0, 512, 128)

local rocks = ResourceManager:getAtlasPart("caverna.png", 0, 0, 512, 256)
rocks.image:setWrap("repeat")

local cam = love.math.newTransform()

local function getCamera()
    local w, h = love.graphics.getDimensions()
    return love.math.newTransform(w / 2, h / 2) * cam:inverse()
end

function state.update(dt)
    local move = dt * 100
    if love.keyboard.isDown"w" then cam:translate(0, -move) end
    if love.keyboard.isDown"a" then cam:translate(-move, 0) end
    if love.keyboard.isDown"s" then cam:translate(0, move) end
    if love.keyboard.isDown"d" then cam:translate(move, 0) end
    if love.keyboard.isDown"q" then cam:scale(1 + dt) end
    if love.keyboard.isDown"e" then cam:scale(1 - dt) end
end

local points = {}
local pointSize = 10

local function containsCircle(a, b, r)
    return math.sqrt(math.pow(b[1] - a[1], 2) + math.pow(b[2]-a[2], 2)) < r
end

local ground = {}
local groundMesh

local groundBottom = 10000000
local groundTextureW = 200
local groundTextureH = 100

local function addGroundPoint(x, y)
    if #ground == 0 then
        ground[1] = {x, groundBottom, 0, groundBottom/groundTextureH}
        ground[2] = {x, groundBottom, 0, groundBottom/groundTextureH}
    end
    ground[#ground+1] = {x, y, x / groundTextureW, y/groundTextureH}
    ground[1][1] = ground[#ground][1]
    ground[1][3] = ground[#ground][3]

    -- TODO: shouldn't init every time
    groundMesh = love.graphics.newMesh(ground) -- fan dynamic is implicit
    groundMesh:setTexture(rocks.image)
end

local usingTexture = {
    position = 1,
    "ground", "car"
}

function state.mousereleased()
    local x, y = getCamera():inverseTransformPoint(love.mouse.getPosition())
    if usingTexture[usingTexture.position] == "ground" then
        table.insert(points, x)
        table.insert(points, y)

        addGroundPoint(x, y)
    end
end

function state.keypressed(a)
    if a == "left" then
        usingTexture.position = ((usingTexture.position-2) % (#usingTexture))+1
    elseif a == "right" then
        usingTexture.position = ((usingTexture.position) % (#usingTexture))+1
    end
end

local function unitVector(x, y)
    local len = math.sqrt(x*x + y*y)

    return x / len, y / len
end

function state.draw()
    love.graphics.reset()
    love.graphics.applyTransform(getCamera())

    --love.graphics.setColor(1,1,1)
    --love.graphics.setLineWidth(10)
    --if #points > 3 then love.graphics.line(points) end
    --love.graphics.points(points)
    for i = 1, #points, 2 do
        love.graphics.setColor(1, 1, (containsCircle({points[i],points[i+1]}, {getCamera():inverseTransformPoint(love.mouse.getPosition())}, pointSize) and 1 or 0))
        local x, y = points[i], points[i+1]
        love.graphics.circle("fill", x, y, pointSize)

        if i + 5 <= #points then
            local x1, y1, x2, y2, x3, y3 = select(i, unpack(points))
            local n1x, n1y = unitVector(y1 - y2, -(x1 - x2))
            local n2x, n2y = unitVector(y2 - y3, -(x2 - x3))
            local nx, ny = unitVector(n1x + n2x, n1y + n2y)

            local h = 50
            nx, ny = nx * h, ny * h

            love.graphics.line(x1, y1, x2, y2)
            love.graphics.line(x2, y2, x2 + nx, y2 + ny)
            love.graphics.line(x1, y1, x2 + nx, y2 + ny)
        end
    end

    if groundMesh then
        love.graphics.draw(groundMesh)
    end

    love.graphics.reset()

    love.graphics.print(usingTexture[usingTexture.position])
end
