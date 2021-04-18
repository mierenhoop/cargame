Game = {
   states = {}
}

require "menu"
require "game"

local functions = {"update", "mousereleased", "draw"}

function ReloadState(newstate)
   for _, f in ipairs(functions) do
      love[f] = Game.states[newstate][f]
   end

   if Game.states[newstate].load then
      Game.states[newstate].load()
   end
end

ReloadState("gamestate")
