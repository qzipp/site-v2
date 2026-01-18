local Logger = require("./Logger")

local Object = require("core").Object
local Path = require("path")

local libqu = require("./libs/libqu")

--fyi: every _* function is one that needs a good name

local Response = require("./router/Response")
local Request = require("./router/Request")

---@alias fuzzy.Router.Method
---| "ANY"
---| "GET"
---| "POST"
---| "PUT"
---| "DELETE"
---| "PATCH"
---| "OPTIONS"
---| "HEAD"

---@alias fuzzy.Router.Route {
---  method: fuzzy.Router.Method,
---  path: string,
---  pattern_path: string,
---  params: table<string>,
---  handler: fuzzy.Router.RouteCallback,
---}

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

  -- ---@type table<number, fuzzy.Router>
  -- self.routers = {}

  ---@type table<number, fuzzy.Router.Route|fuzzy.Router>
  self.routes = {}
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
  table.insert(self.routes, router)

  return self
end

---@param router fuzzy.Router
function Router:_mount_onto_router(router)
  self.parent = router
  self.basepath = Router:_get_basepath_from_parents()
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

  local path = Path.join(table.unpack(t2))

  if path == "." then
    return "/"
  else
    return path
  end
end

---@param req fuzzy.router.Request
---@param res fuzzy.router.Response
---@return fuzzy.Router.RouteCallback|nil
function Router:handle(req, res)
  Logger:debug(("router (%s): request %s:`%s` picked up "):format(self.basepath, req.method, req.url))
  res:header("X-Powered-By", "fuzzy")

  Logger:debug(("request calling middlewares (%d)"):format(#self.middlewares))
  for i, middleware in pairs(self.middlewares) do
    middleware(req, res)
  end

  -- todo: cleanup
  Logger:debug(("request calling routes (%d)"):format(#self.routes))
  for i, route in pairs(self.routes) do
    if route.meta then
      ---@type fuzzy.Router
      route = route
      route:handle(req, res)
      goto continue
    end
    ---@type fuzzy.Router.Route
    route = route 
    res.is_passable = false -- resets the ability to pass the request to another route

    -- merge router path and route path
    local real_path = Path.join(self.basepath, route.path)
    local real_path_pattern = "^" ..Path.join(self.basepath, route.pattern_path)
    
    Logger:debug(("  route -> %s %s | %s"):format(route.method, real_path, real_path_pattern))
    
    -- this is for params (like /hello/:world)
    local matches = {libqu.string.url_decode(req.url):match(real_path_pattern)}

    if route.method ~= "ANY" and req.method ~= route.method then goto continue end
    if #matches == 0 then
      if req.url ~= real_path then goto continue end
    end

    for i, param in pairs(route.params) do
      req.params[param] = matches[i]
    end
    
    Logger:debug(("  route -> %s %s is matching"):format(route.method, route.path))
    route.handler(req, res)

    -- a useful warning for probably something unintended 
    if not res.has_body and not res.is_passable then Logger:warn("no body returned") end

    -- we will stop the request, making it hang
    if res.has_body or not res.is_passable then break end

    ::continue::
  end

  if res.has_body then goto request_end end

  -- Logger:debug(("request calling routers (%d)"):format(#self.routes))
  -- for _, router in pairs(self.routers) do
  --   if string.find(router.basepath, "^"..router.basepath) then
  --     Logger:debug(("request found matching router `%s`"):format(router.path))
  --     router:handle(req, res)
  --   end
  -- end

  ::request_end::
  
  Logger:debug("request end")
end

---@param path string
function Router._path_to_luapattern_n_params(path)
  local params = {}
  local pattern = libqu.string.escape(path):gsub(":(%w+)", function(param)
    table.insert(params, param)
    return "(.*)"
  end) .. "$"

  return pattern, params
end


---@param method fuzzy.Router.Method
---@param path string
---@param handler fuzzy.Router.RouteCallback
function Router:method(method, path, handler)

  local pattern_path, params = self._path_to_luapattern_n_params(path)
  table.insert(self.routes, {
    method = method,
    path = path,
    pattern_path = pattern_path,
    
    params = params,
    
    handler = handler
  })

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