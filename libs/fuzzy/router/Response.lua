local Logger = require("../Logger")

local Object = require("core").Object

---@class fuzzy.router.Response: luvit.core.Object
local Response = Object:extend()

---@param req fuzzy.router.Request
function Response:initialize(req)
  self.req = req
  self.app = self.req.app
  self.http = self.req.http

  self.has_body = self.http.res.hasBody
  self.headers_sent = self.http.res.headersSent

  self.is_passable = false
end

function Response:header(k, v)
  if self.http.res.headersSent then return self end
  self.http.res:setHeader(k, v)

  return self
end

function Response:send(data, content_type)
  data = tostring(data)
  if self.has_body then
    Logger:warn("already has body")
    return self
  end
  if self.headers_sent then
    Logger:warn("you can't send headers more than once")
    return self
  end

  --todo: autodetect based on mime (maybe only text, html, image like png and so on)
  self.http.res:setHeader("content-type", (content_type or "text/plain; charset=utf-8"))
  self.http.res:setHeader("content-length", tostring(#data))
  self.http.res:finish(data)

  return self
end

function Response:pass()
  self.is_passable = true

  return self
end

---@param str string
function Response:write(str)
  self.http.res:write(str)

  return self
end

---@param str? string
function Response:finish(str)
  self.http.res:finish(str or "")

  return self
end

---@param code number
function Response:status(code)
  self.http.res:writeHead(code, self.http.headers)

  return self
end

return Response