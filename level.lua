local readPLY = require "ply"

local levels = {}

-- Currently don't load at startup
-- because it can only load from love data folder
local function loadLevel(name)
    local file = "data/levels/" .. name
end

for _, level in ipairs(levels) do
    loadLevel(level)
end