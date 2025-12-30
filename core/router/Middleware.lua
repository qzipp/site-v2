local Object = require("core").Object

---@alias fuzzy.router.MiddlewareFun fun(req: fuzzy.router.Request, res: fuzzy.router.Response)

---@class fuzzy.router.Middleware: luvit.core.Object
local Middleware = Object:extend()

function Middleware:initialize() end

---@param req fuzzy.router.Request
---@param res fuzzy.router.Response
function Middleware:call(req, res) end

return Middleware