local ton = tonumber

---@param f file*
local function read(f)
    local objects = {}
    for l in f:lines("*l") do
        local cmd, args = l:match("^%s*(%g+)([^#]*)$")
        if not cmd or cmd:sub(1,1) == "#" then
        elseif cmd == "o" then
            objects[#objects+1] = { name = args:match("%g+"), v = {}, vt = {}, f = {} }
        elseif cmd == "v" then
            local o = objects[#objects]
            local x, y, z = args:match("(%g+)%s+(%g+)%s+(%g+)")
            o.v[#o.v+1] = { x = ton(x), y = ton(y), z = ton(z) }
        elseif cmd == "vt" then
            local o = objects[#objects]
            local s, t = args:match("(%g+)%s+(%g+)")
            o.vt[#o.vt+1] = { s = ton(s), t = ton(t) }
        elseif cmd == "f" then
            local i1, i2, i3, i4, i5, i6 = args:match("(%d+)/(%d+)%s+(%d+)/(%d+)%s+(%d+)/(%d+)")
            i1, i2, i3, i4, i5, i6 = ton(i1)+1, ton(i2)+1, ton(i3)+1, ton(i4)+1, ton(i5)+1, ton(i6)+1
            local o = objects[#objects]
            local v1, vt1, v2, vt2, v3, vt3 = o.v[i1], o.vt[i2], o.v[i3], o.vt[i4], o.v[i5], o.vt[i6]
            local face = {{}, {}, {}}
            -- Use Love2d format when rendering mesh
            local mesh = {v1.x, v1.y, vt1.s, vt1.t}

            -- drawmode is "triangles"
        end
    end
end

local f = io.open("data/levels/untitled.obj", "r")
read(f)
f:close()