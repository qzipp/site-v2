local Object = require("core").Object

---@class fuzzy.router.Response: luvit.core.Object
local Response = Object:extend()

---@param req fuzzy.router.Request
function Response:initialize(req)
  self.req = req
  self.app = self.req.app
  self.http = self.req.http

  self.has_body = self.http.res.hasBody
end

function Response:header(k, v)
  if self.http.res.headersSent then return self end
  self.http.res:setHeader(k, v)

  return self
end

function Response:send(data, content_type)
  data = tostring(data)
  if self.http.res.headersSent then
    trace("! you cant send response twice")
    return self
  end
  --todo: autodetect based on mime (maybe only text, html, image like png and so on)
  self.http.res:setHeader("content-type", content_type or "text/plain")
  self.http.res:setHeader("content-length", tostring(#data))
  self.http.res:finish(data)

  return self
end

function Response:finish()
  self.http.res:finish("")

  return self
end

---@param code number
function Response:status(code)
  self.http.res:writeHead(code, self.http.headers)

  return self
end

return Response