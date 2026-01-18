local Logger = require("./Logger")

local http = require("http")
local https = require("https")
local pathJoin = require('luvi').path.join
local fs = require('fs')

local Request = require("./router/Request")
local Response = require("./router/Response")

local Router = require("./Router")

local Emitter = require("core").Emitter;

---@class fuzzy.App: fuzzy.Router
local App = Router:extend()

---@alias fuzzy.App.Config {
---} | fuzzy.Router.Config

---@param config fuzzy.App.Config
function App:initialize(config)
  Router.initialize(self, config --[[@as fuzzy.Router.Config]])
end


---@param config { port: integer, onstart: fun(server: luvit.net.Server, ip: string, port: integer) }
function App:start(config)
  config.port = config.port or 8080

  local server = http.createServer(function(h_req, h_res)
    local req = Request:new(self, h_req, h_res)
    local res = Response:new(req)
    
    xpcall(self.handle, debug.traceback, self, req, res)
  end)

  --wonder why it doesnt say if a port is unavailable?
  --https://github.com/luvit/luvit/issues/1214
  Logger:info(("listening on port %d"):format(config.port))
  server:listen(config.port)
  config.onstart(server, "127.0.0.1", config.port)

  return server
end

return App