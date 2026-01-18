local Object = require("core").Object
local Color = require("./Color")

-- MASSIVE TODO:
--  remove time, add Logger.time

---@class kitty.Logger: luvit.core.Object
local Logger = Object:extend()

local Path = require("path")

--todooooo: make this have levels of verbosity 

--- TODOOOOO give this a namespace like fuzzy
--- make warnings and stuff more verbose, such as give where it came from (Stacktrace)

---@param depth? number
function Logger.get_source_caller(depth)
  local caller = debug.getinfo(depth or 3, "lS")
  local c_line = caller.currentline
  local c_source = Path.relative(".", caller.source:match("@(.*)$"))

  return ("%s:%s"):format(c_source, c_line)
end

---this function knows your home address
---@param ... any
function Logger:trace(...)
  -- if not Config.debug then return end

  local args = {...}
  local all = ""
  for i = 1, table.maxn(args) do
    local arg = args[i]
    arg = tostring(arg)
    arg = arg:len() == 0 and "<empty string>" or arg

    local sep = table.maxn(args) == i and "" or ", "

    all = all .. arg .. sep

  end
  
  print(("%s: %s"):format(Logger.get_source_caller(), all))
end

Logger.TEXT_LEVEL_WARN = Color:format("&{yellow bright}WARN")

---@param message string
function Logger:warn(message)
  self:log(Logger.TEXT_LEVEL_WARN, Logger.get_source_caller(), message)
end

Logger.TEXT_LEVEL_DEBUG = Color:format("&{magenta bright}DEBUG")

---@param message string
function Logger:debug(message)
  -- if os.getenv("DBG") ~= "1" then return end -- windows.. hello?? are you DUMB?? WHY DONT U WORK

  self:log(Logger.TEXT_LEVEL_DEBUG, Logger.get_source_caller(), message)
end

Logger.TEXT_LEVEL_ERROR = Color:format("&{red bright}ERROR")

---@param message string
function Logger:error(message)

  self:log(Logger.TEXT_LEVEL_ERROR, Logger.get_source_caller(), message)
end

Logger.TEXT_LEVEL_INFO = Color:format("&{green bright}INFO")

---@param message string
function Logger:info(message)

  self:log(Logger.TEXT_LEVEL_INFO, Logger.get_source_caller(), message)
end

---@param level string
---@param namespace string
---@param message string
function Logger:log(level, namespace, message)
  local date = os.date("%H:%M:%S")

  print(("%s [%s %s]: %s"):format(date, namespace, level, message))
end

return Logger:new()