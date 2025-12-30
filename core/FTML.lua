-- Fuzzy Table Markup Language
-- (would of been LTML, Lua Table Markup Language, but thats too boring)
local Object = require("core").Object

---@class fuzzy.FTML: luvit.core.Object
local FTML = Object:extend()

---@alias fuzzy.FTML.Config {
---  directory: string,
---} 

---@param config fuzzy.FTML.Config
function FTML:initialize(config)
  self.config = config
end

function FTML:render(path)
  
end

--- this is to be used on the templates themselves
---@type table<string, unknown>
_G.locals = {}

function FTML.escape(str)
  trace("TODO")
  return str
end

function FTML.html(table)
  setmetatable(table, {
    __call = function (t, ...)
      trace(...)
    end
  })
end


return FTML