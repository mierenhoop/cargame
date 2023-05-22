local unpack = string.unpack

if love then
    unpack = love.data.unpack
end

---@class zipfile
---@field name string
---@field _zmethod number
---@field _rawdata string
---@field _cachedata string
local zipfile = {}

function zipfile:data()
    if not self._cachedata then
        if self._zmethod == 8 then
            -- deflate no header
            self._cachedata = self._rawdata
            if love then
                self._cachedata = love.data.decompress("string", "deflate", self._rawdata)
            end
        elseif self._zmethod == 0 then
            self._cachedata = self._rawdata
        end
    end
    return self._cachedata
end

---@class zip
---@field _file file*
---@field numfiles number
local zip = {}

function zip.new(file)
    local total = file:seek("end", 0)

    local toread = math.min(0xffff, total)

    file:seek("set", total - toread)

    local buf = file:read(toread)

    local headerstart

    for at = toread - 21, 0, -1 do
        local magic = buf:sub(at, at + 3)
        if magic == "\x50\x4b\x05\x06" then
            headerstart = at
            break
        end
    end

    local volno, volnodir, volentries, totentries, _, diroffs = unpack("<I2I2I2I2I4I4", buf, headerstart + 4)

    file:seek("set", diroffs)

    local self = setmetatable({}, { __index = zip })
    self._file = file
    self.numfiles = totentries

    return self
end

function zip:files()
    local file = self._file
    local function getnext(_, prev, _)
        if prev._index >= self.numfiles then return nil end
        local buf = file:read(46)
        local magic = buf:sub(1, 4)
        local zmethod = unpack("<I2", buf, 11)
        local size, unsize, namelen, xtralen, commlen = unpack("<I4I4I2I2I2", buf, 21)
        local offsrel = unpack("<I4", buf, 43)

        assert(magic == "\x50\x4b\x01\x02")
        assert(namelen <= 0xffff)

        local name = file:read(namelen)
        file:seek("cur", xtralen + commlen)

        local offset = offsrel
        if size ~= 0 or name:sub(#name) ~= "/" then
            assert(zmethod == 0 or zmethod == 8)
            local pos = file:seek("cur", 0)
            file:seek("set", offset)
            buf = file:read(30)
            magic = buf:sub(1, 4)
            assert(magic == "\x50\x4b\x03\x04")
            namelen, xtralen = unpack("<I2I2", buf, 27)
            file:seek("cur", namelen + xtralen)
            local data = file:read(size)

            file:seek("set", pos)
            return setmetatable({ name = name, _rawdata = data, _zmethod = zmethod, _index = prev._index + 1 }, { __index = zipfile })
        else
            return getnext(nil, { _index = prev._index + 1 })
        end
    end

    return getnext, nil, { _index = 0 }
end

local file = io.open("file.zip", "rb")

local z =  zip.new(file)

for f in z:files() do
    print(f.name, #f:data())
end

file:close()
