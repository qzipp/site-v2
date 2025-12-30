local Object = require("core").Object

---@class fuzzy.FileSystemRouter: luvit.core.Object
local FileSystemRouter = Object:extend()

---@alias fuzzy.FileSystemRouter.Config {
---  directory: string,
---} 

---@param config fuzzy.FileSystemRouter.Config
function FileSystemRouter:initialize(config)
  self.config = config
end

function FileSystemRouter:handle(fun)
  
end