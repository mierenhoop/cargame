local utils = {}

function utils.tostring(t, depth)
   -- TODO: implement this somehow
   local function checkrecursion(t, stack)
      stack = stack or {}
      if stack[t] then return true end
      stack[t] = true
      for k, v in pairs(t) do
         if checkrecursion(v, stack) then return true end
      end
      stack[t] = nil
      return false
   end

   local function reptabs(n)
      local out = ""
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
            out = out ..  utils.tostring(v, depth + 1) .. ",\n"
            haszero = false
         end
      end
      for _, v in ipairs(t) do
         out = out .. (haszero and "\n" or "") .. reptabs(depth)
         out = out ..  utils.tostring(v, depth + 1) .. ",\n"
         haszero = false
      end
      -- remove the last comma
      out = haszero and out or (out:sub(1, #out - 2) .. "\n")
      out = out .. (haszero and "" or reptabs(depth - 1)) .. "}"

      local blockend = #out
      -- inline the block
      if blockend - blockstart < 50 then
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

function utils.print(v)
   local out = string.gsub(utils.tostring(v), "\t", "   ")
   print(out)
end

local functions = {"update", "keypressed", "mousemoved", "mousepressed", "mousereleased", "draw"}
--local funcimpls = {}
--
--for _, func in ipairs(functions) do
--   love[func] = function(...)
--      if funcimpls[func] then
--         funcimpls[func](...)
--      end
--   end
--end

function utils.reloadstate(newstate, ...)
   utils.print(newstate)
   for _, f in ipairs(functions) do
      love[f] = newstate[f]
   end

   if newstate.load then
      newstate.load(...)
   end
end

return utils
