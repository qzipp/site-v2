local Object = require("core").Object

---@class fuzzy.router.Request: luvit.core.Object
local Request = Object:extend()

---@param app fuzzy.App
---@param req luvit.http.IncomingMessage
---@param res luvit.http.ServerResponse
function Request:initialize(app, req, res)
  self.app = app
  self.http = {
    req = req,
    res = res,
  }

  ---@type fuzzy.Router.Method
  ---@diagnostic disable-next-line
  self.method = self.http.req.method

  --todo: transform into an URL object, or maybe not?
  ---@type string
  self.url = self.http.req.url
  ---@type string
  self.body = ""
end

return Request