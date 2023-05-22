local unpack = string.unpack
if love then
    unpack = love.data.unpack
end

---comment
---@param file love.File
return function (file)
    local header = file:read(0x14)
    
    local msize, _, version, datastart, endian = unpack(">I4I4I4I4I1", header)
    endian = endian == 0 and "<" or ">"

    assert(version == 9)
    
    local metadata = file:read(msize)
    
    local _, _, ntypes, pos = unpack(endian .. "zI4I4", metadata)
    -- print(msize, version, endian, ntypes)
    assert(ntypes == 0)

    local nobj = unpack(endian .. "I4", metadata, pos + 4)
    pos = pos + 8

    for i = 1, nobj do
        local posi = pos + (i - 1) * 20
        local off, sz = unpack(endian .. "I4I4", metadata, posi)

        print(off + datastart, sz, nobj, file:getFilename())
        return
    end
end
