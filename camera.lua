local camera = {}

camera.controller = love.math.newTransform()

function camera.getWindowTransform()
  local w, h = love.graphics.getDimensions()
  return love.math.newTransform(w / 2, h / 2) * camera.controller:inverse()
end

---@param transform love.Transform
---@param animation table
---@param into number
local function applyAnimation(transform, animation, into)
    if animation.scale then
        transform:scale(animation.scale * into, animation.scale * into)
    end
    if animation.move then
        transform:translate(animation.move.x * into, animation.move.y * into)
    end
end



local CameraAnimation = {}

function CameraAnimation.new(self)
    setmetatable(self, { __index = CameraAnimation })

    -- pre bake animations

    self.animationStartTime = love.timer.getTime()
    self.currentIndex = 1

    local transform = love.math.newTransform()

    local animationTime = 0
    for i = 1, #self do
        animationTime = animationTime + self[i].time
        self[i].endTime = animationTime

        self[i].startTransform = transform
        transform = transform:clone()

        applyAnimation(transform, self[i], 1)
    end

    return self
end

function CameraAnimation:getTransform()
    local currentAnimationTime = love.timer.getTime() - self.animationStartTime

    for i = self.currentIndex, #self do
        local time = self[i].time
        local endTime = self[i].endTime
        local startTime = endTime - self[i].time
        local elapsedHere = currentAnimationTime - startTime

        if elapsedHere < 0 then
            break
        end

        if elapsedHere < time then
            local into = math.min(1, elapsedHere / time)
            local transform = self[i].startTransform:clone()
            applyAnimation(transform, self[i], into)
            return transform
        end
    end
    local transform = self[#self].startTransform:clone()
    applyAnimation(transform, self[#self], 1)
    return transform
end

function CameraAnimation:finished()
    local currentTime = love.timer.getTime()

    return (currentTime - self.animationStartTime) > self[#self].endTime
end


local Camera = {
    transform = love.math.newTransform()
}

function Camera:applyReset()
    love.graphics.reset()
end

function Camera:applyCenter()
    local w, h = love.graphics.getDimensions()
    love.graphics.translate(w / 2, h / 2)
end

function Camera:move(x, y)
    self.transform:translate(x, y)
end

function Camera:scale(s)
    self.transform:scale(s, s)
end

function Camera:applyTransform()
    self:applyCenter()

    love.graphics.applyTransform(self.transform:inverse())
end

function Camera:playAnimation(animationData)
    local anim = CameraAnimation.new(animationData)
end


return camera
