function exporttable(t, depth)
   local function reptabs(n)
      out = ""
      for i = 1, n do
         out = out .. "\t"
      end
      return out
   end

   local out = ""
   depth = depth or 1

   if type(t) == "table" then
      out = out .. "{"
      local blockstart = #out
      local haszero = true
      for k, v in pairs(t) do
         if type(k) == "string" then
            out = out .. (haszero and "\n" or "") .. reptabs(depth)
            out = out .. k .. " = "
            out = out ..  exporttable(v, depth + 1) .. ",\n"
            haszero = false
         end
      end
      for _, v in ipairs(t) do
         out = out .. (haszero and "\n" or "") .. reptabs(depth)
         out = out ..  exporttable(v, depth + 1) .. ",\n"
         haszero = false
      end
      -- remove the last comma
      out = haszero and out or (out:sub(1, #out - 2) .. "\n")
      out = out .. (haszero and "" or reptabs(depth - 1)) .. "}"

      local blockend = #out
      -- inline the block
      if blockend - blockstart < 200 then
         local part = out:sub(blockstart, blockend)
         part = part:gsub("\n", " ")
         part = part:gsub("\t", "")
         out = out:sub(1, blockstart - 1) .. part
      end
   elseif type(t) == "number" then
      out = out .. tostring(t)
   elseif type(t) == "string" then
      out = out .. "\"" .. t .. "\""
   elseif type(t) == "boolean" then
      out = out .. (t and "true" or "false" )
   end

   return out
end

function parsemtl(data)

end

function parseobj(data)

   local decpat = "%-?%d+%.%d+"
   local objects = {}
   local object
   for line in data:gsub("#[^\n]*", ""):gmatch("[^\n]+") do
      local _, _, command = line:find("^(%w+)%s")

      if command == "v" then
         local _, _, x = line:find("^%w+%s+" .. "(" .. decpat .. ")")
         local _, _, y = line:find("^%w+%s+" .. decpat .. "%s+(" .. decpat .. ")")
         table.insert(object.vertices, { x = tonumber(x), y = tonumber(y) })
      elseif command == "vt" then
         local _, _, u = line:find("^%w+%s+" .. "(" .. decpat .. ")")
         local _, _, v = line:find("^%w+%s+" .. decpat .. "%s+(" .. decpat .. ")")
         table.insert(object.coords, { u = tonumber(u), v = tonumber(v) })
      elseif command == "o" then
         local _, _, name = line:find("^%w+%s+(%w+)")
         object = {vertices = {}, faces = {}, coords = {}}
         objects[name] = object
      elseif command == "f" then
         local face = {}
         for v, vt in line:gmatch("%s+(%d+)/(%d+)") do
            table.insert(face, { v = tonumber(v), vt = tonumber(vt) })
         end
         table.insert(object.faces, face)
      else
         -- print("unused", command)
      end
   end
   return objects
end

function convertobject(object)
   local vertices = {}
   for _, face in ipairs(object.faces) do
      for _, comb in ipairs(face) do
         local vertex = object.vertices[comb.v]
         local vt = object.coords[comb.vt]
         table.insert(vertices, { vertex.x, vertex.y, vt.u, vt.v })
      end
   end
   return vertices
end

local object = parseobj(io.open("test.obj", "r"):read("*a"))
print("return " .. exporttable(convertobject(object.Plane)))
--print(exporttable(parseobj(io.open("/tmp/untitled.obj", "r"):read("*a"))))