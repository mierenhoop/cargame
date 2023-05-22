require"love.image"

while true do
    local file = love.thread.getChannel"file":demand()
    love.thread.getChannel"texture":supply(love.image.newImageData(file))
end
