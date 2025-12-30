local Object = require("core").Object
local path = require("path")

local Response = require("./core/router/Response")
local Request = require("./core/router/Request")

---@alias fuzzy.Router.Method
---| "GET"
---| "POST"
---| "PUT"
---| "DELETE"
---| "PATCH"

---@alias fuzzy.Router.RouteCallback fun(req: fuzzy.router.Request, res: fuzzy.router.Response)

---@class fuzzy.Router: luvit.core.Object
local Router = Object:extend()

---@alias fuzzy.Router.Config {
---  path: string,
---}

--todo: add events so i can hook into them
---@param config fuzzy.Router.Config?
function Router:initialize(config)
  ---@type fuzzy.Router|nil
  self.parent = nil

  self.config = config or {
    path = "/"
  }
  self.path = self.config.path
  self.basepath = self.config.path

  ---@type table<number, fuzzy.router.MiddlewareFun>
  self.middlewares = {}

  ---@type table<number, fuzzy.Router>
  self.routers = {}

  ---@type table<fuzzy.Router.Method, table<string, fuzzy.Router.RouteCallback>>
  self.routes = {
    ["GET"] = {},
    ["POST"] = {},
    ["PUT"] = {},
    ["DELETE"] = {},
    ["PATCH"] = {}
  }
end

---@param middleware fuzzy.router.Middleware|fuzzy.router.MiddlewareFun
function Router:use(middleware)
  if type(middleware) == "table" then
    if middleware.call then
      -- bleh
      table.insert(self.middlewares, function(...)
        return middleware:call(...)
      end)
    else
      Logger:error(("middleware is invalid: \n%s"):format(debug.traceback()))
    end
  elseif type(middleware) == "function" then
    table.insert(self.middlewares, middleware)
  end

  return self
end

---@param router fuzzy.Router
function Router:mount(router)
  router:_mount_onto_router(self)
  table.insert(self.routers, router)

  return self
end

---@param router fuzzy.Router
function Router:_mount_onto_router(router)
  self.parent = router
  self.basepath = self:_get_basepath_from_parents()
end

-- im sorry
function Router:_get_basepath_from_parents()
  local t1 = {}

  -- recursively go through the bottom to the top 
  -- and add the router paths 
  local current = self
  while current ~= nil do
    table.insert(t1, current.path)

    current = current.parent
  end

  -- reverse the table
  local t2 = {}
  for i, v in pairs(t1) do
    t2[#t1 - (i-1)] = v
  end

  return path.join(table.unpack(t2))
end

---@param req fuzzy.router.Request
---@param res fuzzy.router.Response
---@return fuzzy.Router.RouteCallback|nil
function Router:handle(req, res)
  Logger:debug(("router (%s): request %s:`%s` picked up "):format(self.basepath, req.method, req.url))
  res:header("X-Powered-By", "fuzzy")

  Logger:debug("request calling middlewares")
  for i, middleware in pairs(self.middlewares) do
    middleware(req, res)
  end

  --todo: "compile" these
  --basically make em not have to do stuff like path join, less compute

  Logger:debug("request calling routes")
  for p, route in pairs(self.routes[req.method]) do
    if path.join(self.basepath, p) == req.url then
      Logger:debug(("request found matching route `%s`"):format(path))
      route(req, res)
    end
  end


  Logger:debug("request calling routers" .. #self.routers)
  for _, router in pairs(self.routers) do
    if string.find(router.basepath, "^"..router.basepath) then
      Logger:debug(("request found matching router `%s`"):format(router.path))
      router:handle(req, res)
    end
  end

  if not req.http.res.hasBody then
    res:status(404):finish()
  end
  Logger:debug("request end")
end

---@param method fuzzy.Router.Method
---@param path string
---@param handler fuzzy.Router.RouteCallback
function Router:method(method, path, handler)
  self.routes[method][path] = handler

  return self
end

---@param path string
---@param handler fuzzy.Router.RouteCallback
function Router:get(path, handler)
  return self:method("GET", path, handler)
end

---@param path string
---@param handler fuzzy.Router.RouteCallback
function Router:post(path, handler)
  return self:method("POST", path, handler)
end

---@param path string
---@param handler fuzzy.Router.RouteCallback
function Router:put(path, handler)
  return self:method("PUT", path, handler)
end

---@param path string
---@param handler fuzzy.Router.RouteCallback
function Router:delete(path, handler)
  return self:method("DELETE", path, handler)
end

---@param path string
---@param handler fuzzy.Router.RouteCallback
function Router:patch(path, handler)
  return self:method("PATCH", path, handler)
end


return Router