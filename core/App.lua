local http = require("http")
local https = require("https")
local pathJoin = require('luvi').path.join
local fs = require('fs')

local Request = require("./core/router/Request")
local Response = require("./core/router/Response")

local Router = require("./core/Router")

---@class fuzzy.App: fuzzy.Router
local App = Router:extend()

---@alias fuzzy.App.Config {
---} 

-- ---@param config fuzzy.App.Config
function App:initialize()
  Router.initialize(self)
end

--todo events
function App:start(config)
  config.port = config.port or 8080

  local server = http.createServer(function(h_req, h_res)
    local req = Request:new(self, h_req, h_res)
    local res = Response:new(req)
    
    xpcall(self.handle, trace, self, req, res)
  end)

  --wonder why it doesnt say if a port is unavailable?
  --https://github.com/luvit/luvit/issues/1214
  trace(("listening on port %d"):format(config.port))
  server:listen(config.port)

  return server
end

return App