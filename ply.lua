local ton = tonumber

local function asciiUnpacker(props)
    return function(f)
        local t = {}
        local l = f:read"*l"
        for _, prop in ipairs(props) do
            local name, type = prop.name, prop.type
            local n
            n, l = string.match(l, "(%g+)(.*)$")
            n = ton(n)
            if prop.listtype then
                t[name] = {}
                for i = 1, n do
                    n, l = string.match(l, "(%g+)(.*)$")
                    n = ton(n)
                    t[name][i] = n
                end
            else
                t[name] = n
            end
            --needed?
        end
        return t
    end
end

-- TODO: do list types too
local function binaryUnpacker(props, format)
---@diagnostic disable-next-line: deprecated
    local unpack = string.unpack or love.data.unpack
---@diagnostic disable-next-line: deprecated
    local packsize = string.packsize or love.data.getPackedSize
    local fmt = ({binary_little_endian=">",binary_big_endian="<"})[format]
    assert(fmt)

    local types = {
        char    = "b",  uchar   = "B",
        short   = "h",  ushort  = "H",
        int     = "i",  uint    = "I",
        float   = "f",  double  = "d",
        int8    = "i1", uint8   = "I1",
        int16   = "i2", uint16  = "I2",
        int32   = "i4", uint32  = "I4",
        float32 = "f",  float64 = "d",
    }
    for _, prop in ipairs(props) do
        local name, type = prop.name, prop.type
        assert(types[type])
        fmt = fmt .. types[type]
    end
    local size = packsize(fmt)
    return function(f)
        local bytes = f:read(size)
        local t = {unpack(fmt, bytes)}
        t[#t] = nil -- next position
        for i, prop in ipairs(props) do
            t[prop.name] = t[i]
            t[i] = nil
        end
        return t
    end
end

---@param f file*
local function read(f)
    assert(f:read("*l") == "ply")
    local format, version  = f:read("*l"):match("format (.+) (.+)$")

    local elements = {}

    for l in f:lines() do
        local cmd, args = l:match("^(%g+)(.*)$")

        if cmd == "property" then
            local type, name = args:match("(%w+) (%g+)$")
            assert(type and name)
            local listtype = args:match("^ list (%w+)")
            table.insert(elements[#elements].properties, {listtype = listtype, type = type, name = name})
        elseif cmd == "comment" then
        elseif cmd == "element" then
            local name, count = args:match("(%g+) (%d+)")
            assert(name and ton(count))
            elements[#elements+1] = {name = name, count = ton(count), properties = {}}
        elseif cmd == "end_header" then
            break
        else
            error("command: " .. tostring(cmd) .. " not expected")
        end
    end


    for i, element in ipairs(elements) do
        local unpacker = format == "ascii"
                     and asciiUnpacker(element.properties)
                     or binaryUnpacker(element.properties, format)
        for j = 1, element.count do
            element[j] = unpacker(f)
        end
        elements[element.name] = element
        -- clean up
        element.name = nil
        element.count = nil
        element.properties = nil
        elements[i] = nil
    end

    return elements
end

return read