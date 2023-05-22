local Wheel = {}

function Wheel.new()

end

local Car = {}

function Car.new(x, y)
    local self = setmetatable({}, { __index = Car })

    return self
end